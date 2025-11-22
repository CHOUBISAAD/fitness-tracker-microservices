# Start Fitness Tracker Application
Write-Host "Starting Fitness Tracker on EKS..." -ForegroundColor Green

# Scale up core services
Write-Host "`nStarting core services (Config Server, Eureka, MongoDB)..." -ForegroundColor Yellow
kubectl scale deployment config-server --replicas=1 -n fitness-tracker
kubectl scale deployment eureka-server --replicas=1 -n fitness-tracker
kubectl scale statefulset mongodb --replicas=1 -n fitness-tracker

# Wait for core services to be ready
Write-Host "`nWaiting for core services to be ready (60 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Scale up microservices
Write-Host "`nStarting microservices..." -ForegroundColor Yellow
kubectl scale deployment user-service --replicas=1 -n fitness-tracker
kubectl scale deployment activity-service --replicas=1 -n fitness-tracker
kubectl scale deployment ai-service --replicas=1 -n fitness-tracker
kubectl scale deployment api-gateway --replicas=1 -n fitness-tracker

# Wait for microservices to be ready
Write-Host "`nWaiting for microservices to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Show status
Write-Host "`nCluster Status:" -ForegroundColor Green
kubectl get pods -n fitness-tracker

Write-Host "`n✅ Fitness Tracker is starting up!" -ForegroundColor Green
Write-Host "API Gateway will be available at: http://<LoadBalancer-URL>:8080" -ForegroundColor Cyan
Write-Host "Run 'kubectl get svc api-gateway -n fitness-tracker' to get the LoadBalancer URL" -ForegroundColor Cyan
