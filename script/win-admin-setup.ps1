# Install chocolatey
Write-Output "Installing chocolatey package manager..."
# Set-ExecutionPolicy Bypass -Scope Process -Force
Set-ExecutionPolicy AllSigned -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y 1password
choco install -y epicgameslauncher
choco install -y firefox
choco install -y geforce-experience
choco install -y goggalaxy
choco install -y moonlight
choco install -y myharmony
choco install -y obsidian
choco install -y slack
choco install -y steam
choco install -y sublimetext4
choco install -y sunshine
choco install -y yubikey-manager

# Disable Cortana
Get-AppxPackage -Name Microsoft.549981C3F5F10 -AllUsers | Remove-AppxPackage
