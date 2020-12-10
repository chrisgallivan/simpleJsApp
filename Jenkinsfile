pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                env.NODEJS_HOME = "${tool 'Node 6.x'}"
                sh 'npm install-test'

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
