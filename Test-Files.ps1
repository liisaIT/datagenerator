# Test-Files.ps1
# Failide kontroll vastavalt kriteeriumitele:

param(
    [string]$FolderPath = ".\files"
)

# Logimine

$logFile = Join-Path $PSScriptRoot "logs\script-log.json"

# loo objekt
$logEntry = [PSCustomObject]@{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    script    = "Test-Files.ps1"
    arguments = @{
        FolderPath = $FolderPath
    }
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Failide lugemine
$files = Get-ChildItem $FolderPath -File

$total = $files.Count

# loendurid
$invalidNames = 0
$invalidSizes = 0
$validFiles = 0
$invalidExtensions = 0

$index = 0

$allowedExtensions = Get-Content (Join-Path $PSScriptRoot "source\faililaiendid.txt")

foreach ($file in $files) {

    $index++

    $filename = $file.Name
    $size = $file.Length

    #failinime kontroll

    $isValidName = $true

    $ext = $file.Extension.TrimStart('.')

    if ($ext -notin $allowedExtensions) {
        Write-Host "Lubamatu laiend: $filename"
    }

    # väiketähed
    if ($filename -notmatch "^[a-z0-9]+\.[a-z0-9]+$") {
        $isValidName = $false
    }

    # ei kasuta täpitähti
    if ($filename -match "[äöüõšž]") {
        $isValidName = $false
    }

    # ei tohi sisaldada keelatud märke
    if ($filename -match "[^a-z0-9\.]") {
        $isValidName = $false
    }

    if (-not $isValidName) {
        $invalidNames++
        Write-Host "Vigane failinimi: $filename"
    }

    # faili suuruse kontroll

    if ($size -lt 1 -or $size -gt 1024) {
        $invalidSizes++
        Write-Host "Vale faili suurus: $filename ($size bytes)"
    }

    if ($ext -notin $allowedExtensions) {
    $invalidExtensions++
    Write-Host "Lubamatu laiend: $filename"
    }
    # Korrektne fail

    if ($isValidName -and $size -ge 1 -and $size -le 1024) {
        $validFiles++
    }

    #progressbar

    $percent = [int](($index / $total) * 100)

    Write-Progress `
        -Activity "Failide kontrollimine" `
        -Status "[$index/$total] Kontrollin: $filename" `
        -PercentComplete $percent

    if ($total -le 50) {
        Start-Sleep -Milliseconds 50
    }
}

#kokkuvõte

Write-Host ""
Write-Host "=== Kokkuvõte ==="
Write-Host "Faile kokku: $total"
Write-Host "Vigased failinimed: $invalidNames"
Write-Host "Vale suurusega failid: $invalidSizes"
Write-Host "Korrektsed failid: $validFiles"
Write-Host "Lubamatu laiendiga failid: $invalidExtensions"
# logimine

if (Test-Path $logFile) {
    $existing = @(Get-Content $logFile | ConvertFrom-Json)
} else {
    $existing = @()
}

$existing += $logEntry

$existing | ConvertTo-Json -Depth 3 | Out-File $logFile