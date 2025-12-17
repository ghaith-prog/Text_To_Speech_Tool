# 📦 Guide d'Installation Complet - De Zéro

Ce guide vous explique comment installer tous les prérequis nécessaires et configurer le projet depuis le début.

## 📋 Table des Matières

1. [Prérequis Système](#prérequis-système)
2. [Installation de Git](#installation-de-git)
3. [Installation de Docker](#installation-de-docker)
4. [Installation de Vagrant](#installation-de-vagrant)
5. [Installation de VirtualBox](#installation-de-virtualbox)
6. [Configuration du Projet](#configuration-du-projet)
7. [Lancement de l'Application](#lancement-de-lapplication)

---

## 🔍 Prérequis Système

- **OS**: Windows 10/11 (64-bit)
- **RAM**: Minimum 8 GB (recommandé 16 GB)
- **Espace disque**: Minimum 20 GB libres
- **Processeur**: Support de la virtualisation (VT-x/AMD-V)

### Vérifier la virtualisation

1. Ouvrir **Gestionnaire des tâches** (Ctrl + Shift + Esc)
2. Aller dans l'onglet **Performance**
3. Vérifier que **Virtualisation** est activée

Si désactivée, activer dans le BIOS/UEFI :
- Redémarrer → BIOS → Virtualization Technology → Enabled

---

## 1️⃣ Installation de Git

### Windows

1. **Télécharger Git**
   - Aller sur https://git-scm.com/download/win
   - Télécharger la version 64-bit

2. **Installer Git**
   - Exécuter le fichier téléchargé
   - Options recommandées :
     - ✅ Git Bash Here
     - ✅ Git GUI Here
     - ✅ Use Visual Studio Code as default editor
     - ✅ Git from the command line and also from 3rd-party software

3. **Vérifier l'installation**
   ```bash
   git --version
   # Devrait afficher: git version 2.x.x
   ```

4. **Configurer Git** (première fois)
   ```bash
   git config --global user.name "Votre Nom"
   git config --global user.email "votre.email@example.com"
   ```

---

## 2️⃣ Installation de Docker

### Windows

#### Option A : Docker Desktop (Recommandé)

1. **Télécharger Docker Desktop**
   - Aller sur https://www.docker.com/products/docker-desktop/
   - Cliquer sur "Download for Windows"

2. **Prérequis pour Docker Desktop**
   - Windows 10 64-bit : Pro, Enterprise, ou Education (Build 19041+)
   - WSL 2 activé (Windows Subsystem for Linux 2)

3. **Activer WSL 2** (si nécessaire)
   ```powershell
   # Ouvrir PowerShell en tant qu'Administrateur
   wsl --install
   # Redémarrer l'ordinateur
   ```

4. **Installer Docker Desktop**
   - Exécuter le fichier `Docker Desktop Installer.exe`
   - Cocher "Use WSL 2 instead of Hyper-V" (recommandé)
   - Redémarrer l'ordinateur si demandé

5. **Lancer Docker Desktop**
   - Chercher "Docker Desktop" dans le menu Démarrer
   - Attendre que Docker démarre (icône dans la barre des tâches)

6. **Vérifier l'installation**
   ```bash
   docker --version
   # Devrait afficher: Docker version 24.x.x
   
   docker-compose --version
   # Devrait afficher: Docker Compose version v2.x.x
   ```

#### Option B : Docker via WSL 2 (Alternative)

Si Docker Desktop ne fonctionne pas :

```bash
# Dans WSL 2 (Ubuntu)
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
```

---

## 3️⃣ Installation de VirtualBox

1. **Télécharger VirtualBox**
   - Aller sur https://www.virtualbox.org/wiki/Downloads
   - Télécharger "Windows hosts"

2. **Installer VirtualBox**
   - Exécuter le fichier téléchargé
   - Accepter les options par défaut
   - ⚠️ **Important** : Accepter l'installation des pilotes réseau (peut redémarrer)

3. **Vérifier l'installation**
   - Chercher "VirtualBox" dans le menu Démarrer
   - L'application devrait s'ouvrir

---

## 4️⃣ Installation de Vagrant

1. **Télécharger Vagrant**
   - Aller sur https://www.vagrantup.com/downloads
   - Télécharger la version Windows 64-bit

2. **Installer Vagrant**
   - Exécuter le fichier `.msi` téléchargé
   - Suivre l'assistant d'installation
   - Redémarrer le terminal/PowerShell après installation

3. **Vérifier l'installation**
   ```bash
   vagrant --version
   # Devrait afficher: Vagrant 2.x.x
   ```

4. **Installer le plugin VirtualBox pour Vagrant**
   ```bash
   vagrant plugin install vagrant-vbguest
   ```

---

## 5️⃣ Configuration du Projet

### Étape 1 : Cloner ou préparer le projet

```bash
# Si le projet est dans un repository Git
git clone <url-du-repository>
cd "STT transcription"

# Sinon, vous êtes déjà dans le dossier du projet
```

### Étape 2 : Créer les fichiers de secrets

```bash
# Créer le dossier des secrets
mkdir .secrets

# Créer le fichier de clé API AssemblyAI
echo "6357e44296c5466584d2e624eb802261" > .secrets/assemblyai_key.txt

# Créer le fichier de mot de passe PostgreSQL
echo "m_db" > .secrets/db_password.txt

# Créer le fichier secrets.toml pour Streamlit
mkdir .streamlit
echo 'api_key = "6357e44296c5466584d2e624eb802261"' > .streamlit/secrets.toml
```

**Ou manuellement :**

1. Créer le dossier `.secrets` à la racine du projet
2. Créer `assemblyai_key.txt` avec votre clé API
3. Créer `db_password.txt` avec un mot de passe sécurisé
4. Créer `.streamlit/secrets.toml` avec :
   ```toml
   api_key = "6357e44296c5466584d2e624eb802261"
   ```

### Étape 3 : Vérifier les fichiers

Votre structure devrait ressembler à :
```
STT transcription/
├── .secrets/
│   ├── assemblyai_key.txt
│   └── db_password.txt
├── .streamlit/
│   └── secrets.toml
├── app.py
├── Dockerfile
├── docker-compose.yml
├── Vagrantfile
└── ...
```

---

## 6️⃣ Lancement de l'Application

### Option A : Avec Docker Compose (Sans VMs - Plus Simple)

Cette option lance l'application directement sur votre machine sans créer de VMs.

```bash
# 1. Construire les images Docker
docker-compose build

# 2. Démarrer les conteneurs
docker-compose up -d

# 3. Voir les logs
docker-compose logs -f

# 4. Accéder à l'application
# Ouvrir http://localhost:8501 dans votre navigateur
```

**Arrêter l'application :**
```bash
docker-compose down
```

### Option B : Avec Vagrant (Infrastructure Complète)

Cette option crée 3 machines virtuelles avec Jenkins, Nagios, etc.

```bash
# 1. Lancer toutes les VMs (première fois - peut prendre 15-30 min)
vagrant up

# 2. Vérifier le statut des VMs
vagrant status

# 3. Accéder aux services :
# - Application: http://localhost:8501
# - Jenkins: http://localhost:8080
# - Nagios: http://localhost:8888/nagios
```

**Commandes Vagrant utiles :**
```bash
vagrant up              # Démarrer toutes les VMs
vagrant halt            # Arrêter toutes les VMs
vagrant destroy -f      # Supprimer toutes les VMs
vagrant ssh master      # Se connecter à la VM master
vagrant ssh worker      # Se connecter à la VM worker
vagrant provision       # Re-exécuter les scripts de provisioning
```

---

## 7️⃣ Vérification et Tests

### Vérifier Docker
```bash
docker ps
# Devrait afficher les conteneurs en cours d'exécution
```

### Vérifier Vagrant
```bash
vagrant status
# Devrait afficher l'état des VMs
```

### Tester l'application
1. Ouvrir http://localhost:8501
2. Entrer une URL YouTube dans la sidebar
3. Cliquer sur "Go"
4. Attendre la transcription

---

## 🐛 Résolution de Problèmes

### Problème : Docker ne démarre pas

**Solution 1 : Vérifier WSL 2**
```powershell
wsl --status
# Si WSL 1, mettre à jour :
wsl --update
wsl --set-default-version 2
```

**Solution 2 : Redémarrer Docker Desktop**
- Clic droit sur l'icône Docker → Restart

### Problème : Vagrant ne trouve pas VirtualBox

**Solution :**
```bash
# Vérifier que VirtualBox est installé
# Réinstaller le plugin Vagrant
vagrant plugin uninstall vagrant-vbguest
vagrant plugin install vagrant-vbguest
```

### Problème : Erreur de permissions Docker

**Solution Windows :**
- S'assurer que Docker Desktop est lancé
- Vérifier que vous êtes dans le groupe "docker-users"

### Problème : Ports déjà utilisés

**Solution :**
```bash
# Vérifier les ports utilisés
netstat -ano | findstr :8501
netstat -ano | findstr :8080

# Modifier les ports dans docker-compose.yml ou Vagrantfile si nécessaire
```

### Problème : VM Vagrant ne démarre pas

**Solution :**
```bash
# Vérifier la virtualisation dans le BIOS
# Désactiver Hyper-V si VirtualBox ne fonctionne pas :
# PowerShell (Admin) : Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

---

## 📚 Ressources Supplémentaires

- **Documentation Docker** : https://docs.docker.com/
- **Documentation Vagrant** : https://www.vagrantup.com/docs
- **Documentation VirtualBox** : https://www.virtualbox.org/manual/
- **Documentation Streamlit** : https://docs.streamlit.io/

---

## ✅ Checklist d'Installation

Cochez chaque étape au fur et à mesure :

- [ ] Git installé et configuré
- [ ] Docker Desktop installé et fonctionnel
- [ ] VirtualBox installé
- [ ] Vagrant installé
- [ ] Plugin vagrant-vbguest installé
- [ ] Fichiers de secrets créés (.secrets/ et .streamlit/)
- [ ] Application testée avec Docker Compose
- [ ] VMs Vagrant créées et fonctionnelles (optionnel)

---

## 🎉 Félicitations !

Votre environnement est maintenant prêt. Vous pouvez :
- Développer l'application localement
- Tester avec Docker Compose
- Déployer sur l'infrastructure complète avec Vagrant
- Utiliser le pipeline Jenkins pour CI/CD

Pour toute question, consultez le [README.md](README.md) principal.

