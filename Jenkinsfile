pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-east-1'  // Adjust the region as needed
        PACKER_VERSION = '1.8.6'
        GIT_VERSION = '2.30.0'
    }

    stages {
        stage('Install Git and Checkout Repository') {
            steps {
                script {
                    // Install Git if not already installed using yum
                    sh '''
                    if ! command -v git &> /dev/null; then
                        echo "Git not found, installing..."
                        sudo yum update -y
                        sudo yum install -y git
                    else
                        echo "Git is already installed"
                    fi
                    '''
                    
                    // Checkout the repository containing your Packer HCL file
                    echo "Checking out the repository containing the Packer HCL file"
                    git 'https://github.com/your-repository/your-packer-project.git'  // Replace with your Git repository URL
                }
            }
        }

        stage('Install Packer and Build AMI') {
            steps {
                script {
                    // Install Packer if not already installed using yum
                    sh '''
                    if ! command -v packer &> /dev/null; then
                        echo "Packer not found, installing..."
                        curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
                        unzip packer_${PACKER_VERSION}_linux_amd64.zip
                        sudo mv packer /usr/local/bin/
                    else
                        echo "Packer is already installed"
                    fi
                    '''
                    
                    // Validate the Packer HCL configuration
                    echo "Validating Packer HCL file"
                    sh 'packer validate golden_image_packer.hcl'

                    // Build the AMI using the Packer HCL script
                    echo "Building the AMI with Packer"
                    sh 'packer init .'  // Initializes the Packer configuration
                    sh 'packer build golden_image_packer.hcl'
                }
            }
        }

        stage('Clean Up Packer Files') {
            steps {
                script {
                    echo "Cleaning up Packer-related files..."

                    // Remove the downloaded Packer binary zip file
                    sh 'rm -f packer_${PACKER_VERSION}_linux_amd64.zip'

                    // Remove the unpacked Packer binary
                    sh 'rm -f packer'

                    // Clean the workspace if necessary
                    cleanWs()
                }
            }
        }
    }

    post {
        success {
            script {
                // Send a Slack success message
                slackSend(channel: '#jenkins-notifications', message: "The AMI creation job has succeeded!", color: 'good')
            }
        }
        failure {
            script {
                // Send a Slack failure message
                slackSend(channel: '#jenkins-notifications', message: "The AMI creation job has failed!", color: 'danger')
            }
        }
        unstable {
            script {
                // Send an unstable message if the build is marked as unstable
                slackSend(channel: '#jenkins-notifications', message: "The AMI creation job is unstable!", color: 'warning')
            }
        }
    }
}
