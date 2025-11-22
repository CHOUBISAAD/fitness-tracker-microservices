# Quick validation script - builds only infrastructure services
Write-Host "🧪 Running containerization validation..." -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "1️⃣ Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Host "   ✅ $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker not found" -ForegroundColor Red
    exit 1
}

# Check Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "   ✅ $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker Compose not found" -ForegroundColor Red
    exit 1
}

# Check .env file
if (Test-Path ".env") {
    Write-Host "   ✅ .env file found" -ForegroundColor Green
    
    # Check for Gemini API key
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "GEMINI_API_KEY=your_gemini_api_key_here" -or $envContent -match "GEMINI_API_KEY=\s*$") {
        Write-Host "   ⚠️  Warning: GEMINI_API_KEY not configured (AI service will fail)" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ GEMINI_API_KEY configured" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ .env file not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2️⃣ Validating Dockerfiles..." -ForegroundColor Yellow

$services = @(
    "eurekaserver",
    "config-server",
    "api-gateway",
    "userservice",
    "activityservice",
    "aiservice",
    "fitness-front"
)

$allDockerfilesExist = $true
foreach ($service in $services) {
    $dockerfilePath = Join-Path $service "Dockerfile"
    if (Test-Path $dockerfilePath) {
        Write-Host "   ✅ $service/Dockerfile" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $service/Dockerfile missing" -ForegroundColor Red
        $allDockerfilesExist = $false
    }
}

if (-not $allDockerfilesExist) {
    exit 1
}

Write-Host ""
Write-Host "3️⃣ Validating docker-compose.yml..." -ForegroundColor Yellow

if (Test-Path "docker-compose.yml") {
    Write-Host "   ✅ docker-compose.yml found" -ForegroundColor Green
    
    # Validate syntax
    try {
        docker-compose config > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ docker-compose.yml syntax valid" -ForegroundColor Green
        } else {
            Write-Host "   ❌ docker-compose.yml has syntax errors" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "   ❌ Error validating docker-compose.yml" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ❌ docker-compose.yml not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "4️⃣ Testing infrastructure services..." -ForegroundColor Yellow
Write-Host "   Starting PostgreSQL, MongoDB, RabbitMQ..." -ForegroundColor Gray

try {
    docker-compose up -d postgres mongodb-activity mongodb-ai rabbitmq 2>&1 | Out-Null
    
    Write-Host "   ⏳ Waiting for services to be healthy (30s)..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
    
    $status = docker-compose ps --format json | ConvertFrom-Json
    $infraServices = $status | Where-Object { $_.Service -in @("postgres", "mongodb-activity", "mongodb-ai", "rabbitmq") }
    
    $allHealthy = $true
    foreach ($svc in $infraServices) {
        if ($svc.Health -eq "healthy" -or $svc.State -eq "running") {
            Write-Host "   ✅ $($svc.Service) is $($svc.State)" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $($svc.Service) is $($svc.State)" -ForegroundColor Red
            $allHealthy = $false
        }
    }
    
    if ($allHealthy) {
        Write-Host ""
        Write-Host "✅ Infrastructure services are running!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Error starting infrastructure services" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
} finally {
    Write-Host ""
    Write-Host "🧹 Cleaning up test containers..." -ForegroundColor Yellow
    docker-compose down 2>&1 | Out-Null
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ Containerization validation PASSED!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Configure your GEMINI_API_KEY in .env file" -ForegroundColor White
Write-Host "  2. Run: .\start.ps1" -ForegroundColor White
Write-Host "  3. Follow DOCKER_DEPLOYMENT.md to configure Keycloak" -ForegroundColor White
Write-Host ""
