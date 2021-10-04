pipeline {
    agent any
    stages {
        stage('clone') {
            steps {
                checkout scm
                echo "stage 1 pulled scm"
            }
        }

        stage('build') {
            steps {
                sh "docker build -t pateldhiren494/multi-client ./client"
            }
        }
    }
}