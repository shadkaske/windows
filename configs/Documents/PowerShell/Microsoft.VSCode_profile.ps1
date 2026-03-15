Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Import-Module posh-git

# Optional: Set default key bindings for history search (Ctrl+r), file search (Ctrl+t), and directory change (Alt+c)
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordCd 'Alt+c'
# Optional: Enable tab expansion
Set-PSFzfOption -TabExpansion

Invoke-Expression (&starship init powershell)
