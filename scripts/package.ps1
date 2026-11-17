param([string]$Version = '0.1.1')
$ErrorActionPreference = 'Stop'
if ($Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$') { throw 'Invalid release version' }
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskDist = Join-Path $taskRoot 'dist'
New-Item -ItemType Directory -Force $taskDist | Out-Null
$taskStageRoot = Join-Path $taskDist ('.package-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $taskStageRoot | Out-Null
$originalOS = $env:GOOS; $originalArch = $env:GOARCH; $originalCGO = $env:CGO_ENABLED
$sums = @()
Push-Location $taskRoot
try {
    $env:CGO_ENABLED = '0'
    # Build archive helper for host so Unix archives retain executable permissions
    $env:GOOS = (go env GOHOSTOS).Trim(); $env:GOARCH = (go env GOHOSTARCH).Trim()
    $archiveHelper = Join-Path $taskStageRoot 'package-tar.exe'
    go build -trimpath -o $archiveHelper ./scripts/package-tar
    if ($LASTEXITCODE -ne 0) { throw 'Archive helper build failed' }

    foreach ($target in @('windows/amd64','windows/arm64','linux/amd64','linux/arm64','darwin/amd64','darwin/arm64')) {
        $targetOS, $targetArch = $target.Split('/')
        $name = "zagent-$Version-$targetOS-$targetArch"
        $stage = Join-Path $taskStageRoot $name
        New-Item -ItemType Directory $stage | Out-Null
        $binary = if ($targetOS -eq 'windows') { 'zagent.exe' } else { 'zagent' }
        $env:GOOS = $targetOS; $env:GOARCH = $targetArch
        Write-Host "building $target ($Version)"
        go build -trimpath -ldflags "-s -w -X main.version=$Version" -o (Join-Path $stage $binary) ./cmd/zagent
        if ($LASTEXITCODE -ne 0) { throw "Build failed for $target" }
        foreach ($file in @('README.md','CHANGELOG.md','LICENSE','.env.example')) {
            if (Test-Path -LiteralPath $file) { Copy-Item -LiteralPath $file -Destination $stage }
        }
        Copy-Item -LiteralPath docs,examples -Destination $stage -Recurse
        if ($targetOS -eq 'windows') {
            $archive = Join-Path $taskDist "$name.zip"
            Compress-Archive -LiteralPath $stage -DestinationPath $archive -Force
        } else {
            $archive = Join-Path $taskDist "$name.tar.gz"
            & $archiveHelper $stage $archive
            if ($LASTEXITCODE -ne 0) { throw "Archive failed for $target" }
        }
        $sums += "$((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLower())  $(Split-Path $archive -Leaf)"
    }
    $sums | Set-Content -LiteralPath (Join-Path $taskDist 'SHA256SUMS.txt') -Encoding ascii
    Write-Host "Packaged all release archives into $taskDist"
} finally {
    $env:GOOS = $originalOS; $env:GOARCH = $originalArch; $env:CGO_ENABLED = $originalCGO
    Pop-Location
    $resolvedStage = [IO.Path]::GetFullPath($taskStageRoot)
    $resolvedDist = [IO.Path]::GetFullPath($taskDist) + [IO.Path]::DirectorySeparatorChar
    if (!$resolvedStage.StartsWith($resolvedDist, [StringComparison]::OrdinalIgnoreCase)) { throw 'Stage cleanup escaped dist' }
    Remove-Item -LiteralPath $resolvedStage -Recurse -Force
}
