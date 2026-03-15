function Install-NerdFont {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FontName
    )

    # Check if any font files for this family are already installed
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    if (Get-ChildItem $fontDir -Filter "*$FontName*" -File -ErrorAction SilentlyContinue) {
        Write-Host "$FontName fonts already installed, skipping."
        return
    }

    Write-Host "Installing $FontName Nerd Font..."

    $tempDir = [System.IO.Path]::GetTempPath()
    $zipPath = Join-Path $tempDir "$FontName.zip"
    $extractPath = Join-Path $tempDir $FontName

    # Download the font zip
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip" -OutFile $zipPath

    # Extract the zip
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    # User fonts directory
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    if (!(Test-Path $fontDir)) {
        New-Item -ItemType Directory -Path $fontDir -Force
    }

    # Registry path for user fonts
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\EFonts"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force
    }

    # Install each .ttf file
    $fontFiles = Get-ChildItem $extractPath -Recurse -Filter *.ttf
    foreach ($fontFile in $fontFiles) {
        $fontFileName = [System.IO.Path]::GetFileName($fontFile.Name)
        $fontKeyName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile.Name)
        $destPath = Join-Path $fontDir $fontFileName

        if (Test-Path $destPath) {
            Write-Host "Font $fontFileName already installed, skipping."
            continue
        }

        Copy-Item $fontFile.FullName $destPath
        New-ItemProperty -Path $regPath -Name $fontKeyName -Value $fontFileName -PropertyType String -Force
    }

    # Clean up
    Remove-Item $zipPath -Force
    Remove-Item $extractPath -Recurse -Force

    Write-Host "$FontName Nerd Font installed successfully."
}

# Array of Nerd Fonts to install
$nerdFonts = @(
    "JetBrainsMono"
)

# Loop through each Nerd Font and install
foreach ($font in $nerdFonts) {
    Install-NerdFont -FontName $font
}