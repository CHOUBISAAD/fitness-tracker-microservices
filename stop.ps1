# Fitness Tracker - Stop Script

Write-Host "🛑 Stopping Fitness Tracker services..." -ForegroundColor Yellow

docker-compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All services stopped" -ForegroundColor Green
} else {
    Write-Host "❌ Error stopping services" -ForegroundColor Red
    exit 1
}

Write-Host ""
$response = Read-Host "Remove volumes (databases will be wiped)? [y/N]"

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "🗑️  Removing volumes..." -ForegroundColor Yellow
    docker-compose down -v
    Write-Host "✅ Volumes removed" -ForegroundColor Green
}
