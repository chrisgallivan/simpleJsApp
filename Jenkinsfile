pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                nodejs(nodeJSInstallationName: 'Node') {
                    sh 'npm install-test'
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
