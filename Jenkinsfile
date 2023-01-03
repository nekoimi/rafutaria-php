#!groovy

node {
    stage('CleanWs') {
        cleanWs()
    }

    stage('Checkout') {
        checkout scm
    }

    stage('node') {
        sh "docker build -t test -f ./8/fpm/Dockerfile ."
    }
}
