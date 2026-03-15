param (
    [switch]$Packages,
    [switch]$Fonts,
    [switch]$Configs,
    [switch]$Help
)

if ($Help -or ($Packages -eq $false -and $Fonts -eq $false -and $Configs -eq $false)) {
    Write-Host "Usage: .\system_config.ps1 [options]"
    Write-Host "Options:"
    Write-Host "  -Packages    Install packages and PowerShell modules"
    Write-Host "  -Fonts       Install Nerd Fonts"
    Write-Host "  -Configs     Create symbolic links for config files"
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
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PWD\symlink_configs.ps1" -Verb RunAs -Wait
}

