pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'petabait'
        IMAGE_NAME     = "${DOCKERHUB_USER}/spring-petclinic"
        IMAGE_TAG      = "${GIT_COMMIT[0..6]}"
        GITOPS_REPO    = 'https://github.com/bohdan-ihnatenko/project-x.git'
        VALUES_FILE    = 'helm/petclinic/values.yaml'
    }

    stages {
        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }

        stage('Build') {
            steps {
                sh './mvnw package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    """
                }
            }
        }

        stage('Update Helm Values') {
            steps {
                withCredentials([string(
                    credentialsId: 'github-token',
                    variable: 'GH_TOKEN'
                )]) {
                    sh """
                        git clone https://\$GH_TOKEN@github.com/bohdan-ihnatenko/project-x.git gitops
                        cd gitops
                        sed -i 's|tag: .*|tag: "${IMAGE_TAG}"|' ${VALUES_FILE}
                        git config user.email "ci@jenkins"
                        git config user.name "Jenkins CI"
                        git add ${VALUES_FILE}
                        git commit -m "ci: update petclinic image tag to ${IMAGE_TAG}"
                        git push
                        cd ..
                        rm -rf gitops
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}