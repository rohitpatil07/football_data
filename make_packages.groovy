pipeline {
    // agent { label "slave1" }
    agent any

    environment {
        LOCAL_FOLDER = '/home/rohit/Desktop/aws/terraform/football_app/backend'
    }

    stages {

        stage("Clean Workspace"){
            steps {
                cleanWs()
            }
        }

        stage("Clone Repo") {
            steps {
                script {
                    echo "Currently this is a local folder: ${env.LOCAL_FOLDER}"
                    sh "cp -r ${env.LOCAL_FOLDER} ./backend"
                }
            }
        }

        stage("Generate Destination Folder") {
            steps {
                script {
                    sh "mkdir -p application_packages"
                }
            }
        }

        stage("Copy Files") {
            steps {
                script {
                    echo "Copying authentication files"
                    sh "cp -r backend/auth/* application_packages/"

                    echo "Copying players files"
                    sh "cp -r backend/players/* application_packages/"

                    echo "Copying utils files"
                    sh "cp -r backend/utils/* application_packages/"

                    echo "Copying requirements.txt"
                    sh "cp backend/requirements.txt application_packages/"
                }
            }
        }

        stage("Install Dependencies") {
            steps {
                script {
                    echo "Installing dependencies"
                    sh "pip3 install -r application_packages/requirements.txt -t application_packages/"
                    echo "Installation complete"
                }
            }
        }

        stage("Generate ZIP to Be Uploaded") {
            steps {
                script {
                    dir("application_packages") {
                        sh "zip -r ../functions.zip ."
                    }
                }
            }
        }

        stage("Copy the ZIP folder to tge original directory"){
            steps {
                script {
                    sh "cp functions.zip ${env.LOCAL_FOLDER}"
                }
            }
        }
    }
}
