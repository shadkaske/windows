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

