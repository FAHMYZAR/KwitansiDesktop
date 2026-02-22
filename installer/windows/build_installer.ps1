param(
  [string]$ProjectRoot = "$(Resolve-Path "$PSScriptRoot/../..").Path"
)

$ErrorActionPreference = 'Stop'

Set-Location $ProjectRoot

$pubspec = Join-Path $ProjectRoot 'pubspec.yaml'
if (!(Test-Path $pubspec)) { throw "pubspec.yaml tidak ditemukan: $pubspec" }

$versionLine = (Get-Content $pubspec | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1)
if (-not $versionLine) { throw 'Versi tidak ditemukan di pubspec.yaml' }

$version = ($versionLine -replace '^version:\s*', '').Trim()
$version = ($version -split '\+')[0]

Write-Host "==> Build Flutter Windows release (v$version)"
flutter clean
flutter pub get
flutter build windows --release

$iss = Join-Path $ProjectRoot 'installer/windows/AlyaaFlorist.iss'
if (!(Test-Path $iss)) { throw "File ISS tidak ditemukan: $iss" }

$inno = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
if (!(Test-Path $inno)) {
  $inno = "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
}
if (!(Test-Path $inno)) {
  throw 'ISCC.exe tidak ditemukan. Install Inno Setup 6 dulu.'
}

Write-Host "==> Build installer Inno Setup"
& $inno "/DMyAppVersion=$version" $iss

Write-Host "Selesai. Output: dist/windows-installer/"
