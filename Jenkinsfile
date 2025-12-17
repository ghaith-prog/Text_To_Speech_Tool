pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'transcriber-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        WORKER_HOST = '192.168.56.11'
        // Les IDs de credentials doivent être configurés dans Jenkins
        // Jenkins > Credentials > Add > Secret text
        // ID: assemblyai-api-key, Secret: votre_clé_api
        // ID: db-password, Secret: votre_mot_de_passe
        ASSEMBLYAI_API_KEY = credentials('assemblyai-api-key')
        DB_PASSWORD = credentials('db-password')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Code récupéré depuis le repository"
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    echo "Construction des images Docker..."
                    sh '''
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Exécution des tests..."
                    sh '''
                        # Test de construction de l'image
                        docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} python -c "import streamlit; print('Streamlit OK')"
                        docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} python -c "import yt_dlp; print('yt-dlp OK')"
                        docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} python -c "import requests; print('Requests OK')"
                    '''
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    echo "Scan de sécurité des images..."
                    sh '''
                        # Scan basique avec docker scout (si disponible)
                        docker scout quickview ${IMAGE_NAME}:${IMAGE_TAG} || echo "Docker Scout non disponible, scan ignoré"
                    '''
                }
            }
        }
        
        stage('Deploy to Worker') {
            steps {
                script {
                    echo "Déploiement sur le serveur Worker..."
                    
                    // Utilisation d'Ansible pour le déploiement
                    sh '''
                        cd ansible
                        export ASSEMBLYAI_API_KEY=${ASSEMBLYAI_API_KEY}
                        export DB_PASSWORD=${DB_PASSWORD}
                        ansible-playbook -i inventory.ini deploy-app.yml
                    '''
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    echo "Vérification de la santé de l'application..."
                    sh '''
                        # Attendre que l'application soit prête
                        sleep 30
                        
                        # Vérifier que l'application répond
                        curl -sf http://${WORKER_HOST}:8501/_stcore/health || exit 1
                        
                        echo "Application déployée avec succès!"
                    '''
                }
            }
        }
        
        stage('Notify Monitoring') {
            steps {
                script {
                    echo "Notification au système de monitoring..."
                    sh '''
                        # Forcer une vérification Nagios
                        curl -sf http://192.168.56.12/nagios/cgi-bin/cmd.cgi?cmd_typ=7 || echo "Notification Nagios ignorée"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline terminé"
            // Nettoyage des images Docker locales anciennes
            sh '''
                docker image prune -f || true
            '''
        }
        success {
            echo "✅ Déploiement réussi!"
        }
        failure {
            echo "❌ Échec du déploiement"
            // Rollback si nécessaire
            sh '''
                ssh vagrant@${WORKER_HOST} "cd /opt/transcriber && docker-compose down && docker-compose up -d" || true
            '''
        }
    }
}

