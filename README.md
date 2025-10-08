# 🚀 AWS ECS CI/CD Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.13+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20Fargate-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-20+-339933?logo=node.js&logoColor=white)](https://nodejs.org/)

Production-ready AWS ECS infrastructure with complete CI/CD pipeline, Infrastructure as Code (Terraform), Docker containerization, and Blue/Green deployments using AWS CodeDeploy.

![Architecture Diagram](https://via.placeholder.com/800x400?text=Add+Your+Architecture+Diagram+Here)

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Infrastructure Components](#infrastructure-components)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security Features](#security-features)
- [Cost Optimization](#cost-optimization)
- [Deployment](#deployment)
- [Monitoring & Logging](#monitoring--logging)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

- **Infrastructure as Code**: Complete AWS infrastructure defined in Terraform
- **Container Orchestration**: ECS Fargate for serverless container management
- **Blue/Green Deployments**: Zero-downtime releases with AWS CodeDeploy
- **CI/CD Pipeline**: Automated testing, building, and deployment with GitHub Actions
- **Security Scanning**: Container vulnerability scanning (Trivy) and IaC security (Checkov)
- **Multi-Stage Docker Builds**: Optimized container images with security hardening
- **Auto-Scaling**: Configurable auto-scaling based on CPU/memory metrics
- **Load Balancing**: Application Load Balancer with health checks
- **Monitoring**: CloudWatch integration for logs and metrics
- **Cost Optimized**: Separate dev/prod configurations with cost-saving measures

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet Gateway                         │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Application Load Balancer                      │
│           (Public Subnets - 2 AZs)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
┌───────▼────────┐       ┌───────▼────────┐
│  Target Group  │       │  Target Group  │
│     (Blue)     │       │    (Green)     │
└───────┬────────┘       └───────┬────────┘
        │                         │
┌───────▼─────────────────────────▼───────┐
│         ECS Fargate Cluster             │
│      (Private Subnets - 2 AZs)          │
│                                         │
│  ┌─────────────┐    ┌─────────────┐   │
│  │  ECS Task 1 │    │  ECS Task 2 │   │
│  │  Container  │    │  Container  │   │
│  └─────────────┘    └─────────────┘   │
└─────────────────────────────────────────┘
         │                      │
         └──────────┬───────────┘
                    │
         ┌──────────▼──────────┐
         │    NAT Gateway       │
         └──────────┬──────────┘
                    │
              Internet
```

### Network Architecture

- **VPC**: Dedicated Virtual Private Cloud (10.0.0.0/16)
- **Public Subnets**: 2 subnets across 2 AZs for ALB
- **Private Subnets**: 2 subnets across 2 AZs for ECS tasks
- **NAT Gateway**: For outbound internet access from private subnets
- **Internet Gateway**: For inbound traffic to ALB

## 🛠️ Technologies Used

### Infrastructure & Cloud
- **AWS ECS (Fargate)**: Serverless container orchestration
- **AWS ECR**: Container registry
- **Application Load Balancer**: Layer 7 load balancing
- **AWS CodeDeploy**: Blue/Green deployment automation
- **VPC**: Network isolation and security
- **CloudWatch**: Logging and monitoring
- **IAM**: Role-based access control

### Infrastructure as Code
- **Terraform**: Infrastructure provisioning and management
- **Terraform Workspaces**: Environment separation (dev/prod)

### Application & Container
- **Node.js 20**: Runtime environment
- **Express.js**: Web framework
- **Docker**: Containerization
- **Alpine Linux**: Minimal base image

### CI/CD & DevOps
- **GitHub Actions**: CI/CD automation
- **Trivy**: Container vulnerability scanning
- **Checkov**: Infrastructure security scanning
- **ESLint**: Code quality
- **Jest**: Unit testing

## 📁 Project Structure

```
aws-ecs-cicd-infrastructure/
├── .github/
│   └── workflows/
│       └── cicd.yml              # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   │   └── terraform.tfvars  # Development variables
│   │   └── prod/
│   │       └── terraform.tfvars  # Production variables
│   ├── main.tf                   # Main Terraform configuration
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output values
│   ├── backend.tf                # State backend configuration
│   └── versions.tf               # Provider versions
├── deployment/
│   ├── appspec.yaml              # CodeDeploy AppSpec
│   ├── task-definition-dev.json  # ECS task definition (dev)
│   └── task-definition-prod.json # ECS task definition (prod)
├── src/
│   ├── index.js                  # Application entry point
│   ├── routes/
│   │   └── health.js             # Health check endpoint
│   └── config/
│       └── database.js           # Database configuration
├── tests/
│   └── unit/
│       └── health.test.js        # Unit tests
├── scripts/
│   ├── setup-infrastructure.ps1  # Setup automation
│   ├── deploy.ps1                # Deployment script
│   └── rollback.ps1              # Rollback script
├── Dockerfile                    # Multi-stage Docker build
├── .dockerignore                 # Docker ignore rules
├── .eslintrc.json                # ESLint configuration
├── .gitignore                    # Git ignore rules
├── package.json                  # Node.js dependencies
└── README.md                     # This file
```

## 📋 Prerequisites

- AWS Account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Docker Desktop
- Node.js >= 20
- Git

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/aws-ecs-cicd-infrastructure.git
cd aws-ecs-cicd-infrastructure
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure AWS Backend

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket --bucket YOUR-TERRAFORM-STATE-BUCKET --region us-east-1

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```

### 4. Update Configuration

```bash
# Update terraform/backend.tf with your bucket name
# Update terraform/environments/dev/terraform.tfvars with your settings
```

### 5. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform workspace new dev
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### 6. Build & Push Docker Image

```bash
# Get ECR repository URL from Terraform output
ECR_REPO=$(terraform output -raw ecr_repository_url)

# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO

# Build and push
docker build -t my-app:latest .
docker tag my-app:latest ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest
```

### 7. Deploy Application

```bash
# Update ECS service
aws ecs update-service \
    --cluster my-app-dev-cluster \
    --service my-app-dev \
    --force-new-deployment
```

## 🏗️ Infrastructure Components

### VPC & Networking
- **VPC CIDR**: 10.0.0.0/16
- **Availability Zones**: 2 (us-east-1a, us-east-1b)
- **Public Subnets**: 10.0.101.0/24, 10.0.102.0/24
- **Private Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **NAT Gateway**: 1 (dev) or 2 (prod)
- **Internet Gateway**: 1

### ECS Configuration
- **Launch Type**: Fargate (serverless)
- **CPU**: 256 (dev) / 512 (prod)
- **Memory**: 512 MB (dev) / 1024 MB (prod)
- **Desired Count**: 1 (dev) / 3 (prod)
- **Deployment Controller**: CODE_DEPLOY

### Load Balancer
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Target Groups**: 2 (Blue/Green)
- **Health Check Path**: /health
- **Health Check Interval**: 30 seconds

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline includes:

1. **Code Quality**
   - ESLint code linting
   - Unit tests with Jest
   - Code coverage reporting

2. **Security Scanning**
   - Terraform security scan (Checkov)
   - Container vulnerability scan (Trivy)
   - SARIF upload to GitHub Security

3. **Build & Push**
   - Docker multi-stage build
   - Tag with branch name and commit SHA
   - Push to Amazon ECR

4. **Deploy**
   - **Dev**: Automatic deployment on `develop` branch
   - **Prod**: Manual approval required on `main` branch
   - Blue/Green deployment via CodeDeploy

### Pipeline Stages

```yaml
Code Quality → Security Scan → Build & Push → Deploy (Dev) → Deploy (Prod with Approval)
     ✓              ✓              ✓              ✓                     ✓
```

## 🔒 Security Features

### Container Security
- ✅ Multi-stage Docker builds (reduced attack surface)
- ✅ Non-root user execution (nodejs:1001)
- ✅ Minimal Alpine base image
- ✅ No secrets in images
- ✅ Vulnerability scanning with Trivy

### Infrastructure Security
- ✅ Private subnets for ECS tasks
- ✅ Security groups with least privilege
- ✅ IAM roles with minimal permissions
- ✅ Encrypted ECR repositories (AES256)
- ✅ Encrypted CloudWatch logs
- ✅ VPC isolation

### Code Security
- ✅ Infrastructure security scanning (Checkov)
- ✅ Automated security updates
- ✅ Secrets management via AWS Secrets Manager
- ✅ SARIF security reporting

## 💰 Cost Optimization

### Development Environment (~$65/month)
- Single NAT Gateway
- 1 ECS task
- 256 CPU / 512 MB memory
- 7-day log retention

### Production Environment (~$130/month)
- Dual NAT Gateways (HA)
- 3 ECS tasks
- 512 CPU / 1024 MB memory
- 30-day log retention

### Cost-Saving Tips
1. Use FARGATE_SPOT for non-critical workloads (70% discount)
2. Delete dev environment when not in use
3. Use lifecycle policies for ECR images
4. Enable CloudWatch log retention limits

## 📊 Monitoring & Logging

### CloudWatch Integration
- **Container Insights**: Enabled on ECS cluster
- **Log Groups**: `/ecs/my-app-{environment}`
- **Metrics**: CPU, memory, network utilization
- **Alarms**: Auto-rollback on deployment failures

### Health Checks
- **ALB Health Check**: HTTP GET /health every 30s
- **Container Health Check**: Docker HEALTHCHECK directive
- **Unhealthy Threshold**: 3 consecutive failures

## 🐛 Troubleshooting

### Common Issues

**Issue**: ECS tasks not starting
```bash
# Check service events
aws ecs describe-services --cluster my-app-dev-cluster --services my-app-dev
```

**Issue**: Container fails health checks
```bash
# View container logs
aws logs tail /ecs/my-app-dev --follow
```

**Issue**: Terraform state locked
```bash
# Remove lock from DynamoDB
aws dynamodb delete-item --table-name terraform-locks --key '{"LockID":{"S":"LOCK_ID"}}'
```

## 🧹 Cleanup

To avoid AWS charges, destroy all resources:

```bash
cd terraform
terraform destroy -var-file=environments/dev/terraform.tfvars

# Delete S3 bucket
aws s3 rb s3://YOUR-BUCKET-NAME --force

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-locks
```

## 📈 Future Enhancements

- [ ] Add RDS PostgreSQL database
- [ ] Implement auto-scaling policies
- [ ] Add Route 53 custom domain
- [ ] SSL/TLS certificates (ACM)
- [ ] WAF integration
- [ ] Multi-region deployment
- [ ] Canary deployments
- [ ] A/B testing support
- [ ] Distributed tracing (X-Ray)
- [ ] Prometheus/Grafana monitoring

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Your Name**
<<<<<<< HEAD
- GitHub: (https://github.com/franklinosuji2-afk/)
- LinkedIn: (https://www.linkedin.com/in/franklin-osuji-a96003321/)


## 🙏 Acknowledgments

- AWS Documentation
- Terraform Registry
- Docker Best Practices
- DevOps Community

---

⭐ If you find this project helpful, please give it a star!

<<<<<<< HEAD
📧 For questions or feedback, please open an issue.
=======
📧 For questions or feedback, please open an issue.
>>>>>>> c7506ca (fix: Update deprecated GitHub Actions to v4 and fix npm scripts)
