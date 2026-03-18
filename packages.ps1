function Install-Application {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$AppObject
    )

    Clear-Host
    Write-Host "`e[1;34mInstalling $($AppObject.Name)...`e[0m"

    winget install -e --id $AppObject.Identifier --source $AppObject.Source --accept-package-agreements --silent
    Start-Sleep -Seconds 0.7
}

# Array of applications to install
$applications = @(
    [PSCustomObject]@{ Name = "DBeaver CE"; Identifier = "9PNKDR50694P"; Source = "msstore" },
    [PSCustomObject]@{ Name = "Docker Desktop"; Identifier = "XP8CBJ40XLBWKX"; Source = "msstore" },
    # [PSCustomObject]@{ Name = "Outlook for Windows"; Identifier = "9NRX63209R7B"; Source = "msstore" },
    [PSCustomObject]@{ Name = "Visual Studio Code"; Identifier = "XP9KHM4BK9FZ7Q"; Source = "msstore" },
    # [PSCustomObject]@{ Name = "Bitwarden CLI"; Identifier = "Bitwarden.CLI"; Source = "winget" },
    [PSCustomObject]@{ Name = "Bitwarden"; Identifier = "Bitwarden.Bitwarden"; Source = "winget" },
    # [PSCustomObject]@{ Name = "Bruno"; Identifier = "Bruno.Bruno"; Source = "winget" },
    [PSCustomObject]@{ Name = "Ditto"; Identifier = "Ditto.Ditto"; Source = "winget" },
    [PSCustomObject]@{ Name = "Git"; Identifier = "Git.Git"; Source = "winget" },
    [PSCustomObject]@{ Name = "GlazeWM"; Identifier = "glzr-io.glazewm"; Source = "winget" },
    [PSCustomObject]@{ Name = "Google Chrome"; Identifier = "Google.Chrome"; Source = "winget" },
    [PSCustomObject]@{ Name = "JetBrains Toolbox"; Identifier = "JetBrains.Toolbox"; Source = "winget" },
    [PSCustomObject]@{ Name = "Kanata GUI"; Identifier = "jtroo.kanata_gui"; Source = "winget" },
    [PSCustomObject]@{ Name = "Mozilla Firefox"; Identifier = "Mozilla.Firefox"; Source = "winget" },
    [PSCustomObject]@{ Name = "Neovim"; Identifier = "Neovim.Neovim"; Source = "winget" },
    [PSCustomObject]@{ Name = "Node.js"; Identifier = "OpenJS.NodeJS.LTS"; Source = "winget" },
    [PSCustomObject]@{ Name = "Obsidian"; Identifier = "Obsidian.Obsidian"; Source = "winget" },
    [PSCustomObject]@{ Name = "PHPStorm"; Identifier = "JetBrains.PhpStorm"; Source = "winget" },
    [PSCustomObject]@{ Name = "PowerShell 7-x64"; Identifier = "Microsoft.PowerShell"; Source = "winget" },
    [PSCustomObject]@{ Name = "PowerToys (Preview) x64"; Identifier = "Microsoft.PowerToys"; Source = "winget" },
    [PSCustomObject]@{ Name = "Python 3.14.3 (64-bit)"; Identifier = "Python.Python.3.14"; Source = "winget" },
    [PSCustomObject]@{ Name = "RealVNC Connect"; Identifier = "RealVNC.RealVNCConnct"; Source = "winget" },
    [PSCustomObject]@{ Name = "RipGrep GNU"; Identifier = "BurntSushi.ripgrep.GNU"; Source = "winget" },
    [PSCustomObject]@{ Name = "SQL Server Management Studio 22"; Identifier = "Microsoft.SQLServerManagementStudio.22"; Source = "winget" }
    [PSCustomObject]@{ Name = "Tailscale"; Identifier = "Tailscale.Tailscale"; Source = "winget" },
    [PSCustomObject]@{ Name = "Visual Studio Professional 2026"; Identifier = "Microsoft.VisualStudio.Professional"; Source = "winget" }
    [PSCustomObject]@{ Name = "YASB Reborn"; Identifier = "AmN.yasb"; Source = "winget" },
    [PSCustomObject]@{ Name = "bat"; Identifier = "sharkdp.bat"; Source = "winget" },
    [PSCustomObject]@{ Name = "less"; Identifier = "jftuga.less"; Source = "winget" },
    [PSCustomObject]@{ Name = "fzf"; Identifier = "junegunn.fzf"; Source = "winget" },
    [PSCustomObject]@{ Name = "lazygit"; Identifier = "JesseDuffield.lazygit"; Source = "winget" },
    [PSCustomObject]@{ Name = "zellij"; Identifier = "JesseDuffield.arndawg.zellij-windows"; Source = "winget" },
    [PSCustomObject]@{ Name = "starship"; Identifier = "Starship.Starship"; Source = "winget" },
    [PSCustomObject]@{ Name = "zoxide"; Identifier = "ajeetdsouza.zoxide"; Source = "winget" }
)

# Loop through each application and install
foreach ($app in $applications) {
    Install-Application -AppObject $app
}

Clear-Host

# Install Powershell Modules
Install-Module -Name PSFzf -Scope CurrentUser -Force -WarningAction SilentlyContinue
Import-Module PSFzf -WarningAction SilentlyContinue
