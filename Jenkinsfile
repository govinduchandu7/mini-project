pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['staging', 'production'],
            description: 'Target environment'
        )

        booleanParam(
            name: 'RUN_DEPLOYMENT',
            defaultValue: true,
            description: 'Deploy after build'
        )
    }

    environment {
        WEB_SERVER = '192.168.1.30'
        DEPLOY_USER = 'sysadmin'
        PACKAGE_NAME = "famm-portal-${BUILD_NUMBER}.tar.gz"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-pat',
                    url: 'https://github.com/YOUR-USER/famm-training-portal.git'
            }
        }

        stage('Build Information') {
            steps {
                sh 'echo "Build $BUILD_NUMBER → $DEPLOY_ENV"'
                sh 'git log -1 --oneline'
            }
        }

        stage('Validate') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/validate.sh'
            }
        }

        stage('Package') {
            steps {
                sh 'tar -czf "$PACKAGE_NAME" -C website .'

                archiveArtifacts(
                    artifacts: '*.tar.gz',
                    fingerprint: true
                )
            }
        }

        stage('Deploy') {
            when {
                expression {
                    params.RUN_DEPLOYMENT
                }
            }

            steps {
                sshagent(credentials: ['linux-web-server-ssh']) {
                    sh '''
                        mkdir -p ~/.ssh
                        ssh-keyscan -H "$WEB_SERVER" >> ~/.ssh/known_hosts

                        scp "$PACKAGE_NAME" scripts/deploy.sh \
                            "$DEPLOY_USER@$WEB_SERVER:/tmp/"

                        ssh "$DEPLOY_USER@$WEB_SERVER" \
                            "chmod +x /tmp/deploy.sh && /tmp/deploy.sh /tmp/$PACKAGE_NAME"
                    '''
                }
            }
        }

        stage('Remote Health Check') {
            when {
                expression {
                    params.RUN_DEPLOYMENT
                }
            }

            steps {
                sh 'curl --fail --retry 3 "http://$WEB_SERVER/"'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Review the first failed stage.'
        }

        always {
            cleanWs()
        }
    }
}
