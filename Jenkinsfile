pipeline {
    agent any

    stages {
        stage('Prepare Env') {
            steps {
                sh 'cp /host-project/.env .env'
                sh 'ls -l .env'
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker compose down'
                sh 'docker compose up --build -d'
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'sleep 5'
                sh """docker compose exec -T backend python -c "
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:8000/api/').read().decode())
" """
            }
        }
    }
}
