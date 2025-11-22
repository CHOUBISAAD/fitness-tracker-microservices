# Fitness Tracker - View Logs Script

param(
    [string]$Service = "",
    [switch]$Follow = $false
)

if ($Service -eq "") {
    Write-Host "📋 Available services:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - eureka-server" -ForegroundColor White
    Write-Host "  - config-server" -ForegroundColor White
    Write-Host "  - api-gateway" -ForegroundColor White
    Write-Host "  - user-service" -ForegroundColor White
    Write-Host "  - activity-service" -ForegroundColor White
    Write-Host "  - ai-service" -ForegroundColor White
    Write-Host "  - frontend" -ForegroundColor White
    Write-Host "  - postgres" -ForegroundColor White
    Write-Host "  - mongodb-activity" -ForegroundColor White
    Write-Host "  - mongodb-ai" -ForegroundColor White
    Write-Host "  - rabbitmq" -ForegroundColor White
    Write-Host "  - keycloak" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage: .\logs.ps1 -Service <service-name> [-Follow]" -ForegroundColor Yellow
    Write-Host "Example: .\logs.ps1 -Service api-gateway -Follow" -ForegroundColor Gray
    exit 0
}

Write-Host "📋 Viewing logs for: $Service" -ForegroundColor Cyan
Write-Host ""

if ($Follow) {
    docker-compose logs -f $Service
} else {
    docker-compose logs --tail=100 $Service
}
