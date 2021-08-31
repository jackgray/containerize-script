pipeline {
    agent {
        label '!docker'
        docker { image 'docker' }
    }
    stages {
        stage('Setup') {
            steps {
                sh 'echo "This is the setup stage"'
            }
        }
    }
}
post {
    always {
        echo 'This will always run'
    }
    success {
        echo 'This will run only if successful'
    }
}