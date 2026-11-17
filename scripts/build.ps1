<#
.SYNOPSIS  Cross-compile zagent for every supported platform into .\dist
.EXAMPLE   .\scripts\build.ps1 -Version 1.0.0
#>
param([string]$Version = "dev")
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
New-Item -ItemType Directory -Force dist | Out-Null
$originalOS = $env:GOOS
$originalArch = $env:GOARCH
$originalCGO = $env:CGO_ENABLED
try {
$env:CGO_ENABLED = "0"
foreach ($t in "windows/amd64","windows/arm64","linux/amd64","linux/arm64","darwin/amd64","darwin/arm64") {
    $os, $arch = $t.Split("/")
    $ext = if ($os -eq "windows") { ".exe" } else { "" }
    $env:GOOS = $os; $env:GOARCH = $arch
    Write-Host "building $t"
    go build -trimpath -ldflags "-s -w -X main.version=$Version" -o "dist/zagent-$os-$arch$ext" ./cmd/zagent
    if ($LASTEXITCODE -ne 0) { throw "build failed for $t" }
}
} finally {
    $env:GOOS = $originalOS
    $env:GOARCH = $originalArch
    $env:CGO_ENABLED = $originalCGO
}
Write-Host "done: $(Resolve-Path dist)"
