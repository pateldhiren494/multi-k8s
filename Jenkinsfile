pipeline {
    agent any
    stages {
        stage('Clone repository') {
            checkout scm
            sh 'echo "stage 1 pulled scm"'
        }

        stage('Build image') {
            app = docker.build("pateldhiren494/multi-k8s")
            sh 'echo "stage 2 built image"'
        }

        stage('Push image') {
            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub')
            app.push("latest")
            sh 'echo "stage 3 pushed image"'
        }
    }
}
