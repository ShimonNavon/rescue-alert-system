pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ShimonNavon/rescue-alert-system.git'
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
