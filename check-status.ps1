# Check Fitness Tracker Status
Write-Host "Fitness Tracker Status on EKS" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

# Check pods
Write-Host "Pods Status:" -ForegroundColor Yellow
kubectl get pods -n fitness-tracker

# Check services
Write-Host "`nServices & LoadBalancers:" -ForegroundColor Yellow
kubectl get svc -n fitness-tracker

# Check PVCs
Write-Host "`nPersistent Volume Claims:" -ForegroundColor Yellow
kubectl get pvc -n fitness-tracker

Write-Host "`n================================" -ForegroundColor Green
Write-Host "To get API Gateway URL:" -ForegroundColor Cyan
Write-Host "kubectl get svc api-gateway -n fitness-tracker -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'" -ForegroundColor White
