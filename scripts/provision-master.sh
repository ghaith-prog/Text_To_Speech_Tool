#!/bin/bash
# Provisioning script pour la VM Master (Jenkins + Ansible)

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
    software-properties-common \
    git \
    python3-pip \
    sshpass

echo "=== Installation de Docker ==="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== Installation de Docker Compose ==="
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "=== Installation de Jenkins ==="
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y openjdk-17-jdk jenkins

echo "=== Installation d'Ansible ==="
pip3 install ansible

echo "=== Configuration des permissions ==="
usermod -aG docker jenkins
usermod -aG docker vagrant

echo "=== Démarrage des services ==="
systemctl enable docker
systemctl start docker
systemctl enable jenkins
systemctl start jenkins

echo "=== Configuration SSH pour Ansible ==="
mkdir -p /home/vagrant/.ssh
cat >> /home/vagrant/.ssh/config << EOF
Host worker
    HostName 192.168.56.11
    User vagrant
    StrictHostKeyChecking no

Host monitoring
    HostName 192.168.56.12
    User vagrant
    StrictHostKeyChecking no
EOF
chown -R vagrant:vagrant /home/vagrant/.ssh

echo "=== Récupération du mot de passe initial Jenkins ==="
echo "Jenkins initial admin password:"
sleep 30
cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Jenkins pas encore prêt, vérifiez plus tard"

echo "=== Provisioning Master terminé ==="

