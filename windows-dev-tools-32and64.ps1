# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
# Check and Set Execution Policy
function Set-ExecutionPolicy-RemoteSigned {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -ne 'RemoteSigned') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy set to RemoteSigned."
    } else {
        Write-Host "Execution policy is already set to RemoteSigned."
    }
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "You'll need at least PowerShell version 5. To determine your version, open PowerShell and type:"
    Write-Host "$PSVersionTable.PSVersion.ToString()"
    Write-Host "If you have an older version, you can upgrade it following these instructions: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell"
    exit
}

# Determine OS architecture
$is64Bit = [Environment]::Is64BitOperatingSystem

# Define the PHP versions and URLs
$phpVersions = @{
    "7.4.33" = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip" } else { "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x86.zip" }
    "8.0.30" = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-8.0.30-Win32-vs16-x64.zip" } else { "https://windows.php.net/downloads/releases/php-8.0.30-Win32-vs16-x86.zip" }
    "8.1.29" = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-8.1.29-Win32-vs16-x64.zip" } else { "https://windows.php.net/downloads/releases/php-8.1.29-Win32-vs16-x86.zip" }
    "8.2.20" = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-8.2.20-Win32-vs16-x64.zip" } else { "https://windows.php.net/downloads/releases/php-8.2.20-Win32-vs16-x86.zip" }
    "8.3.8"  = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip" } else { "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x86.zip" }
}

$pythonVersions = @{
    "3.8.10" = if ($is64Bit) { "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe" } else { "https://www.python.org/ftp/python/3.8.10/python-3.8.10.exe" }
    "3.9.13" = if ($is64Bit) { "https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe" } else { "https://www.python.org/ftp/python/3.9.13/python-3.9.13.exe" }
    "3.10.7" = if ($is64Bit) { "https://www.python.org/ftp/python/3.10.7/python-3.10.7-amd64.exe" } else { "https://www.python.org/ftp/python/3.10.7/python-3.10.7.exe" }
    "3.11.4" = if ($is64Bit) { "https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe" } else { "https://www.python.org/ftp/python/3.11.4/python-3.11.4.exe" }
    "3.12.3" = if ($is64Bit) { "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe" } else { "https://www.python.org/ftp/python/3.12.3/python-3.12.3.exe" }
}

# Display menu
function Show-Menu {
    cls
    Write-Host "Select an option to install:"
    Write-Host "1. Install PHP"
    Write-Host "2. Install Composer"
    Write-Host "3. Install Node.js"
    Write-Host "4. Install npm"
    Write-Host "5. Install pnpm"
    Write-Host "6. Install Yarn"
    Write-Host "7. Install Docker Desktop"
    Write-Host "8. Install Git and Configure SSH for GitHub"
    Write-Host "9. Install Python"
    Write-Host "10. Exit"
}

function Show-PHPVersions {
    Write-Host "Select PHP version to install:"
    $phpVersions.Keys | ForEach-Object { Write-Host "$($_)" }
    Write-Host "Back to main menu (type 'menu')"
}

function Show-PythonSubMenu {
    Write-Host "Select Python version to install:"
    Write-Host "1. Python 3.8.10"
    Write-Host "2. Python 3.9.13"
    Write-Host "3. Python 3.10.7"
    Write-Host "4. Python 3.11.4"
    Write-Host "5. Python 3.12.3"
    Write-Host "6. LTS (Long Term Support)"
    Write-Host "7. Specify a version"
    Write-Host "Back to main menu (type 'menu')"
}

function Show-NodeSubMenu {
    Write-Host "Install Node.js:"
    Write-Host "1. Via nvm"
    Write-Host "2. Natively"
    Write-Host "Back to main menu (type 'menu')"
}

function Show-NodeInstallOptions {
    Write-Host "Install Node.js:"
    Write-Host "1. Specify a version"
    Write-Host "2. Install latest version"
    Write-Host "Back to previous menu (type 'menu')"
}

# Add to PATH
function Add-ToPath {
    param (
        [string]$newPath
    )
    $envPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($envPath -notmatch [regex]::Escape($newPath)) {
        [System.Environment]::SetEnvironmentVariable('Path', "$envPath;$newPath", 'Machine')
        Write-Host "$newPath has been added to the system PATH. Please restart your terminal or log out and log back in for the changes to take effect."
    } else {
        Write-Host "$newPath already exists in the system PATH."
    }
    $env:Path = "$env:Path;$newPath"
}

# Check if a command exists and get its version
function Get-CommandVersion {
    param (
        [string]$command,
        [string]$versionArg = "--version"
    )
    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd) {
        return & $command $versionArg
    } else {
        return $null
    }
}

# Install PHP
function Install-PHP {
    param (
        [string]$phpVersion,
        [string]$phpUrl
    )
    $currentVersion = Get-CommandVersion -command "php" -versionArg "-v"
    if ($currentVersion) {
        Write-Host "PHP is already installed: $currentVersion"
        $confirm = Read-Host "Do you really want to reinstall PHP? (y/n)"
        if ($confirm -ne 'y') {
            return
        }
    }

    $installPath = "C:\Program Files\PHP\php-$phpVersion"
    if (-Not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null
    }
    $zipPath = "$installPath\php.zip"
    Invoke-WebRequest -Uri $phpUrl -OutFile $zipPath
    try {
        Expand-Archive -Path $zipPath -DestinationPath $installPath -Force
        Remove-Item $zipPath
        Add-ToPath -newPath $installPath
        Write-Host "PHP $phpVersion installation completed successfully!"
    } catch {
        Write-Host "Failed to extract PHP zip file. Error: $_"
    }

    # Check installation success
    $installedVersion = Get-CommandVersion -command "php" -versionArg "-v"
    if ($installedVersion -and $installedVersion -match $phpVersion) {
        Write-Host "PHP $phpVersion has been installed successfully."
    } else {
        Write-Host "Failed to install PHP $phpVersion."
    }
}

# Install Docker Desktop
function Install-Docker-Desktop {
    $url = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    $installerPath = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Start-Process -FilePath $installerPath -Wait
    if ($?) {
        Write-Host "Docker Desktop has been installed successfully."
    } else {
        Write-Host "Failed to install Docker Desktop."
    }
}

# Enable WSL2
function Enable-WSL2 {
    wsl --set-default-version 2
    if ($?) {
        Write-Host "WSL2 has been enabled successfully."
    } else {
        Write-Host "Failed to enable WSL2."
    }
}

# Configure Docker Desktop
function Configure-Docker-Desktop {
    Start-Process "Docker Desktop" -Verb runAs
    Start-Sleep -Seconds 60  # Wait for Docker Desktop to start
    $settings = @{
        "useWsl2" = $true
        "wslDistroName" = "Ubuntu"
    }
    $settings | ConvertTo-Json | Out-File -FilePath "$env:APPDATA\Docker\settings.json" -Encoding utf8
    Stop-Process -Name "Docker Desktop"
    Start-Process "Docker Desktop" -Verb runAs
    Write-Host "Docker Desktop has been configured successfully."
}

# Set WSL distro version
function Set-WSL-Distro-Version {
    param (
        [string]$distroName
    )
    wsl --set-version $distroName 2
    if ($?) {
        Write-Host "WSL distro version has been set successfully."
    } else {
        Write-Host "Failed to set WSL distro version."
    }
}

# Configure WSL integration
function Configure-WSL-Integration {
    $integrations = @{
        "enabledDistributions" = @("Ubuntu")
    }
    $integrations | ConvertTo-Json | Out-File -FilePath "$env:APPDATA\Docker\integrations.json" -Encoding utf8
    Stop-Process -Name "Docker Desktop"
    Start-Process "Docker Desktop" -Verb runAs
    Write-Host "WSL integration has been configured successfully."
}

# Install Git
function Install-Git {
    $url = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.36.1.1-64-bit.exe"
    $installerPath = "$env:TEMP\GitInstaller.exe"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Git has been installed successfully."
    } else {
        Write-Host "Failed to install Git."
    }
}

# Configure SSH for GitHub
function Configure-SSH-For-GitHub {
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-Not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir
    }
    $keyPath = "$sshDir\id_rsa"
    if (Test-Path $keyPath) {
        $overwrite = Read-Host "An existing SSH key pair was found. Do you want to overwrite it? (y/n)"
        if ($overwrite -ne 'y') {
            Write-Host "Exiting without creating a new SSH key pair."
            return
        }
    }
    $email = Read-Host "Enter your email address for the SSH key"
    ssh-keygen -t rsa -b 4096 -C $email -f $keyPath -N ""
    Start-Process -FilePath "powershell" -ArgumentList "Start-Process ssh-agent -Verb runAs"
    Start-Process -FilePath "powershell" -ArgumentList "ssh-add $keyPath"
    Write-Host "Your new SSH public key has been generated:"
    Get-Content "$keyPath.pub"
    Write-Host "Copy the above SSH key and add it to your GitHub account under Settings > SSH and GPG keys."
}

# Install Composer
function Install-Composer {
    $url = "https://getcomposer.org/Composer-Setup.exe"
    $installerPath = "$env:TEMP\Composer-Setup.exe"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Composer has been installed successfully."
    } else {
        Write-Host "Failed to install Composer."
    }
}

# Install nvm and Node.js
function Install-Nvm-Node {
    $nvmInstallScript = "https://raw.githubusercontent.com/coreybutler/nvm-windows/master/nvm-setup.exe"
    $installerPath = "$env:TEMP\nvm-setup.exe"
    Invoke-WebRequest -Uri $nvmInstallScript -OutFile $installerPath
    Start-Process -FilePath $installerPath -Wait
    if ($?) {
        nvm install latest
        nvm use latest
        npm install -g npm
        Write-Host "nvm and Node.js have been installed successfully."
    } else {
        Write-Host "Failed to install nvm and Node.js."
    }
}

# Install Yarn or pnpm
function Install-Yarn-Pnpm {
    $choice = Read-Host "Do you want to install Yarn, pnpm, or none? (yarn/pnpm/none)"
    if ($choice -eq 'yarn') {
        npm install -g yarn
        Write-Host "Yarn has been installed successfully."
    } elseif ($choice -eq 'pnpm') {
        npm install -g pnpm
        Write-Host "pnpm has been installed successfully."
    } else {
        Write-Host "No additional package manager will be installed."
    }
}

# Install Python
function Install-Python {
    param (
        [string]$pythonVersion,
        [string]$pythonUrl
    )
    $installerPath = "$env:TEMP\python-$pythonVersion.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    if ($?) {
        Write-Host "Python $pythonVersion has been installed successfully."
    } else {
        Write-Host "Failed to install Python."
    }
}

# Main menu logic
while ($true) {
    Set-ExecutionPolicy-RemoteSigned
    Show-Menu
    $choice = Read-Host "Enter your choice (1-10)"
    switch ($choice) {
        1 {
            Show-PHPVersions
            $phpChoice = Read-Host "Enter your choice or 'menu' to return to the main menu"
            if ($phpChoice -eq 'menu') { continue }
            if ($phpVersions.ContainsKey($phpChoice)) {
                Install-PHP -phpVersion $phpChoice -phpUrl $phpVersions[$phpChoice]
            } else {
                Write-Host "Invalid choice. Please try again."
            }
        }
        2 {
            Install-Composer
        }
        3 {
            Show-NodeSubMenu
            $nodeChoice = Read-Host "Enter your choice (1-2) or 'menu' to return to the main menu"
            if ($nodeChoice -eq 'menu') { continue }
            switch ($nodeChoice) {
                1 {
                    Show-NodeInstallOptions
                    $installChoice = Read-Host "Enter your choice (1-2) or 'menu' to return to the previous menu"
                    if ($installChoice -eq 'menu') { continue }
                    switch ($installChoice) {
                        1 {
                            Install-Node-With-Nvm -nodeVersion (Read-Host "Enter the Node.js version to install (e.g., 14.17.0, latest, lts)")
                        }
                        2 {
                            Install-Latest-Node-Natively
                        }
                        default {
                            Write-Host "Invalid choice. Please try again."
                        }
                    }
                }
                2 {
                    Show-NodeInstallOptions
                    $installChoice = Read-Host "Enter your choice (1-2) or 'menu' to return to the previous menu"
                    if ($installChoice -eq 'menu') { continue }
                    switch ($installChoice) {
                        1 {
                            Install-Custom-Node-Natively
                        }
                        2 {
                            Install-Latest-Node-Natively
                        }
                        default {
                            Write-Host "Invalid choice. Please try again."
                        }
                    }
                }
                default {
                    Write-Host "Invalid choice. Please try again."
                }
            }
        }
        4 {
            Install-npm
        }
        5 {
            Install-pnpm
        }
        6 {
            Install-Yarn
        }
        7 {
            Install-Docker-Desktop
            Enable-WSL2
            Configure-Docker-Desktop
            Set-WSL-Distro-Version -distroName "Ubuntu"
            Configure-WSL-Integration
        }
        8 {
            Install-Git
            Configure-SSH-For-GitHub
        }
        9 {
            Show-PythonSubMenu
            $pythonChoice = Read-Host "Enter your choice or 'menu' to return to the main menu"
            if ($pythonChoice -eq 'menu') { continue }
            switch ($pythonChoice) {
                1 { Install-Python -pythonVersion "3.8.10" -pythonUrl $pythonVersions["3.8.10"] }
                2 { Install-P
