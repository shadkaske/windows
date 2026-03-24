# Set direcotry highlighting to a sane value
$PSStyle.FileInfo.Directory = "`e[0;34m"

$env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship\starship.toml"

# Add Bitwarden CLI to PATH
# $bwPath = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter bw.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty DirectoryName
# if ($bwPath) {
#     $env:PATH += ";$bwPath"
# }

$batPath = Get-ChildItem $env:LOCALAPPDATA\Microsoft\WinGet\Packages -Recurse -Filter bat.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty DirectoryName
if ($batPath) {
    $env:PATH += ";$batPath"
}

$gitPath = Get-ChildItem $env:LOCALAPPDATA\Programs\Git -Recurse -Filter git.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty DirectoryName
if ($gitPath) {
    $env:PATH += ";$gitPath"
}

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force
Set-Alias -Name lg -Value lazygit -Option AllScope -Scope Global -Force
Set-Alias -Name ll -Value Get-Childitem -Option AllSCope -Scope Global -Force
Set-Alias -Name l -Value Get-Childitem -Option AllSCope -Scope Global -Force

Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Import-Module posh-git

# Optional: Set default key bindings for history search (Ctrl+r), file search (Ctrl+t), and directory change (Alt+c)
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordCd 'Alt+c'
# Optional: Enable tab expansion
Set-PSFzfOption -TabExpansion

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
