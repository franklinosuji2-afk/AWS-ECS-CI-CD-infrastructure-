#!/usr/bin/env pwsh
# Deploy Application Script

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','prod')]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [string]$ImageTag
)

Write-Host "🚀 Deploying application to $Environment..." -ForegroundColor Cyan

# Get AWS Account ID
$accountId = aws sts get-caller-identity --query Account --output text

# Get ECR repository URL
$ecrRepo = "$accountId.dkr.ecr.us-east-1.amazonaws.com/my-app"

# Update task definition with new image
Write-Host "📝 Updating task definition..." -ForegroundColor Yellow
$taskDefFile = "deployment/task-definition-$Environment.json"
$taskDefContent = Get-Content $taskDefFile | ConvertFrom-Json

# Update image
$taskDefContent.containerDefinitions[0].image = "${ecrRepo}:${ImageTag}"

# Register new task definition
$newTaskDef = $taskDefContent | ConvertTo-Json -Depth 10 | aws ecs register-task-definition --cli-input-json - | ConvertFrom-Json

Write-Host "✅ New task definition registered: $($newTaskDef.taskDefinition.taskDefinitionArn)" -ForegroundColor Green

# Update ECS service
Write-Host "🔄 Updating ECS service..." -ForegroundColor Yellow
$clusterName = "my-app-$Environment-cluster"
$serviceName = "my-app-$Environment"

aws ecs update-service `
    --cluster $clusterName `
    --service $serviceName `
    --task-definition $newTaskDef.taskDefinition.family

Write-Host "✅ Deployment initiated successfully!" -ForegroundColor Green
Write-Host "🔍 Monitor deployment: https://console.aws.amazon.com/ecs" -ForegroundColor Cyan