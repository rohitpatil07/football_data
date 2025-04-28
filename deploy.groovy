@Library("SharedLib") _

pipeline {
    agent any 

    environment {
        AWS_DEFAULT_REGION = 'us-east-1' 
    }

    stages {
        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Clone Repo") {
            steps {
                script {
                    echo "Cloning Repository"
                    clone("https://github.com/rohitpatil07/football_data.git", "main")
                }
            }
        }

        stage("Generate Destination Folder") {
            steps {
                script {
                    echo "Creating destination folder"
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

        stage("Copy the ZIP folder to the workspace"){
            steps {
                script {
                    sh "cp functions.zip backend/"
                }
            }
        }

        stage("Test AWS Credentials") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    script {
                        echo "Testing AWS Credentials"
                        sh 'aws sts get-caller-identity'
                    }
                }
            }
        }

        stage("Init Terraform & Validate") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    sh """
                        cd terraform
                        terraform init
                        terraform validate
                    """
                }
            }
        }

        stage("Planned Infrastructure") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    sh """
                        cd terraform
                        terraform plan
                    """
                }
            }
        }

        stage("Apply Infrastructure") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    input message: 'Do you want to apply the changes?', ok: 'Yes'
                    sh """
                        cd terraform
                        terraform apply -auto-approve
                    """
                }
            }
        }

        //Used for local frontend
        // stage("Update frontend API URL") {
        //     steps {
        //         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
        //             script {
        //                 echo "Updating frontend API URL"
        //                 sh """
        //                     cd terraform
        //                     echo "API_URL=$(terraform output -raw api_gw_dev_url)" > ../frontend/.env 
        //                 """
        //             }
        //         }
        //     }
        // }

        stage("Provide Output"){
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    script {
                        echo "Display API_URL"
                        sh """
                            cd terraform
                            terraform output -raw api_gw_dev_url
                        """
                    }
                }
            }
        }

        stage("Copy data.csv to S3") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    script {
                        echo "Copying data.csv to S3"
                        sh """
                            aws s3 cp /home/rohit/Desktop/aws/terraform/football_app/terraform/data/players.csv s3://lambda-trigger-bucket-demo-iabkacbefifopwqibfoqiefoq
                        """
                    }
                }
            }

        }

        stage("Destroy Infrastructure") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-admin']]) {
                    input message: 'Do you want to destroy the changes?', ok: 'Yes'
                    sh """
                        cd terraform
                        terraform destroy -auto-approve
                    """
                }
            }
        }
    }
}
