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
                sh 'curl -f http://127.0.0.1:8000/api/'
            }
        }
    }
}
