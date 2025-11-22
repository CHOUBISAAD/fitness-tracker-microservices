# Restart a specific service
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('config-server', 'eureka-server', 'user-service', 'activity-service', 'ai-service', 'api-gateway', 'mongodb')]
    [string]$Service
)

Write-Host "Restarting $Service..." -ForegroundColor Yellow

if ($Service -eq 'mongodb') {
    kubectl rollout restart statefulset/mongodb -n fitness-tracker
} else {
    kubectl rollout restart deployment/$Service -n fitness-tracker
}

Write-Host "`nWaiting for rollout to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n$Service Status:" -ForegroundColor Green
kubectl get pods -n fitness-tracker | Select-String $Service

Write-Host "`n✅ $Service has been restarted!" -ForegroundColor Green
