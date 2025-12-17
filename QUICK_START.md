# 🚀 Guide de Démarrage Rapide

Guide simplifié pour démarrer rapidement l'application.

## ⚡ Démarrage Ultra-Rapide (5 minutes)

### Si vous avez déjà Docker installé :

```bash
# 1. Créer les secrets
mkdir .secrets
echo "6357e44296c5466584d2e624eb802261" > .secrets/assemblyai_key.txt
echo "m_db" > .secrets/db_password.txt

mkdir .streamlit
echo 'api_key = "6357e44296c5466584d2e624eb802261"' > .streamlit/secrets.toml

# 2. Lancer l'application
docker-compose up -d

# 3. Ouvrir http://localhost:8501
```

### Si vous n'avez RIEN installé :

#### Windows (PowerShell en Admin) :

```powershell
# Exécuter le script d'installation automatique
.\scripts\install-windows.ps1
```

Puis suivre les instructions à l'écran.

#### Installation manuelle :

1. **Installer Docker Desktop** : https://www.docker.com/products/docker-desktop/
2. **Installer Git** : https://git-scm.com/download/win
3. **Créer les secrets** (voir ci-dessus)
4. **Lancer** : `docker-compose up -d`

---

## 📝 Étapes Détaillées

### Étape 1 : Installer Docker Desktop

1. Télécharger : https://www.docker.com/products/docker-desktop/
2. Installer et redémarrer
3. Lancer Docker Desktop
4. Attendre que l'icône soit verte dans la barre des tâches

### Étape 2 : Préparer les secrets

```bash
# Créer les dossiers
mkdir .secrets
mkdir .streamlit

# Créer les fichiers de secrets
echo "6357e44296c5466584d2e624eb802261" > .secrets/assemblyai_key.txt
echo "m_db" > .secrets/db_password.txt
echo 'api_key = "6357e44296c5466584d2e624eb802261"' > .streamlit/secrets.toml
```

### Étape 3 : Lancer l'application

```bash
# Construire et démarrer
docker-compose up -d

# Voir les logs
docker-compose logs -f transcriber-app

# Arrêter
docker-compose down
```

### Étape 4 : Utiliser l'application

1. Ouvrir http://localhost:8501
2. Entrer une URL YouTube dans la sidebar
3. Cliquer sur "Go"
4. Attendre la transcription

---

## 🔧 Commandes Utiles

```bash
# Voir les conteneurs en cours
docker ps

# Voir les logs
docker-compose logs -f

# Redémarrer l'application
docker-compose restart

# Reconstruire les images
docker-compose build --no-cache

# Nettoyer
docker-compose down -v
docker system prune -a
```

---

## ❓ Problèmes Courants

### Docker ne démarre pas
→ Vérifier que WSL 2 est installé : `wsl --status`

### Port 8501 déjà utilisé
→ Changer le port dans `docker-compose.yml` :
```yaml
ports:
  - "8502:8501"  # Utiliser 8502 au lieu de 8501
```

### Erreur de permissions
→ Lancer PowerShell en tant qu'Administrateur

---

## 📚 Documentation Complète

Pour plus de détails, voir :
- [INSTALLATION.md](INSTALLATION.md) - Guide d'installation complet
- [README.md](README.md) - Documentation principale

