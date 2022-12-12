# Install chocolatey
Write-Output "Installing chocolatey package manager..."
# Set-ExecutionPolicy Bypass -Scope Process -Force
Set-ExecutionPolicy AllSigned -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# TODO: follow https://github.com/chocolatey-community/chocolatey-packages/issues/1773
# choco install 1password

choco install brave
choco install epicgameslauncher
choco install firefox
choco install goggalaxy
choco install retroarch
choco install slack
choco install steam
