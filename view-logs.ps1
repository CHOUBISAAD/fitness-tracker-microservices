# View logs for a specific service
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('config-server', 'eureka-server', 'user-service', 'activity-service', 'ai-service', 'api-gateway', 'mongodb')]
    [string]$Service,
    
    [Parameter(Mandatory=$false)]
    [int]$Lines = 100
)

Write-Host "Viewing logs for $Service (last $Lines lines)..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to exit`n" -ForegroundColor Cyan

if ($Service -eq 'mongodb') {
    kubectl logs mongodb-0 -n fitness-tracker --tail=$Lines -f
} else {
    kubectl logs deployment/$Service -n fitness-tracker --tail=$Lines -f
}
