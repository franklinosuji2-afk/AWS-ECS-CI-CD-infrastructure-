# My AWS App - CI/CD with DevSecOps

A production-ready Node.js application deployed on AWS ECS with complete CI/CD pipeline.

## Features

- ✅ CI/CD with GitHub Actions
- ✅ Blue/Green deployments
- ✅ Security scanning (Trivy + Checkov)
- ✅ Infrastructure as Code (Terraform)
- ✅ Container orchestration (ECS Fargate)

## Quick Start

### Prerequisites
- Node.js 20+
- Docker
- AWS CLI configured
- Terraform 1.0+

### Local Development
```bash
npm install
npm run dev

Deploy Infrastructure
powershell.\scripts\setup-infrastructure.ps1 -Environment dev
Documentation
See Setup Guide for detailed instructions.

---

## 🎯 Complete Setup Workflow

### Step 1: Create Project Structure
```powershell
# Run the structure creation commands above
Step 2: Initialize Git Repository
powershellgit init
git add .
git commit -m "Initial commit: Project structure"
Step 3: Create GitHub Repository
powershell# Create repo on GitHub, then:
git remote add origin https://github.com/yourusername/my-aws-app.git
git branch -M main
git push -u origin main
Step 4: Install Dependencies
powershellnpm install
Step 5: Setup AWS Infrastructure
powershell.\scripts\setup-infrastructure.ps1 -Environment dev -AutoApprove
Step 6: Configure GitHub Secrets
Go to GitHub → Settings → Secrets and add:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

Step 7: Push to Trigger Pipeline
powershellgit checkout -b develop
git push origin develop
📊 File Organization Summary
DirectoryPurposeKey Files.github/workflows/CI/CD pipelinescicd.ymlterraform/Infrastructure codemain.tf, variables.tfterraform/environments/Environment configsdev/terraform.tfvars, prod/terraform.tfvarsdeployment/Deployment configsappspec.yaml, task definitionsscripts/Automation scriptsPowerShell deployment scriptssrc/Application codeindex.js, routes, configtests/Test filesUnit and integration tests
This structure follows AWS best practices and separates concerns clearly!