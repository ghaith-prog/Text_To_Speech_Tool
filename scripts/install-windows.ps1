# Script PowerShell d'installation automatique pour Windows
# Exécuter en tant qu'Administrateur : PowerShell (Admin)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation Automatique - Transcriber App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si exécuté en tant qu'Administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERREUR: Ce script doit être exécuté en tant qu'Administrateur!" -ForegroundColor Red
    Write-Host "Clic droit sur PowerShell -> Exécuter en tant qu'administrateur" -ForegroundColor Yellow
    exit 1
}

# Fonction pour vérifier si une commande existe
function Test-Command {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# 1. Vérifier/Installer Git
Write-Host "[1/5] Vérification de Git..." -ForegroundColor Yellow
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host "  ✓ Git déjà installé: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "  ✗ Git non trouvé. Installation requise." -ForegroundColor Red
    Write-Host "  Téléchargez depuis: https://git-scm.com/download/win" -ForegroundColor Yellow
    $install = Read-Host "  Voulez-vous ouvrir la page de téléchargement? (O/N)"
    if ($install -eq "O" -or $install -eq "o") {
        Start-Process "https://git-scm.com/download/win"
    }
}

# 2. Vérifier/Installer Docker
Write-Host ""
Write-Host "[2/5] Vérification de Docker..." -ForegroundColor Yellow
if (Test-Command "docker") {
    $dockerVersion = docker --version
    Write-Host "  ✓ Docker déjà installé: $dockerVersion" -ForegroundColor Green
    
    # Vérifier si Docker Desktop est en cours d'exécution
    $dockerRunning = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠ Docker n'est pas en cours d'exécution" -ForegroundColor Yellow
        Write-Host "  Démarrez Docker Desktop depuis le menu Démarrer" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Docker est en cours d'exécution" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ Docker non trouvé. Installation requise." -ForegroundColor Red
    Write-Host "  Téléchargez Docker Desktop depuis: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    $install = Read-Host "  Voulez-vous ouvrir la page de téléchargement? (O/N)"
    if ($install -eq "O" -or $install -eq "o") {
        Start-Process "https://www.docker.com/products/docker-desktop/"
    }
}

# 3. Vérifier WSL 2 (requis pour Docker Desktop)
Write-Host ""
Write-Host "[3/5] Vérification de WSL 2..." -ForegroundColor Yellow
$wslStatus = wsl --status 2>&1
if ($wslStatus -like "*WSL 2*") {
    Write-Host "  ✓ WSL 2 est installé et configuré" -ForegroundColor Green
} else {
    Write-Host "  ⚠ WSL 2 n'est pas configuré" -ForegroundColor Yellow
    $installWsl = Read-Host "  Voulez-vous installer WSL 2 maintenant? (O/N)"
    if ($installWsl -eq "O" -or $installWsl -eq "o") {
        Write-Host "  Installation de WSL 2..." -ForegroundColor Yellow
        wsl --install
        Write-Host "  ⚠ Redémarrez votre ordinateur après l'installation" -ForegroundColor Yellow
    }
}

# 4. Vérifier/Installer VirtualBox
Write-Host ""
Write-Host "[4/5] Vérification de VirtualBox..." -ForegroundColor Yellow
$vboxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
if (Test-Path $vboxPath) {
    Write-Host "  ✓ VirtualBox est installé" -ForegroundColor Green
} else {
    Write-Host "  ✗ VirtualBox non trouvé. Installation requise." -ForegroundColor Red
    Write-Host "  Téléchargez depuis: https://www.virtualbox.org/wiki/Downloads" -ForegroundColor Yellow
    $install = Read-Host "  Voulez-vous ouvrir la page de téléchargement? (O/N)"
    if ($install -eq "O" -or $install -eq "o") {
        Start-Process "https://www.virtualbox.org/wiki/Downloads"
    }
}

# 5. Vérifier/Installer Vagrant
Write-Host ""
Write-Host "[5/5] Vérification de Vagrant..." -ForegroundColor Yellow
if (Test-Command "vagrant") {
    $vagrantVersion = vagrant --version
    Write-Host "  ✓ Vagrant déjà installé: $vagrantVersion" -ForegroundColor Green
    
    # Vérifier le plugin vbguest
    $plugins = vagrant plugin list
    if ($plugins -like "*vagrant-vbguest*") {
        Write-Host "  ✓ Plugin vagrant-vbguest installé" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Plugin vagrant-vbguest non installé" -ForegroundColor Yellow
        $installPlugin = Read-Host "  Voulez-vous installer le plugin maintenant? (O/N)"
        if ($installPlugin -eq "O" -or $installPlugin -eq "o") {
            vagrant plugin install vagrant-vbguest
        }
    }
} else {
    Write-Host "  ✗ Vagrant non trouvé. Installation requise." -ForegroundColor Red
    Write-Host "  Téléchargez depuis: https://www.vagrantup.com/downloads" -ForegroundColor Yellow
    $install = Read-Host "  Voulez-vous ouvrir la page de téléchargement? (O/N)"
    if ($install -eq "O" -or $install -eq "o") {
        Start-Process "https://www.vagrantup.com/downloads"
    }
}

# 6. Créer les fichiers de configuration
Write-Host ""
Write-Host "[Configuration] Création des fichiers de secrets..." -ForegroundColor Yellow

$projectPath = $PSScriptRoot + "\.."
Set-Location $projectPath

# Créer .secrets
if (-not (Test-Path ".secrets")) {
    New-Item -ItemType Directory -Path ".secrets" | Out-Null
    Write-Host "  ✓ Dossier .secrets créé" -ForegroundColor Green
}

# Créer assemblyai_key.txt
if (-not (Test-Path ".secrets\assemblyai_key.txt")) {
    "6357e44296c5466584d2e624eb802261" | Out-File -FilePath ".secrets\assemblyai_key.txt" -Encoding UTF8
    Write-Host "  ✓ Fichier assemblyai_key.txt créé" -ForegroundColor Green
}

# Créer db_password.txt
if (-not (Test-Path ".secrets\db_password.txt")) {
    "m_db" | Out-File -FilePath ".secrets\db_password.txt" -Encoding UTF8
    Write-Host "  ✓ Fichier db_password.txt créé" -ForegroundColor Green
}

# Créer .streamlit
if (-not (Test-Path ".streamlit")) {
    New-Item -ItemType Directory -Path ".streamlit" | Out-Null
    Write-Host "  ✓ Dossier .streamlit créé" -ForegroundColor Green
}

# Créer secrets.toml
if (-not (Test-Path ".streamlit\secrets.toml")) {
    @"
api_key = "6357e44296c5466584d2e624eb802261"
"@ | Out-File -FilePath ".streamlit\secrets.toml" -Encoding UTF8
    Write-Host "  ✓ Fichier secrets.toml créé" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation terminée!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "  1. Si WSL 2 a été installé, redémarrez votre ordinateur" -ForegroundColor White
Write-Host "  2. Assurez-vous que Docker Desktop est en cours d'exécution" -ForegroundColor White
Write-Host "  3. Pour lancer l'application:" -ForegroundColor White
Write-Host "     docker-compose up -d" -ForegroundColor Cyan
Write-Host "  4. Accéder à l'application: http://localhost:8501" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour l'infrastructure complète avec Vagrant:" -ForegroundColor Yellow
Write-Host "  vagrant up" -ForegroundColor Cyan
Write-Host ""

