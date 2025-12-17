# 🔧 Configuration Jenkins

Guide pour configurer Jenkins et les credentials nécessaires au pipeline.

## 📋 Prérequis

- Jenkins installé et accessible (http://localhost:8080 après `vagrant up`)
- Accès administrateur à Jenkins

## 🔐 Configuration des Credentials

### Étape 1 : Accéder à Jenkins

1. Ouvrir http://localhost:8080
2. Récupérer le mot de passe initial :
   ```bash
   vagrant ssh master
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Se connecter avec `admin` et le mot de passe récupéré

### Étape 2 : Créer les Credentials

#### Credential 1 : Clé API AssemblyAI

1. Aller dans **Jenkins** → **Manage Jenkins** → **Credentials**
2. Cliquer sur **(global)** → **Add Credentials**
3. Remplir :
   - **Kind** : Secret text
   - **Secret** : `6357e44296c5466584d2e624eb802261`
   - **ID** : `assemblyai-api-key` ⚠️ **Important : exactement ce nom**
   - **Description** : AssemblyAI API Key
4. Cliquer sur **OK**

#### Credential 2 : Mot de passe PostgreSQL

1. Dans **Credentials**, cliquer sur **Add Credentials**
2. Remplir :
   - **Kind** : Secret text
   - **Secret** : `m_db` (ou votre mot de passe)
   - **ID** : `db-password` ⚠️ **Important : exactement ce nom**
   - **Description** : PostgreSQL Database Password
3. Cliquer sur **OK**

### Étape 3 : Vérifier les Credentials

Les credentials devraient apparaître dans la liste :
- ✅ `assemblyai-api-key`
- ✅ `db-password`

## 🚀 Créer le Pipeline

### Option A : Pipeline depuis un Repository Git

1. **Nouveau Job**
   - Jenkins → **New Item**
   - Nom : `transcriber-pipeline`
   - Type : **Pipeline**
   - Cliquer sur **OK**

2. **Configuration**
   - Dans **Pipeline**, section **Definition** :
     - **Definition** : Pipeline script from SCM
     - **SCM** : Git
     - **Repository URL** : URL de votre repository (ou chemin local)
     - **Script Path** : `Jenkinsfile`
   - Cliquer sur **Save**

3. **Lancer le Pipeline**
   - Cliquer sur **Build Now**
   - Voir les logs dans **Console Output**

### Option B : Pipeline depuis le Jenkinsfile local

1. **Nouveau Job**
   - Jenkins → **New Item**
   - Nom : `transcriber-pipeline`
   - Type : **Pipeline**
   - Cliquer sur **OK**

2. **Configuration**
   - Dans **Pipeline**, section **Definition** :
     - **Definition** : Pipeline script
     - Coller le contenu du `Jenkinsfile`
   - Cliquer sur **Save**

3. **Lancer le Pipeline**
   - Cliquer sur **Build Now**

## 🔍 Vérification

### Vérifier que les credentials sont utilisés

Dans les logs du pipeline, vous devriez voir :
```
[Pipeline] withCredentials
Masking supported pattern matches of $ASSEMBLYAI_API_KEY or $DB_PASSWORD
```

Les valeurs ne seront **pas** affichées en clair (sécurité).

### Tester manuellement

```bash
# Se connecter à la VM master
vagrant ssh master

# Vérifier que Docker fonctionne
docker ps

# Vérifier que Ansible est installé
ansible --version

# Tester la connexion au worker
ssh vagrant@192.168.56.11 "docker ps"
```

## 🐛 Résolution de Problèmes

### Erreur : "Credentials not found"

**Solution :**
- Vérifier que les IDs sont exactement : `assemblyai-api-key` et `db-password`
- Vérifier que les credentials sont dans le scope **Global**

### Erreur : "Cannot connect to worker"

**Solution :**
```bash
# Sur la VM master, configurer SSH
vagrant ssh master
ssh-keygen -t rsa -b 4096
ssh-copy-id vagrant@192.168.56.11
```

### Erreur : "Ansible not found"

**Solution :**
```bash
vagrant ssh master
sudo pip3 install ansible
```

### Erreur : "Docker permission denied"

**Solution :**
```bash
vagrant ssh master
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## 📝 Structure des Credentials dans Jenkinsfile

```groovy
environment {
    // credentials('ID') récupère le credential avec cet ID
    ASSEMBLYAI_API_KEY = credentials('assemblyai-api-key')
    DB_PASSWORD = credentials('db-password')
}
```

⚠️ **Important** : Les IDs dans `credentials()` doivent correspondre **exactement** aux IDs créés dans Jenkins.

## ✅ Checklist

- [ ] Jenkins accessible sur http://localhost:8080
- [ ] Credential `assemblyai-api-key` créé
- [ ] Credential `db-password` créé
- [ ] Pipeline créé et configuré
- [ ] Premier build réussi
- [ ] Application déployée sur le worker

## 🔗 Ressources

- [Documentation Jenkins Credentials](https://www.jenkins.io/doc/book/using/using-credentials/)
- [Documentation Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)

