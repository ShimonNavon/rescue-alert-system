pipeline {
    agent any

    stages {
        stage('Prepare Env') {
            steps {
                sh 'cp /host-project/.env .env'
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker compose down'
                sh 'docker compose up --build -d'
            }
        }

        stage('Wait for Backend') {
            steps {
                sh 'sleep 10'
                sh 'docker compose ps'
            }
        }

        stage('Migrate DB') {
            steps {
                sh 'docker compose exec -T backend python backend/manage.py migrate'
            }
        }

        stage('Smoke Test') {
            steps {
                sh """docker compose exec -T backend python -c "
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:8000/api/').read().decode())
" """
            }
        }
    }
}

