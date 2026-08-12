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
                // No --profile dev: the Vite dev server is not part of production.
                sh 'docker compose up --build -d'
            }
        }

        stage('Build Admin Panel') {
            steps {
                // nginx serves admin-panel/dist, which is gitignored and does
                // not rebuild on its own -- without this the panel drifts behind
                // the source (it once shipped a build predating the auth fix).
                sh 'docker compose run --rm --no-deps admin-panel sh -c "npm ci && npm run build"'
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
                sh 'docker compose exec -T backend python manage.py migrate'
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

