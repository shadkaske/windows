param (
    [switch]$PackagesOnly,
    [switch]$FontsOnly
)

# Install packages if requested
if ($PackagesOnly -or (!$FontsOnly)) {
    . .\packages.ps1
}

# Install fonts if requested
if ($FontsOnly -or (!$PackagesOnly)) {
    . .\fonts.ps1
}

# Ask user if they want to link configs
$linkConfigs = Read-Host "Do you want to link configs? (y/n)"
if ($linkConfigs -eq 'y' -or $linkConfigs -eq 'Y') {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PWD\symlink_configs.ps1" -Verb RunAs -Wait
}

