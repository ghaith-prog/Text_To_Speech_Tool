#!/bin/bash
# Provisioning script pour la VM Worker (Docker Application)

set -e

echo "=== Mise à jour du système ==="
apt-get update && apt-get upgrade -y

echo "=== Installation des dépendances ==="
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

echo "=== Installation de Docker ==="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== Installation de Docker Compose ==="
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "=== Configuration des permissions ==="
usermod -aG docker vagrant

echo "=== Démarrage de Docker ==="
systemctl enable docker
systemctl start docker

echo "=== Création du répertoire de l'application ==="
mkdir -p /opt/transcriber
chown vagrant:vagrant /opt/transcriber

echo "=== Installation de NRPE pour Nagios ==="
apt-get install -y nagios-nrpe-server nagios-plugins

cat > /etc/nagios/nrpe.cfg << EOF
server_address=192.168.56.11
allowed_hosts=127.0.0.1,192.168.56.12
command[check_docker]=sudo /usr/lib/nagios/plugins/check_procs -c 1: -C dockerd
command[check_app]=curl -sf http://localhost:8501/_stcore/health || exit 2
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_load]=/usr/lib/nagios/plugins/check_load -w 5,4,3 -c 10,8,6
EOF

systemctl enable nagios-nrpe-server
systemctl restart nagios-nrpe-server

echo "=== Provisioning Worker terminé ==="

