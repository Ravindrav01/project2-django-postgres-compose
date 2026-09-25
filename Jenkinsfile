pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/deploy.sh'
            }
        }

        stage('Verify') {
            steps {
                sh './scripts/verify.sh'
            }
        }
    }

    post {
        success {
            echo 'Deployed! Open http://<SERVER-IP>:8000 in your browser.'
        }
        failure {
            echo 'Deployment failed. Check the console output.'
        }
    }
}
