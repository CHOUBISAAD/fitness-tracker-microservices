# Fitness Tracker - Status Check Script

Write-Host "🔍 Checking service status..." -ForegroundColor Cyan
Write-Host ""

# Check Docker
try {
    docker ps > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📊 Container Status:" -ForegroundColor Cyan
Write-Host ""

docker-compose ps

Write-Host ""
Write-Host "🏥 Health Checks:" -ForegroundColor Cyan
Write-Host ""

$services = @(
    @{Name="Eureka Server"; Url="http://localhost:8761/actuator/health"},
    @{Name="Config Server"; Url="http://localhost:8888/actuator/health"},
    @{Name="User Service"; Url="http://localhost:8081/actuator/health"},
    @{Name="Activity Service"; Url="http://localhost:8082/actuator/health"},
    @{Name="AI Service"; Url="http://localhost:8083/actuator/health"},
    @{Name="API Gateway"; Url="http://localhost:8080/actuator/health"},
    @{Name="Frontend"; Url="http://localhost:3000/health"},
    @{Name="Keycloak"; Url="http://localhost:8181/health/ready"},
    @{Name="RabbitMQ"; Url="http://localhost:15672"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -TimeoutSec 2 -UseBasicParsing 2>$null
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) - Healthy" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $($service.Name) - Unknown status" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($service.Name) - Not responding" -ForegroundColor Red
    }
}

Write-Host ""
