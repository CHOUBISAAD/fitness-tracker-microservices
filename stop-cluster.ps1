# Stop Fitness Tracker Application
Write-Host "Stopping Fitness Tracker on EKS..." -ForegroundColor Yellow

# Scale down all deployments to 0
Write-Host "`nScaling down all services..." -ForegroundColor Yellow
kubectl scale deployment config-server eureka-server user-service activity-service ai-service api-gateway --replicas=0 -n fitness-tracker

# Scale down MongoDB
kubectl scale statefulset mongodb --replicas=0 -n fitness-tracker

Write-Host "`nWaiting for pods to terminate (20 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Show status
Write-Host "`nCluster Status:" -ForegroundColor Green
kubectl get pods -n fitness-tracker

Write-Host "`n✅ Fitness Tracker has been stopped!" -ForegroundColor Green
Write-Host "Run './start-cluster.ps1' to start it again." -ForegroundColor Cyan
