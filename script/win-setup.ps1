# Install chocolatey
Write-Output "Installing chocolatey package manager..."
# Set-ExecutionPolicy Bypass -Scope Process -Force
Set-ExecutionPolicy AllSigned -Scope Process -Force
# runas /noprofile /user:Administrator Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
irm 'https://chocolatey.org/install.ps1' | runas /noprofile /user:Administrator iex

# Install scoop.sh
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Set up additional scoop buckets
# scoop bucket add extras
# scoop bucket add Ash258 ‘https://github.com/Ash258/Scoop-Ash258.git’
# scoop bucket add TheRandomLabs https://github.com/TheRandomLabs/Scoop-Bucket.git

# Install tools from Scoop
# scoop install yq
# scoop install jq
scoop install 1password-cli
scoop install git

# Install version(s) of python
# scoop install pyenv
# pyenv update
# pyenv install -q 3.11.0
# pyenv global 3.11.0
# Explicitly set the path to the pyenv shims at the beginning of the PATH. By default, it gets appended to the end of the PATH.
# This ensures that the pyenv shims are used instead of the python installed by mingw, which is located at C:\ProgramData\chocolatey\bin\python.exe.
# [Environment]::SetEnvironmentVariable("Path", "C:\Users\Administrator\.pyenv\pyenv-win\bin;C:\Users\Administrator\.pyenv\pyenv-win\shims;" + [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine), [System.EnvironmentVariableTarget]::Machine)

# Install version(s) of golang
# scoop install go

# no mismatched line endings
git config --system core.autocrlf false

# TODO: follow https://github.com/chocolatey-community/chocolatey-packages/issues/1773
# choco install 1password

choco install brave
choco install epicgameslauncher
choco install firefox
choco install goggalaxy
choco install retroarch
choco install slack
choco install steam
