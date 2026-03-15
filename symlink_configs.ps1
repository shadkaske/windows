# Script to create symbolic links for config files from configs/ to %USERPROFILE%

$configsDir = Join-Path $PSScriptRoot "configs"

if (!(Test-Path $configsDir)) {
    Write-Host "Configs directory not found: $configsDir"
    exit 1
}

# Get all files in configs recursively
$files = Get-ChildItem -Path $configsDir -File -Recurse

foreach ($file in $files) {
    # Get relative path
    $relativePath = $file.FullName -replace [regex]::Escape($configsDir), ''
    $relativePath = $relativePath.TrimStart('\')  # Remove leading backslash

    # Target path in USERPROFILE
    $targetPath = Join-Path $env:USERPROFILE $relativePath

    # Ensure target directory exists
    $targetDir = Split-Path $targetPath
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force
    }

    # Create symbolic link
    if (Test-Path $targetPath) {
        Write-Host "Target already exists, skipping: $targetPath"
        continue
    }

    New-Item -ItemType SymbolicLink -Path $targetPath -Target $file.FullName -Force
    Write-Host "Created symlink: $targetPath -> $($file.FullName)"
}