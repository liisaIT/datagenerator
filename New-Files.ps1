# New-Files.ps1
# Failide genereerimine

param(
    [int]$Count
)

if (-not $Count -or $Count -le 0) {

    do {
        $inputValue = Read-Host "Mitu faili soovid genereerida?"

        if ($inputValue -match "^\d+$" -and [int]$inputValue -gt 0) {
            $Count = [int]$inputValue
            $valid = $true
        }
        else {
            Write-Host "Palun sisesta korrektne arv!" -ForegroundColor Yellow
            $valid = $false
        }

    } while (-not $valid)
}


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# sisend
$filenames = Get-Content (Join-Path $PSScriptRoot "source\failinimed.txt") | ForEach-Object { $_.Trim() }
$extensions = Get-Content (Join-Path $PSScriptRoot "source\faililaiendid.txt") | ForEach-Object { $_.Trim() }

# Kaust failidele
$filesFolder = Join-Path $PSScriptRoot "files"

if (-not (Test-Path $filesFolder)) {
    New-Item -ItemType Directory -Path $filesFolder | Out-Null
}

#oluline – enne kasutamist!
$usedNames = @()

#failide loomine
for ($i = 0; $i -lt $Count; $i++) {

    $isInvalid = (Get-Random -Minimum 1 -Maximum 101) -le 20

    $name = Get-Random $filenames
    $ext = Get-Random $extensions

    # puhastamine
    $cleanName = $name -replace "[- ]", ""

    $cleanName = $cleanName `
        -replace "ä","a" -replace "ö","o" -replace "ü","u" -replace "õ","o"

    # failinimi
    if ($isInvalid) {
        $type = Get-Random -Minimum 1 -Maximum 6

        switch ($type) {
            1 { $filename = $cleanName }                         # laiend puudub
            2 { $filename = ($cleanName + "." + $ext).ToUpper() } # suured tähed
            3 { $filename = ($name + "." + $ext) }                # täpitähed sees
            4 { $filename = ($cleanName + "@" + $ext) }           # vale märk
            5 { $filename = ($cleanName + "." + $ext + ".x") }    # liiga palju punkte
        }
    }
    else {
        $filename = ($cleanName + "." + $ext).ToLower()
    }

    #  duplikaadi kontroll
    if ($usedNames -contains $filename) {
        $i--
        continue
    }

    $usedNames += $filename

    $filePath = Join-Path $filesFolder $filename

    # faili suurus
    if ($isInvalid) {
        $size = Get-Random -Minimum 1025 -Maximum 2048   # vale suurus
    }
    else {
        $size = Get-Random -Minimum 1 -Maximum 1024
    }

    # sisu loomine
    $content = "A" * $size
    Set-Content -Path $filePath -Value $content

    Write-Host "Loodud fail: $filename ($size bytes)"

    # progressbar
    $percent = [int](($i + 1) / $Count * 100)

    Write-Progress `
        -Activity "Failide genereerimine" `
        -Status "Töötlen: $filename" `
        -PercentComplete $percent

    Start-Sleep -Milliseconds 100
}

Write-Host "Failid loodud kausta: $filesFolder"