pipeline {
    agent any
    stages {
        stage('Clone repository') {
            steps{
                checkout scm
                echo "stage 1 pulled scm"
            }
        }

        stage('Build image') {
            steps {
                app = docker.build("pateldhiren494/multi-k8s")
                echo "stage 2 built image"
            }
        }

        stage('Push image') {
            steps {
                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                    app.push("latest")
                }
                echo "stage 3 pushed image"
            }
        }
    }
}
