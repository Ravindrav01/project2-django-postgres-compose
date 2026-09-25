pipeline {
    agent any
    
    environment {
        HOST_PORT = '8000'
        APP_HOST = 'host.docker.internal'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh 'chmod +x deploy/*.sh'
                sh './deploy/deploy.sh'
            }
        }

        stage('Verify') {
            steps {
                sh './deploy/verify.sh'
            }
        }
    }

    post {
        success {
            echo 'Deployed! Open http://${APP_HOST}:8000 in your browser.'
        }
        failure {
            echo 'Deployment failed. Check the console output.'
        }
    }
}
