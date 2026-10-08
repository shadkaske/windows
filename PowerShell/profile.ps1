# Set direcotry highlighting to a sane value
$PSStyle.FileInfo.Directory = "`e[0;34m"

$env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship\starship.toml"

# Add Bitwarden CLI to PATH
# $bwPath = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter bw.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty DirectoryName
# if ($bwPath) {
#     $env:PATH += ";$bwPath"
# }

# bat is already on the user PATH (winget adds it), so no lookup is needed here.

# Git\cmd is on the user PATH; also add Git\bin (bash, sh). A fixed path is faster than a recursive search.
$gitPath = "$env:LOCALAPPDATA\Programs\Git\bin"
if (Test-Path $gitPath) {
    $env:PATH += ";$gitPath"
}

# Add .Net to path
$env:PATH += ";C:\Windows\Microsoft.NET\Framework64\v4.0.30319"

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force
Set-Alias -Name lg -Value lazygit -Option AllScope -Scope Global -Force
Set-Alias -Name ll -Value Get-Childitem -Option AllSCope -Scope Global -Force
Set-Alias -Name l -Value Get-Childitem -Option AllSCope -Scope Global -Force

Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

Invoke-Expression (& { (zoxide init powershell | Out-String) })

# posh-git and PSFzf take ~1.2s to import, so load them once the prompt is idle instead of before it appears.
# Their tab completion and fzf key bindings become available a moment after the first prompt.
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Import-Module posh-git -Global

    # Optional: Set default key bindings for history search (Ctrl+r), file search (Ctrl+t), and directory change (Alt+c)
    Import-Module PSFzf -Global
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordCd 'Alt+c'
    # Optional: Enable tab expansion
    Set-PSFzfOption -TabExpansion
}

Invoke-Expression (&starship init powershell)

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
