param (
    [switch]$Packages,
    [switch]$Fonts,
    [switch]$Configs,
    [switch]$Startup,
    [switch]$All,
    [switch]$Help
)

if ($All) {
    $Packages = $true
    $Fonts = $true
    $Configs = $true
    $Startup = $true
}

if ($Help -or ($Packages -eq $false -and $Fonts -eq $false -and $Configs -eq $false -and $Startup -eq $false)) {
    Write-Host "Usage: .\system_config.ps1 [options]"
    Write-Host "Options:"
    Write-Host "  -Packages    Install packages and PowerShell modules"
    Write-Host "  -Fonts       Install Nerd Fonts"
    Write-Host "  -Configs     Create symbolic links for config files"
    Write-Host "  -Startup     Create Shell Startup Shortcuts"
    Write-Host "  -All         Run all setup steps (equivalent to -Packages -Fonts -Configs -Startup)"
    Write-Host "  -Help        Show this help message"
    Write-Host "Examples:"
    Write-Host "  .\system_config.ps1 -Packages -Fonts  # Install packages and fonts"
    Write-Host "  .\system_config.ps1 -Fonts            # Install Configured Fonts"
    Write-Host "  .\system_config.ps1 -Configs          # Link configs"
    Write-Host "  .\system_config.ps1 -Startup          # Setup Run At Startup Items"
    Write-Host "  .\system_config.ps1 -All              # Run all setup steps"
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
    # Set User Environment Variable for HOME
    $gitHomePath = "$env:USERPROFILE\.config\git"
    $starshipPath = "$env:USERPROFILE\.config\starship\starship.toml"
    [System.Environment]::SetEnvironmentVariable("HOME", $gitHomePath, "User")
    [System.Environment]::SetEnvironmentVariable("STARSHIP_CONFIG", $starshipPath, "User")
    . .\junctions.ps1
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
        $Shortcut.Arguments = '--cfg "' + $env:USERPROFILE + '\.config\kanata\kanata.kbd"'
        $Shortcut.WorkingDirectory = $env:USERPROFILE
        $Shortcut.Save()
        Write-Host "Added Kanata to startup."
    } else {
        Write-Host "Kanata executable not found, skipping startup shortcut."
    }
}

# Disable Office Key Nonsense
# REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32
New-Item -Path "HKCU:\Software\Classes\ms-officeapp\Shell\Open" -Force
New-ItemProperty -Path "HKCU:\Software\Classes\ms-officeapp\Shell\Open" -Name "Command" -PropertyType String -Value "rundll32" -Force