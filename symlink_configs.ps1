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

# Add GlazeWM to startup
$glazewmPath = Get-ChildItem "$env:ProgramFiles" -Recurse -Filter glazewm.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if ($glazewmPath) {
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\StartUp"
    $shortcutPath = Join-Path $startupPath "GlazeWM.lnk"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $glazewmPath
    $Shortcut.WorkingDirectory = $env:USERPROFILE
    $Shortcut.Save()
    Write-Host "Added GlazeWM to startup."
} else {
    Write-Host "GlazeWM executable not found, skipping startup shortcut."
}

# Add Kanata to startup
$kanataPath = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "kanata_windows_gui*cmd_allowed*x64.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if ($kanataPath) {
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\StartUp"
    $shortcutPath = Join-Path $startupPath "Kanata.lnk"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $kanataPath
    $Shortcut.Arguments = '--cfg "' + $env:USERPROFILE + '\.config\kanata.kbd"'
    $Shortcut.WorkingDirectory = $env:USERPROFILE
    $Shortcut.Save()
    Write-Host "Added Kanata to startup."
} else {
    Write-Host "Kanata executable not found, skipping startup shortcut."
}