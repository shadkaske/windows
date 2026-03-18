param (
    [switch]$Packages,
    [switch]$Fonts,
    [switch]$Configs,
    [switch]$Startup,
    [switch]$Help
)

if ($Help -or ($Packages -eq $false -and $Fonts -eq $false -and $Configs -eq $false -and $Startup -eq $false)) {
    Write-Host "Usage: .\system_config.ps1 [options]"
    Write-Host "Options:"
    Write-Host "  -Packages    Install packages and PowerShell modules"
    Write-Host "  -Fonts       Install Nerd Fonts"
    Write-Host "  -Configs     Create symbolic links for config files"
    Write-Host "  -Startup     Create Shell Startup Shortcuts"
    Write-Host "  -Help        Show this help message"
    Write-Host "Examples:"
    Write-Host "  .\system_config.ps1 -Packages -Fonts  # Install packages and fonts"
    Write-Host "  .\system_config.ps1 -Configs          # Link configs"
    exit
}

# Install packages if requested
if ($Packages) {
    . .\packages.ps1
}

# Install fonts if requested
if ($Fonts) {
    . .\fonts.ps1
}

# Link configs if requested
if ($Configs) {
    $userPath = $env:USERPROFILE
    $symlinkScript = Join-Path $PWD 'symlink_configs.ps1'
    $argString = "-NoProfile -ExecutionPolicy Bypass -File `"$symlinkScript`" -userPath `"$userPath`""
    Start-Process powershell -ArgumentList $argString -Verb RunAs -Wait
}

if ($Startup) {
    # Add GlazeWM to startup
    $glazewmPath = Get-ChildItem "$env:ProgramFiles" -Recurse -Filter glazewm.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if ($glazewmPath) {
        $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\StartUp"
        $shortcutPath = Join-Path $startupPath "GlazeWM.lnk"
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $glazewmPath
        $Shortcut.WorkingDirectory = $userPath
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
        $Shortcut.Arguments = '--cfg "' + $userPath + '\.config\kanata.kbd"'
        $Shortcut.WorkingDirectory = $userPath
        $Shortcut.Save()
        Write-Host "Added Kanata to startup."
    } else {
        Write-Host "Kanata executable not found, skipping startup shortcut."
    }
}