# Test-Users.ps1
# Kasutajate kontroll vastavalt kriteeriumitele:


param(
    [string]$FilePath = ".\users\new_users_accounts.csv"
)

# Logimine

$logFile = Join-Path $PSScriptRoot "logs\script-log.json"

# loo objekt
$logEntry = [PSCustomObject]@{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    script    = "Test-Users.ps1"
    arguments = @{
        FilePath = $FilePath
    }
}


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# CSV lugemine
$users = Import-Csv $FilePath -Delimiter ";"

$total = $users.Count

# loendurid
$invalidUsernames = 0
$weakPasswords = 0
$goodPasswords = 0
$strongPasswords = 0

$index = 0

foreach ($user in $users) {

    $index++

    $username = $user.Kasutajanimi
    $password = $user.Parool
    
    # Kasutajanimede kontroll 

    $isValidUsername = $true

    # peab olema kujul eesnimi.perenimi (ainult väiketähed)
    if ($username -notmatch "^[a-z]+\.[a-z]+$") {
        $isValidUsername = $false
    }

    # ei tohi sisaldada täpitähti
    if ($username -match "[äöüõšž]") {
        $isValidUsername = $false
    }

    # ei tohi sisaldada keelatud märke
    if ($username -match "[^a-z\.]") {
        $isValidUsername = $false
    }

    if (-not $isValidUsername) {
        $invalidUsernames++
        Write-Host "Vigane kasutajanimi: $username"
    }

    # Parooli kontroll 

    $length = $password.Length

    $hasUpper = $password -match "[A-Z]"
    $hasLower = $password -match "[a-z]"
    $hasNumber = $password -match "\d"
    $hasSpecial = $password -match "[^a-zA-Z0-9]"

    # nõrk parool
    if ($length -lt 10) {
        $weakPasswords++
        Write-Host "Nõrk parool: $password"
    }

    # tugev parool
    elseif ($length -ge 12 -and $length -le 15 -and $hasUpper -and $hasLower -and $hasNumber -and $hasSpecial) {
        $strongPasswords++
    }

    # keskmine parool
    else {
        $goodPasswords++
    }

    # Progressbar

    $percent = [int](($index / $total) * 100)

    Write-Progress `
        -Activity "Kasutajate kontrollimine" `
        -Status "[$index/$total] Kontrollin: $username" `
        -PercentComplete $percent

    if ($total -le 50) {
        Start-Sleep -Milliseconds 50
    }
}

# Tulemused

Write-Host ""
Write-Host "=== Kokkuvõte ==="
Write-Host "Kasutajaid kokku: $total"
Write-Host "Vigased kasutajanimed: $invalidUsernames"
Write-Host "Nõrgad paroolid: $weakPasswords"
Write-Host "Head paroolid: $goodPasswords"
Write-Host "Tugevad paroolid: $strongPasswords"

# salvesta JSON logisse
if (Test-Path $logFile) {
    $existing = @(Get-Content $logFile | ConvertFrom-Json)
} else {
    $existing = @()
}

$existing += $logEntry

$existing | ConvertTo-Json -Depth 3 | Out-File $logFile