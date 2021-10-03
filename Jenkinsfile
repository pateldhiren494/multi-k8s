node {
    def app

    stage('Initialize'){
        def dockerHome = tool 'myDocker'
        env.PATH = "${dockerHome}/bin:${env.PATH}"
    }

    stage('Clone repository') {
        checkout scm
    }

    stage('Build image') {
        app = docker.build("pateldhiren494/multi-client", "./client")
    }

    /*stage('Test image') {
        app.inside {
            sh 'echo "Tests passed"'
        }
    }*/

    /*stage('Push image') {
        docker.withRegistry('https://registry.hub.docker.com', 'git') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }*/
}