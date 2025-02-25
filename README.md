# 📺 Amazon Prime Clone Deployment with DevOps  

This project automates the deployment of an Amazon Prime clone using modern DevOps tools and best practices. It leverages Infrastructure as Code (IaC), CI/CD pipelines, containerization, security scanning, and monitoring.

## 🚀 Technologies Used  

- **Terraform** – Automates AWS infrastructure provisioning (EC2, EKS, etc.).
- **GitHub & GitHub Actions** – Version control and CI/CD automation.
- **SonarQube** – Static code analysis for quality and security.
- **Docker & AWS ECR** – Containerization and private image storage.
- **AWS EKS** – Kubernetes-based container orchestration.
- **ArgoCD** – GitOps-based continuous deployment.
- **Prometheus & Grafana** – Real-time monitoring and visualization.
- **NPM** – Node.js package manager and build tool.
- **Aqua Trivy** – Container security scanner.


---

## ✅ Prerequisites  

Before setting up the project, ensure you have the following:  

1. **AWS Account** – Sign up if you don’t have one. [Create an AWS Account](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html)  
2. **AWS CLI** – Install and configure AWS CLI for managing cloud resources. [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  
3. **Visual Studio Code (VS Code) (Optional)** – Recommended for development. [Download VS Code](https://code.visualstudio.com/download)  
4. **Terraform** – Install Terraform based on your OS:  

   - **Windows**: [Terraform Windows Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)  
   - **Mac (Homebrew)**:
     ```bash
     brew tap hashicorp/tap
     brew install hashicorp/tap/terraform
     ```

---

## 🛠 AWS Configuration  

1. **IAM User Setup**  
   - Create an IAM user with programmatic access.  
   - Generate an access key and secret key for authentication.  

2. **Key Pair Setup**  
   - Create an AWS EC2 key pair named `projectkey` for SSH access.  

---

## 📌 Deploying the Infrastructure with Terraform  

### 1️⃣ Clone the Repository  
Open a terminal and run:  
```bash
git clone https://github.com/DonGranda/cd-ciproject.git
cd cd-ciproject
code .  # Opens the project in VS Code

```
### 2️⃣ Initialize and Deploy  
Navigate to the Terraform configuration directory `terraform_code\eks_code` and `terraform_code\ec2_server` to execute:  

```bash
aws configure
terraform init
terraform apply --auto-approve
```
## 🔍 SonarQube Setup  

### 🔑 Login Credentials  
- **Username**: `admin`  
- **Password**: `admin` (change after first login)  

### 🔧 Generate a SonarQube Token  
1. Navigate to **Administration → Security → Users → Tokens**.  
2. Create a new token and store it securely for integration with GitHub Actions.  

## 🚧 GitHub Actions Configuration

1. **Set Up Repository Secrets**:
   - Navigate to `Settings → Secrets and variables → Actions → New repository secret`.
   - Add the following secrets:
     - `SONARQUBE_TOKEN`: Your SonarQube authentication token.
     - `AWS_ACCESS_KEY_ID`: Your AWS access key.
     - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key.

2. **Define Required Dependencies**:
   - Ensure your GitHub Actions workflow installs required dependencies like Node.js, Docker, and SonarQube Scanner.
   - Example setup in `.github/workflows/deploy.yml`:
  
By following these steps, GitHub Actions will automate the build, test, and deployment process for your project.

## 🚀 CI/CD Pipeline Overview  

### 🔄 Pipeline Workflow  
1️⃣ **Source Code Retrieval**: Pulls the latest code from GitHub.  
2️⃣ **Code Quality Check**: Runs a static analysis using SonarQube.  
3️⃣ **Quality Assurance**: Enforces coding standards via SonarQube’s Quality Gate.  
4️⃣ **Dependency Installation**: Installs necessary Node.js packages.  
5️⃣ **Security Scan**: Uses Trivy to detect vulnerabilities in the project.  
6️⃣ **Containerization**: Builds a Docker image for deployment.  
7️⃣ **Image Deployment**: Tags and pushes the Docker image to AWS Elastic Container Registry (ECR).  




            }
        }
        

# 🛠️ GitHub Actions Workflow Breakdown  

This repository contains GitHub Actions workflows for automating code analysis, security scanning, containerization, and deployment to AWS EKS. Below is a breakdown of the workflows and their respective responsibilities.  

## 🔍 Workflow 1: Code Analysis and Push to Amazon ECR  

### 📌 Overview  
This workflow runs when code is pushed to the repository. It performs the following tasks:  
1️⃣ **Code Checkout**: Retrieves the latest code.  
2️⃣ **SonarQube Analysis**: Checks for code quality issues and security vulnerabilities.  
3️⃣ **Quality Gate Validation**: Ensures the code meets predefined quality standards.  
4️⃣ **Dependency Installation**: Installs necessary Node.js dependencies.  
5️⃣ **Security Scan**: Uses Trivy to scan for vulnerabilities in dependencies and the codebase.  
6️⃣ **Docker Build & Push**: Builds a Docker image and pushes it to Amazon Elastic Container Registry (ECR).  

### ⚙️ Workflow Breakdown  

#### **Step 1: Code Analysis and Security Scanning**  

```yaml
name: Check for Code Smells and Push to ECR

on:
  push

jobs:
  Check_for_Code_Smells:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code 
        uses: actions/checkout@v4

      - name: Sonar Scan 
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}

      # Check the Quality Gate status.
      - name: SonarQube Quality Gate check
        id: sonarqube-quality-gate-check
        uses: sonarsource/sonarqube-quality-gate-action@master
        with:
          pollingTimeoutSec: 600
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }} # Optional

      - name: Show SonarQube Quality Gate Status
        run: echo "The Quality Gate status is ${{ steps.sonarqube-quality-gate-check.outputs.quality-gate-status }}"

      - name: Install all packages for source code 
        run: npm install

      - name: Scan for Vunrabilty 
        run: trivy fs . > trivy-scan-logs.txt
  
  Push_to_Amazon_ECR:
    needs: Check_for_Code_Smells
    runs-on: ubuntu-latest

    steps: 
      - name: Checkout Code 
        uses: actions/checkout@v4

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build, tag, and push docker image to Amazon ECR
        env:
          REGISTRY: ${{ secrets.REGISTORY }}
          REPOSITORY: amazon-prime
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $REGISTRY/$REPOSITORY:$IMAGE_TAG .
          docker push $REGISTRY/$REPOSITORY:$IMAGE_TAG
          docker push $REGISTRY/$REPOSITORY:latest

  
```

## Continuous Deployment with ArgoCD
1. **Create EKS Cluster**: Use Terraform to create an EKS cluster and related resources.
2. **Deploy Amazon Prime Clone**: Use ArgoCD to deploy the application using Kubernetes YAML files.
3. **Monitoring Setup**: Install Prometheus and Grafana using Helm charts for monitoring the Kubernetes cluster.

### Deployment Pipeline
```groovy
pipeline {
    agent any

    environment {
        KUBECTL = '/usr/local/bin/kubectl'
    }

    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'amazon-prime-cluster', description: 'Enter your EKS cluster name')
    }

    stages {
        stage("Login to EKS") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'),
                                     string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) {
                        sh "aws eks --region us-east-1 update-kubeconfig --name ${params.CLUSTER_NAME}"
                    }
                }
            }
        }

        stage("Configure Prometheus & Grafana") {
            steps {
                script {
                    sh """
                    helm repo add stable https://charts.helm.sh/stable || true
                    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
                    # Check if namespace 'prometheus' exists
                    if kubectl get namespace prometheus > /dev/null 2>&1; then
                        # If namespace exists, upgrade the Helm release
                        helm upgrade stable prometheus-community/kube-prometheus-stack -n prometheus
                    else
                        # If namespace does not exist, create it and install Helm release
                        kubectl create namespace prometheus
                        helm install stable prometheus-community/kube-prometheus-stack -n prometheus
                    fi
                    kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus -p '{"spec": {"type": "LoadBalancer"}}'
                    kubectl patch svc stable-grafana -n prometheus -p '{"spec": {"type": "LoadBalancer"}}'
                    """
                }
            }
        }

        stage("Configure ArgoCD") {
            steps {
                script {
                    sh """
                    # Install ArgoCD
                    kubectl create namespace argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
                    """
                }
            }
        }
		
    }
}
```

## Cleanup
- Run cleanup pipelines to delete the resources such as load balancers, services, and deployment files.
- Use `terraform destroy` to remove the EKS cluster and other infrastructure.


---
