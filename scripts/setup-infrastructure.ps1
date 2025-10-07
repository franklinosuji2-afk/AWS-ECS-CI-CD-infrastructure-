#!/usr/bin/env pwsh
# Setup Infrastructure Script

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','prod')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove
)

Write-Host "🚀 Setting up infrastructure for $Environment environment..." -ForegroundColor Cyan

# Navigate to terraform directory
Set-Location "terraform"

# Initialize Terraform
Write-Host "📦 Initializing Terraform..." -ForegroundColor Yellow
terraform init

# Select or create workspace
Write-Host "🔄 Selecting workspace: $Environment..." -ForegroundColor Yellow
terraform workspace select $Environment 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating new workspace: $Environment..." -ForegroundColor Yellow
    terraform workspace new $Environment
}

# Plan infrastructure
Write-Host "📋 Planning infrastructure..." -ForegroundColor Yellow
$varFile = "environments/$Environment/terraform.tfvars"
terraform plan -var-file="$varFile" -out="$Environment.tfplan"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed!" -ForegroundColor Red
    exit 1
}

# Apply infrastructure
if ($AutoApprove) {
    Write-Host "✅ Applying infrastructure (auto-approved)..." -ForegroundColor Green
    terraform apply -auto-approve "$Environment.tfplan"
} else {
    Write-Host "⏳ Applying infrastructure (manual approval required)..." -ForegroundColor Green
    terraform apply "$Environment.tfplan"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Infrastructure setup completed successfully!" -ForegroundColor Green
    
    # Show outputs
    Write-Host "`n📊 Infrastructure Outputs:" -ForegroundColor Cyan
    terraform output
} else {
    Write-Host "❌ Infrastructure setup failed!" -ForegroundColor Red
    exit 1
}

Set-Location ..