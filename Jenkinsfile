// Jenkinsfile
// CodeAlpha DevOps Internship - Task 2: Jenkins Remoting
// Demonstrates: remote agent execution, label-based architecture targeting,
// and Docker-based node isolation.

pipeline {
    agent none

    stages {

        stage('Build on x86 Agent') {
            agent { label 'linux-x86' }
            steps {
                echo "Running on x86 remote agent"
                sh 'uname -m'
                sh 'echo "Build step running on remote node..."'
                // sh 'make build'   // replace with your real build command
            }
        }

        stage('Build on ARM64 Agent') {
            agent { label 'arm64-node' }
            steps {
                echo "Running on ARM64 remote agent"
                sh 'uname -m'
                sh 'echo "Build step running on remote node..."'
            }
        }

        stage('Isolated Build (Docker Agent)') {
            agent {
                docker {
                    image 'node:18-slim'
                    label 'docker-agent'
                    args '--rm'
                }
            }
            steps {
                echo "Running inside an isolated, ephemeral Docker container"
                sh 'node --version'
                sh 'npm --version'
                // sh 'npm install && npm run build'
            }
        }

        stage('Report') {
            agent { label 'linux-x86' }
            steps {
                echo "All remote builds completed successfully."
            }
        }
    }

    post {
        success {
            echo 'Pipeline finished successfully across all remote nodes.'
        }
        failure {
            echo 'Pipeline failed - check the logs of the specific agent stage.'
        }
    }
}
