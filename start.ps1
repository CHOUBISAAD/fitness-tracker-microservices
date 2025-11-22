# Fitness Tracker - Docker Startup Script
# This script starts all services and waits for them to be healthy

Write-Host "🏋️ Starting Fitness Tracker Microservices..." -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  Warning: .env file not found!" -ForegroundColor Yellow
    Write-Host "Creating .env from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Edit .env and add your GEMINI_API_KEY before proceeding!" -ForegroundColor Red
    Write-Host "Press Enter when ready to continue..."
    Read-Host
}

# Check Docker is running
try {
    docker ps > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
} catch {
    Write-Host "❌ Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker is running" -ForegroundColor Green
Write-Host ""

# Stop existing containers
Write-Host "🛑 Stopping existing containers..." -ForegroundColor Yellow
docker-compose down 2>$null

Write-Host ""
Write-Host "🔨 Building and starting services..." -ForegroundColor Cyan
Write-Host "This will take 5-10 minutes on first run..." -ForegroundColor Yellow
Write-Host ""

# Start services
docker-compose up --build -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start services" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⏳ Waiting for services to become healthy..." -ForegroundColor Cyan
Write-Host ""

$maxWait = 300  # 5 minutes
$elapsed = 0
$interval = 10

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    
    $status = docker-compose ps --format json | ConvertFrom-Json
    $total = $status.Count
    $healthy = ($status | Where-Object { $_.Health -eq "healthy" -or $_.State -eq "running" }).Count
    
    $percentage = [math]::Round(($healthy / $total) * 100)
    Write-Host "[$elapsed/$maxWait s] $healthy/$total services ready ($percentage%)" -ForegroundColor Cyan
    
    if ($healthy -eq $total) {
        break
    }
}

Write-Host ""
Write-Host "✅ All services are running!" -ForegroundColor Green
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 Service Endpoints:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Frontend:           http://localhost:3000" -ForegroundColor White
Write-Host "🔌 API Gateway:        http://localhost:8080" -ForegroundColor White
Write-Host "🔍 Eureka Dashboard:   http://localhost:8761" -ForegroundColor White
Write-Host "🔐 Keycloak Admin:     http://localhost:8181 (admin/admin)" -ForegroundColor White
Write-Host "🐰 RabbitMQ UI:        http://localhost:15672 (guest/guest)" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  IMPORTANT: Configure Keycloak before using the app!" -ForegroundColor Yellow
Write-Host "   See DOCKER_DEPLOYMENT.md for Keycloak setup instructions" -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 View logs:" -ForegroundColor Cyan
Write-Host "   docker-compose logs -f [service-name]" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 Stop all services:" -ForegroundColor Cyan
Write-Host "   docker-compose down" -ForegroundColor Gray
Write-Host ""
