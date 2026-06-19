# New-Users.ps1
# Ülesanne - kasutajate loomine ja paroolid

param(
    [int]$Count = 10,
    [string]$FixedPassword = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Failid
$eesnimed = Get-Content (Join-Path $PSScriptRoot "source\eesnimed.txt") | ForEach-Object { $_.Trim() }
$perenimed = Get-Content (Join-Path $PSScriptRoot "source\perenimed.txt") | ForEach-Object { $_.Trim() }

# Tähed ja numbrid
$letters = @()
$letters += [char[]](65..90)
$letters += [char[]](97..122)

$numbers = 0..9
$specialChars = "!@#$%^&*".ToCharArray()

# Parooli funktsioon
function Generate-Password {
    $length = Get-Random -Minimum 8 -Maximum 15
    $password = Get-Random $letters
    $all = $letters + $numbers + $specialChars

    for ($i = 1; $i -lt $length; $i++) {
        $password += Get-Random $all
    }

    return $password
}

# CSV fail
$outfile = Join-Path $PSScriptRoot "users\new_users_accounts.csv"
"Eesnimi;Perenimi;Kasutajanimi;Parool" | Out-File $outfile

# 👉 oluline – enne kasutamist!
$usedUsernames = @()

# kasutajate loomine
for ($i = 0; $i -lt $Count; $i++) {

    $isInvalid = (Get-Random -Minimum 1 -Maximum 101) -le 20

    $fname = Get-Random $eesnimed
    $lname = Get-Random $perenimed

    # puhastamine
    $cleanEesnimi = $fname -replace "[- ]", ""
    $cleanPerenimi = $lname -replace "[- ]", ""

    $cleanEesnimi = $cleanEesnimi `
        -replace "ä","a" -replace "ö","o" -replace "ü","u" -replace "õ","o"

    $cleanPerenimi = $cleanPerenimi `
        -replace "ä","a" -replace "ö","o" -replace "ü","u" -replace "õ","o"

    # kasutajanimi
    if ($isInvalid) {
        $type = Get-Random -Minimum 1 -Maximum 7

        switch ($type) {
            1 { $username = ($cleanEesnimi + $cleanPerenimi) }
            2 { $username = ($cleanEesnimi + "." + $cleanPerenimi).ToUpper() }
            3 { $username = ($fname + "." + $lname) }
            4 { $username = ($cleanEesnimi + "@" + $cleanPerenimi) }
            5 { $username = ($cleanEesnimi + "." + $cleanPerenimi + ".x") }
            6 { $username = ($cleanEesnimi + " " + $cleanPerenimi) }
        }
    }
    else {
        $username = ($cleanEesnimi + "." + $cleanPerenimi).ToLower()
    }

    # 👉 duplikaadi kontroll
    if ($usedUsernames -contains $username) {
        $i--   # proovib uuesti
        continue
    }

    $usedUsernames += $username

    # parool
    if ($FixedPassword -ne "") {
        $password = $FixedPassword
    }
    else {
        $password = Generate-Password
    }

    # vigased paroolid
    if ($isInvalid) {
        $password = "test123"
    }

    # CSV
    "$fname;$lname;$username;$password" | Add-Content $outfile

    Write-Host "Loodud kasutaja: $username"

    #progressbar
    $percent = [int](($i + 1) / $Count * 100)

    Write-Progress `
    -Activity "Kasutajate genereerimine" `
    -Status "Töötlen: $username" `
    -PercentComplete $percent

    Start-Sleep -Milliseconds 130

}

Write-Host "Fail valmis: $outfile"