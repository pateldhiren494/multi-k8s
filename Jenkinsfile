pipeline {
    agent any
    stages {
        stage('Clone repository') {
            steps{
                checkout scm
                echo "testing webhook"
                echo "stage 1 pulled scm"
            }
        }

        stage('Build image') {
            steps {
                //app = docker.build("pateldhiren494/multi-k8s")
                echo "stage 2 build image"
                sh '''
                    docker image build -t pateldhiren494/multi-client ./client
                '''
            }
        }

        stage('Push image') {
            steps {
                //docker.withRegistry('https://registry.hub.docker.com', 'dockerhub')
                //app.push("latest")
                echo "stage 3 pushed image"
            }
        }
    }
}
