pipeline {
    agent none 

    environment {
        IMAGE='liatrio/jira'
        SLACK_CHANNEL="flywheel"
        APP_DOMAIN='liatr.io'
        URL='docker.artifactory'
    }
    stages {
        stage('Build image') {
            agent { dockerfile true }
            steps {
                sh "docker build --pull -t ${IMAGE}:${GIT_COMMIT[0..10]} -t ${IMAGE}:latest ."
            }
        }
        stage('Publish image') {
            when { 
                branch 'master'
            }
            agent { 
                docker { 
                    image 'docker:18.09' 
                    args  '--privileged	-u 0 -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                    withCredentials([usernamePassword(credentialsId: 'artifactory', passwordVariable: 'artifactoryPass', usernameVariable: 'artifactoryUser')]) {
                    sh "docker login -u ${env.dockerUsername} -p ${env.dockerPassword} ${URL}.${APP_DOMAIN}"
                    sh "docker push ${URL}.${APP_DOMAIN}/${IMAGE}:${GIT_COMMIT[0..10]}"
                    sh "docker push ${URL}.${APP_DOMAIN}/${IMAGE}:latest"
                }
            }
        }
    }
    post {
        failure {
            slackSend channel: "#${env.SLACK_CHANNEL}",  color: "danger", message: "Build failed: ${env.JOB_NAME} on build #${env.BUILD_NUMBER} (<${env.BUILD_URL}|go there>)"
        }
        fixed {
            slackSend channel: "#${env.SLACK_CHANNEL}", color: "good",  message: "Build recovered: ${env.JOB_NAME} on #${env.BUILD_NUMBER}"
        }
    }
}