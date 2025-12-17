# 📝 Transcriber App - Projet DevOps Conteneurisé

Application web de transcription de vidéos YouTube utilisant l'IA (AssemblyAI), conteneurisée avec Docker et déployée via un pipeline CI/CD complet.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        INFRASTRUCTURE DEVOPS                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │
│  │   VM MASTER     │    │   VM WORKER     │    │  VM MONITORING  │     │
│  │  192.168.56.10  │    │  192.168.56.11  │    │  192.168.56.12  │     │
│  ├─────────────────┤    ├─────────────────┤    ├─────────────────┤     │
│  │                 │    │                 │    │                 │     │
│  │  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │     │
│  │  │  Jenkins  │  │───▶│  │  Docker   │  │◀───│  │  Nagios   │  │     │
│  │  │  :8080    │  │    │  │  Compose  │  │    │  │   :80     │  │     │
│  │  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │     │
│  │                 │    │       │         │    │                 │     │
│  │  ┌───────────┐  │    │  ┌────┴────┐    │    └─────────────────┘     │
│  │  │  Ansible  │  │    │  │         │    │                            │
│  │  └───────────┘  │    │  ▼         ▼    │                            │
│  │                 │    │┌─────┐ ┌──────┐ │                            │
│  └─────────────────┘    ││App  │ │Nginx │ │                            │
│                         ││:8501│ │ :80  │ │                            │
│                         │└─────┘ └──────┘ │                            │
│                         │     │           │                            │
│                         │     ▼           │                            │
│                         │ ┌────────┐      │                            │
│                         │ │PostgreSQL     │                            │
│                         │ │  :5432 │      │                            │
│                         │ └────────┘      │                            │
│                         └─────────────────┘                            │
└─────────────────────────────────────────────────────────────────────────┘
```

## 📦 Composants

| Composant | Technologie | Description |
|-----------|-------------|-------------|
| **Frontend/Backend** | Streamlit (Python) | Interface web + logique serveur |
| **IA** | AssemblyAI API | Transcription audio via ML |
| **Base de données** | PostgreSQL | Stockage des transcriptions |
| **Reverse Proxy** | Nginx | Load balancing et SSL |
| **Conteneurisation** | Docker + Docker Compose | Isolation des services |
| **CI/CD** | Jenkins | Pipeline automatisé |
| **Provisioning** | Vagrant + Ansible/Bash | Infrastructure as Code |
| **Monitoring** | Nagios | Surveillance de l'infrastructure |

## 🚀 Démarrage Rapide

### ⚡ Installation Rapide (5 minutes)

**Si vous n'avez rien installé**, suivez le [Guide de Démarrage Rapide](QUICK_START.md)

**Pour une installation complète étape par étape**, consultez le [Guide d'Installation Complet](INSTALLATION.md)

### Prérequis
- VirtualBox 6.1+ (pour l'infrastructure complète)
- Vagrant 2.3+ (pour l'infrastructure complète)
- Docker Desktop (pour l'application seule)
- Git

### 1. Cloner le projet
```bash
git clone <repository-url>
cd STT-transcription
```

### 2. Configurer les secrets
```bash
mkdir -p .secrets
echo "VOTRE_CLE_ASSEMBLYAI" > .secrets/assemblyai_key.txt
echo "motdepasse_db" > .secrets/db_password.txt
cp .streamlit/secrets.toml.example .streamlit/secrets.toml
# Éditer .streamlit/secrets.toml avec votre clé API
```

### 3. Lancer l'infrastructure
```bash
vagrant up
```

### 4. Accéder aux services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Application** | http://localhost:8501 | - |
| **Jenkins** | http://localhost:8080 | admin / (voir console) |
| **Nagios** | http://localhost:8888/nagios | nagiosadmin / nagiosadmin |
| **PostgreSQL** | localhost:5433 | transcriber_user / (voir secrets) |

## 🔧 Développement Local (sans VMs)

```bash
# Créer les secrets
mkdir -p .secrets
echo "VOTRE_CLE_API" > .secrets/assemblyai_key.txt
echo "password123" > .secrets/db_password.txt

# Lancer avec Docker Compose
docker-compose up --build
```

## 📋 Pipeline CI/CD

> 📖 **Configuration Jenkins** : Consultez [JENKINS_SETUP.md](JENKINS_SETUP.md) pour configurer les credentials et créer le pipeline.

Le pipeline Jenkins exécute automatiquement:

1. **Checkout** - Récupération du code source
2. **Build** - Construction des images Docker
3. **Test** - Tests unitaires et d'intégration
4. **Security Scan** - Analyse de vulnérabilités
5. **Deploy** - Déploiement via Ansible
6. **Health Check** - Vérification de l'application
7. **Notify** - Notification au monitoring

## 📊 Monitoring Nagios

Services surveillés:
- ✅ État de l'application Streamlit
- ✅ Service Docker
- ✅ Base de données PostgreSQL
- ✅ Utilisation disque
- ✅ Charge CPU
- ✅ Service Jenkins

## 📁 Structure du Projet

```
STT-transcription/
├── app.py                    # Application Streamlit principale
├── requirements.txt          # Dépendances Python
├── Dockerfile               # Image Docker de l'application
├── docker-compose.yml       # Orchestration des conteneurs
├── Vagrantfile              # Configuration des VMs
├── Jenkinsfile              # Pipeline CI/CD
├── init-db.sql              # Initialisation PostgreSQL
├── .gitignore
├── README.md
├── .streamlit/
│   ├── config.toml          # Configuration Streamlit
│   └── secrets.toml.example # Template des secrets
├── nginx/
│   └── nginx.conf           # Configuration reverse proxy
├── scripts/
│   ├── provision-master.sh  # Setup VM Master
│   ├── provision-worker.sh  # Setup VM Worker
│   └── provision-monitoring.sh # Setup VM Nagios
└── ansible/
    ├── inventory.ini        # Inventaire des hôtes
    └── deploy-app.yml       # Playbook de déploiement
```

## 🔐 Sécurité

- Secrets stockés dans des fichiers séparés (non versionnés)
- Communications inter-conteneurs via réseau Docker isolé
- HTTPS disponible via Nginx (certificats à configurer)
- Accès base de données restreint au réseau interne

## 📝 Commandes Utiles

```bash
# Vagrant
vagrant up              # Démarrer toutes les VMs
vagrant halt            # Arrêter les VMs
vagrant destroy -f      # Supprimer les VMs
vagrant ssh master      # Se connecter à la VM master

# Docker
docker-compose logs -f  # Voir les logs
docker-compose restart  # Redémarrer les services
docker-compose down     # Arrêter les conteneurs

# Ansible (depuis master)
ansible-playbook -i ansible/inventory.ini ansible/deploy-app.yml
```

## 👥 Auteur

Projet DevOps - Application de transcription IA conteneurisée

## 📄 Licence

MIT License

