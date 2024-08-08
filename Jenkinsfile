pipeline {
    agent any

    environment {
        JAVA_HOME = '/opt/homebrew/opt/openjdk@21'
        PATH = "${env.JAVA_HOME}/bin:/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/1sayan1/Skill-Up-Project.git'
            }
        }

        stage('Build Java Code') {
            steps {
                script {
                    sh "mvn clean install"
                }
            }
        }

        stage('Build Node.js Code') {
            steps {
                script {
                    sh "npm install"
                    sh "npm run build"
                }
            }
        }

        stage('Setup Environment') {
            steps {
                script {
                    withEnv(["PATH+BREW=/opt/homebrew/bin"]) {
                        sh "brew update || true"
                        sh "brew install maven node terraform ansible"
                    }
                }
            }
        }

        stage('Authenticate Azure CLI') {
            environment {
                AZURE_CLIENT_ID = credentials('azure-client-id') // Add your Azure Client ID in Jenkins credentials store
                AZURE_CLIENT_SECRET = credentials('azure-client-secret') // Add your Azure Client Secret in Jenkins credentials store
                AZURE_TENANT_ID = credentials('azure-tenant-id') // Add your Azure Tenant ID in Jenkins credentials store
                AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id') // Add your Azure Subscription ID in Jenkins credentials store
            }
            steps {
                script {
                    sh """
                    az login --service-principal -u ${env.AZURE_CLIENT_ID} -p ${env.AZURE_CLIENT_SECRET} --tenant ${env.AZURE_TENANT_ID}
                    az account set --subscription ${env.AZURE_SUBSCRIPTION_ID}
                    """
                }
            }
        }

        stage('Generate SSH Keys') {
            steps {
                script {
                    def keys = [
                        'dev': '/Users/jenkins/.ssh/id_rsa_dev',
                        'int': '/Users/jenkins/.ssh/id_rsa_int',
                        'prod': '/Users/jenkins/.ssh/id_rsa_prod'
                    ]

                    keys.each { env, keyPath ->
                        if (!fileExists(keyPath)) {
                            sh "ssh-keygen -t rsa -b 4096 -f ${keyPath} -N ''"
                        } else {
                            echo "SSH key for ${env} environment already exists. Skipping key generation."
                        }
                    }
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                dir('terraform') {
                    script {
                        // Update Terraform and Providers
                        sh "terraform init -upgrade"
                        // Ensure provider versions are updated
                        sh "terraform providers"
                    }
                }
            }
        }

        stage('Create Resource Group') {
            steps {
                dir('terraform') {
                    script {
                        sh "terraform apply -auto-approve -target=azurerm_resource_group.main -var-file=\"terraform.tfvars\""
                    }
                }
            }
        }

        stage('Provision VMs') {
            steps {
                script {
                    def environments = ['dev', 'int', 'prod']
                    environments.each { env ->
                        stage("Provision ${env} VM") {
                            dir('terraform') {
                                script {
                                    sh """
                                    terraform workspace new ${env} || terraform workspace select ${env}
                                    terraform apply -auto-approve -var-file="terraform.tfvars"
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                script {
                    def environments = ['dev', 'int', 'prod']
                    environments.each { env ->
                        script {
                            def vm_ip = sh(script: "terraform output -raw vm_public_ip[${environments.indexOf(env)}]", returnStdout: true).trim()
                            def admin_user = sh(script: "terraform output -raw admin_username", returnStdout: true).trim()
                            def admin_password = sh(script: "terraform output -raw admin_password", returnStdout: true).trim()

                            writeFile file: "ansible/inventory_${env}", text: "[${env}_servers]\n${vm_ip} ansible_user=${admin_user} ansible_password=${admin_password}\n"
                        }
                    }
                }
            }
        }

        stage('Configure VMs and Deploy Application') {
            environment {
                DOCKER_HUB_USERNAME = credentials('docker-hub-username') // Add your Docker Hub Username in Jenkins credentials store
                DOCKER_HUB_PASSWORD = credentials('docker-hub-password') // Add your Docker Hub Password in Jenkins credentials store
            }
            steps {
                script {
                    def environments = ['dev', 'int', 'prod']
                    environments.each { env ->
                        stage("Configure ${env} VM and Deploy Application") {
                            script {
                                def vm_ip = sh(script: "terraform output -raw vm_public_ip[${environments.indexOf(env)}]", returnStdout: true).trim()
                                def admin_user = sh(script: "terraform output -raw admin_username", returnStdout: true).trim()
                                def admin_password = sh(script: "terraform output -raw admin_password", returnStdout: true).trim()

                                echo "SSH credentials for ${env}: ${admin_user}@${vm_ip} with password ${admin_password}"
                                sh "cat ansible/inventory_${env}"

                                sh "ansible-playbook -i ansible/inventory_${env} ansible/install-docker.yml"

                                sh "sudo docker build -t my-app-${env} ."

                                sh "echo ${env.DOCKER_HUB_PASSWORD} | sudo docker login -u ${env.DOCKER_HUB_USERNAME} --password-stdin"
                                sh "sudo docker tag my-app-${env} ${env.DOCKER_HUB_USERNAME}/my-app-${env}:latest"
                                sh "sudo docker push ${env.DOCKER_HUB_USERNAME}/my-app-${env}:latest"

                                sh "ansible-playbook -i ansible/inventory_${env} ansible/pull-run-docker-image.yml --extra-vars \"docker_image=${env.DOCKER_HUB_USERNAME}/my-app-${env}:latest\""
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
