#!/usr/bin/env pwsh
# Rollback Deployment Script

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','prod')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [int]$RevisionOffset = 1
)

Write-Host "⏮️  Rolling back $Environment environment..." -ForegroundColor Yellow

$clusterName = "my-app-$Environment-cluster"
$serviceName = "my-app-$Environment"

# Get current task definition
$currentService = aws ecs describe-services --cluster $clusterName --services $serviceName | ConvertFrom-Json
$currentTaskDef = $currentService.services[0].taskDefinition

Write-Host "📋 Current task definition: $currentTaskDef" -ForegroundColor Cyan

# Get previous task definitions
$family = "my-app-$Environment"
$taskDefs = aws ecs list-task-definitions --family-prefix $family --sort DESC --max-items 10 | ConvertFrom-Json

if ($taskDefs.taskDefinitionArns.Count -le $RevisionOffset) {
    Write-Host "❌ No previous revision found to rollback to!" -ForegroundColor Red
    exit 1
}

$previousTaskDef = $taskDefs.taskDefinitionArns[$RevisionOffset]
Write-Host "⏮️  Rolling back to: $previousTaskDef" -ForegroundColor Yellow

# Update service with previous task definition
aws ecs update-service `
    --cluster $clusterName `
    --service $serviceName `
    --task-definition $previousTaskDef

Write-Host "✅ Rollback initiated successfully!" -ForegroundColor Green
Write-Host "🔍 Monitor rollback: https://console.aws.amazon.com/ecs" -ForegroundColor Cyan