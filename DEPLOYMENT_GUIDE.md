
markdown
🚀 AWS ECS Deployment Guide
Prerequisites
Before you begin, ensure you have:

✅ AWS Account with appropriate IAM permissions
✅ AWS CLI configured (aws configure)
✅ Terraform >= 1.0 installed
✅ Docker Desktop running
✅ Node.js >= 20 installed
✅ Git installed
📋 Required AWS IAM Permissions
Your AWS user/role needs permissions for:

ECS (Full Access)
ECR (Full Access)
VPC (Full Access)
EC2 (for ALB, Security Groups)
IAM (Role creation)
CloudWatch Logs
CodeDeploy
S3 (for Terraform state)
DynamoDB (for Terraform locks)
🔧 Step-by-Step Deployment
Step 1: Clone Repository
bash


git clone https://github.com/franklinosuji2-afk/AWS-ECS-CI-CD-infrastructure-.git
cd AWS-ECS-CI-CD-infrastructure-
Step 2: Configure Terraform Backend
Create S3 bucket for Terraform state:
bash


aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-east-1
Enable versioning:
bash


aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
Create DynamoDB table for state locking:
bash


aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
Update terraform/backend.tf with your bucket name:
hcl


terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"  # Change this
    key            = "ecs-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
Step 3: Configure Variables
Update terraform/environments/dev/terraform.tfvars:

hcl


aws_region     = "us-east-1"
environment    = "dev"
app_name       = "my-app"
vpc_cidr       = "10.0.0.0/16"
container_port = 3000
desired_count  = 1
cpu            = "256"
memory         = "512"
For production, update terraform/environments/prod/terraform.tfvars:

hcl


aws_region     = "us-east-1"
environment    = "prod"
app_name       = "my-app"
vpc_cidr       = "10.0.0.0/16"
container_port = 3000
desired_count  = 3
cpu            = "512"
memory         = "1024"
Step 4: Deploy Infrastructure
For Development:
bash


cd terraform
terraform init
terraform workspace new dev
terraform workspace select dev
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
For Production:
bash


terraform workspace new prod
terraform workspace select prod
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
Step 5: Build & Push Docker Image
Get ECR repository URL:
bash


ECR_REPO=$(terraform output -raw ecr_repository_url)
echo $ECR_REPO
Authenticate Docker to ECR:
bash


aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_REPO
Build Docker image:
bash


cd ..
docker build -t my-app:latest .
Tag and push to ECR:
bash


docker tag my-app:latest ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest
Step 6: Deploy Application
The initial deployment happens automatically when you apply Terraform. The ECS service will pull the latest image from ECR.

Check deployment status:
bash


aws ecs describe-services \
  --cluster my-app-dev-cluster \
  --services my-app-dev \
  --query 'services[0].deployments'
Get Application URL:
bash


cd terraform
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "Application URL: http://${ALB_DNS}"
Test the application:
bash


curl http://${ALB_DNS}/health
curl http://${ALB_DNS}/
Step 7: Setup GitHub Actions CI/CD
Go to your GitHub repository: Settings → Secrets and variables → Actions

Add these secrets:

AWS_ACCESS_KEY_ID - Your AWS access key
AWS_SECRET_ACCESS_KEY - Your AWS secret key
AWS_REGION - Your AWS region (e.g., us-east-1)
Push code to trigger pipeline:

bash


git add .
git commit -m "Initial deployment"
git push origin main
The CI/CD pipeline will automatically:

Run tests and linting
Scan for security vulnerabilities
Build Docker image
Push to ECR
Deploy to ECS
Perform smoke tests
🔄 Making Updates
Update Application Code
Make changes to your code
Commit and push:
bash


git add .
git commit -m "Your changes"
git push origin develop  # For dev environment
git push origin main     # For prod environment
GitHub Actions will automatically build and deploy.

Update Infrastructure
Modify Terraform files
Apply changes:
bash


cd terraform
terraform workspace select dev
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
📊 Monitoring & Logs
View Application Logs
bash


aws logs tail /ecs/my-app-dev --follow
View ECS Service Status
bash


aws ecs describe-services \
  --cluster my-app-dev-cluster \
  --services my-app-dev
View Running Tasks
bash


aws ecs list-tasks --cluster my-app-dev-cluster
CloudWatch Dashboard
Go to AWS Console → CloudWatch
Navigate to Dashboards
View ECS metrics for CPU, Memory, Network
🔧 Troubleshooting
Issue: ECS Tasks Not Starting
Check:

Task definition is valid
ECR image exists and is accessible
Security groups allow traffic
Subnets have internet access (via NAT Gateway)
Debug:

bash


aws ecs describe-tasks \
  --cluster my-app-dev-cluster \
  --tasks <task-id>
Issue: Cannot Access Application
Check:

Security group allows port 80/443
Target group health checks are passing
ECS tasks are registered with target group
Debug:

bash


# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
Issue: CodeDeploy Deployment Fails
Check:

Task definition is valid
IAM roles have correct permissions
Target groups exist
Debug:

bash


aws deploy get-deployment --deployment-id <deployment-id>
Issue: Docker Build Fails
Check:

Dockerfile syntax
Dependencies in package.json
Node.js version compatibility
Debug:

bash


docker build -t my-app:latest . --no-cache
🧹 Cleanup
To remove all resources and avoid AWS charges:

Step 1: Delete ECS Service
bash


aws ecs update-service \
  --cluster my-app-dev-cluster \
  --service my-app-dev \
  --desired-count 0

aws ecs delete-service \
  --cluster my-app-dev-cluster \
  --service my-app-dev \
  --force
Step 2: Delete ECR Images
bash


aws ecr batch-delete-image \
  --repository-name my-app \
  --image-ids imageTag=latest
Step 3: Destroy Infrastructure
bash


cd terraform
terraform workspace select dev
terraform destroy -var-file=environments/dev/terraform.tfvars
Step 4: Delete State Files (Optional)
bash


aws s3 rm s3://your-terraform-state-bucket/ecs-app/ --recursive
💰 Cost Estimates
Development Environment
VPC: $0 (Free)
NAT Gateway: $0.045/hour ($32/month)
ALB: $0.0225/hour ($16/month)
ECS Fargate: 1 task × 0.25 vCPU × 0.5 GB = ~$7/month
ECR Storage: First 500 MB free, then $0.10/GB
Data Transfer: First 100 GB free
CloudWatch Logs: First 5 GB free, then $0.50/GB
Total Dev: ~$55-60/month

Production Environment
VPC: $0 (Free)
NAT Gateway: 2 × ~$32/month = ~$64/month
ALB: ~$16/month
ECS Fargate: 3 tasks × 0.5 vCPU × 1 GB = ~$42/month
ECR Storage: ~$1-2/month
Data Transfer: Variable based on traffic
CloudWatch Logs: Variable based on log volume
Total Prod: ~$125-135/month (base cost)

Cost Optimization Tips
Use Fargate Spot: 70% cheaper for non-critical workloads
Single NAT Gateway (Dev): Use one NAT in dev environments
Enable ECR Lifecycle Policies: Auto-delete old images
CloudWatch Log Retention: Set to 7 days for dev, 30 days for prod
Shutdown Dev at Night: Stop ECS tasks when not needed
Use Reserved Capacity: For production long-term workloads
📚 Additional Resources
AWS ECS Documentation
Terraform AWS Provider
Docker Best Practices
AWS CodeDeploy
GitHub Actions
🆘 Support
If you encounter issues:

Check the troubleshooting section above
Review AWS CloudWatch Logs
Check GitHub Actions workflow logs
Review Terraform plan output
For additional help, create an issue in the GitHub repository