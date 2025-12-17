#!/bin/bash
# Provisioning script pour la VM Monitoring (Nagios)

set -e

echo "=== Mise à jour du système ==="
apt-get update && apt-get upgrade -y

echo "=== Installation des dépendances ==="
apt-get install -y \
    apache2 \
    php \
    php-gd \
    libgd-dev \
    libapache2-mod-php \
    build-essential \
    unzip \
    wget \
    curl \
    openssl \
    libssl-dev \
    nagios-plugins \
    nagios-nrpe-plugin

echo "=== Création de l'utilisateur Nagios ==="
useradd -m -s /bin/bash nagios || true
groupadd nagcmd || true
usermod -aG nagcmd nagios
usermod -aG nagcmd www-data

echo "=== Téléchargement et installation de Nagios Core ==="
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.14.tar.gz
tar xzf nagios-4.4.14.tar.gz
cd nagios-4.4.14

./configure --with-httpd-conf=/etc/apache2/sites-enabled --with-command-group=nagcmd
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf

echo "=== Configuration Apache ==="
a2enmod rewrite cgi
htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin

echo "=== Configuration de Nagios pour surveiller l'infrastructure ==="
cat > /usr/local/nagios/etc/objects/transcriber.cfg << 'EOF'
# Configuration Nagios pour l'application Transcriber

# Définition des hosts
define host {
    use                     linux-server
    host_name               master
    alias                   Master Server (Jenkins)
    address                 192.168.56.10
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

define host {
    use                     linux-server
    host_name               worker
    alias                   Worker Server (Docker App)
    address                 192.168.56.11
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

# Services pour Master
define service {
    use                     generic-service
    host_name               master
    service_description     Jenkins Service
    check_command           check_http!-p 8080
}

define service {
    use                     generic-service
    host_name               master
    service_description     SSH
    check_command           check_ssh
}

# Services pour Worker
define service {
    use                     generic-service
    host_name               worker
    service_description     Transcriber App
    check_command           check_http!-p 8501 -u /_stcore/health
}

define service {
    use                     generic-service
    host_name               worker
    service_description     Docker Service
    check_command           check_nrpe!check_docker
}

define service {
    use                     generic-service
    host_name               worker
    service_description     Disk Usage
    check_command           check_nrpe!check_disk
}

define service {
    use                     generic-service
    host_name               worker
    service_description     CPU Load
    check_command           check_nrpe!check_load
}

define service {
    use                     generic-service
    host_name               worker
    service_description     PostgreSQL
    check_command           check_tcp!5432
}
EOF

# Ajouter la config au fichier principal
echo "cfg_file=/usr/local/nagios/etc/objects/transcriber.cfg" >> /usr/local/nagios/etc/nagios.cfg

echo "=== Démarrage des services ==="
systemctl enable apache2
systemctl start apache2
systemctl enable nagios
systemctl start nagios

echo "=== Provisioning Monitoring terminé ==="
echo "Nagios Web: http://192.168.56.12/nagios"
echo "Utilisateur: nagiosadmin / Mot de passe: nagiosadmin"

