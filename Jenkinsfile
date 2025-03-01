pipeline {
    agent any

    tools{
        jdk 'jdk17.0.8'
        nodejs 'nodejs16'
    }
    parameters {
        string(name: 'ECR_REPOSITORY', defaultValue: 'amazon-prime', description: 'Enter repository name')
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '#####', description: 'Enter AWS Account ID') 
    }

    stages {
        stage('Git Checkout') {
            steps {
               git branch: 'main', url: 'https://github.com/DonGranda/cd-ciproject.git'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                ScannerHome = tool 'sonar7'
            }
            steps {
                script {
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            ${ScannerHome}/bin/sonar-scanner \
                             -Dsonar.projectKey=amazontest \
                            //  -Dsonar.projectName=AmazonCICD \
                        """
                    }
                }
            }
        }

          stage('SonarQube Quality Gate') {
            
            steps {
                script {
                timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
                }
                }
            }
          }


          stage('NPM Installation') {
            
            steps {
                sh "npm install"
                }
                
            }
       
          stage('Trivy Scan ') {
            
            steps {
                sh "trivy fs . > trivy-scan-logs.txt"
                }
                
            }
            stage('Docker Build ') {
            
            steps {
                sh "docker build -t ${params.ECR_REPOSITORY} ."
                }
                
            }
            stage('Create ECR Repo ') {
            
            steps {
                withCredentials([string(credentialsId: 'access_key', variable: 'AWS_ACCESS_KEY'), string(credentialsId: 'secret_key', variable: 'AWS_SECRET_KEY')]) {
                sh """
                aws configure set aws_access_key_id $AWS_ACCESS_KEY
                aws configure set aws_secret_access_key $AWS_SECRET_KEY
                aws ecr describe-repositories --repository-name ${params.ECR_REPOSITORY} --region eu-north-1 || \
                aws ecr create-repository --repository-name ${params.ECR_REPOSITORY} --region eu-north-1
                """
                }
                }
                
            }
            stage('Tag ECR Image') {
            
            steps {
                withCredentials([string(credentialsId: 'access_key', variable: 'AWS_ACCESS_KEY'), string(credentialsId: 'secret_key', variable: 'AWS_SECRET_KEY')]) {
                sh """
                aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com
                docker tag ${params.ECR_REPOSITORY} ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/${params.ECR_REPOSITORY}:${BUILD_NUMBER}
                docker tag ${params.ECR_REPOSITORY} ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/${params.ECR_REPOSITORY}:latest
                """
                }
                }
                
            }
                stage('Push ECR Image') {
            
            steps {
                withCredentials([string(credentialsId: 'access_key', variable: 'AWS_ACCESS_KEY'), string(credentialsId: 'secret_key', variable: 'AWS_SECRET_KEY')]) {
                sh """
                aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com
                docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/${params.ECR_REPOSITORY}:${BUILD_NUMBER}
                docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/${params.ECR_REPOSITORY}:latest
                """
                }
                }
                
            }

            stage('Clean Up images on Jenkins') {
            
            steps {
                withCredentials([string(credentialsId: 'access_key', variable: 'AWS_ACCESS_KEY'), string(credentialsId: 'secret_key', variable: 'AWS_SECRET_KEY')]) {
                sh """
                aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com
                    docker rmi ${params.ECR_REPOSITORY} ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/${params.ECR_REPOSITORY}:${BUILD_NUMBER}
                    docker rmi ${params.ECR_REPOSITORY} ${params.AWS_ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/${params.ECR_REPOSITORY}:latest
                
                """
                }
                }
                
            }
          

    }
}
