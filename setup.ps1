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

# Display menu
function Show-Menu {
    cls
    Write-Host "Select an option to install:"
    Write-Host "1. Install PHP"
    Write-Host "2. Install Composer"
    Write-Host "3. Install Node.js via nvm"
    Write-Host "4. Install npm"
    Write-Host "5. Install pnpm"
    Write-Host "6. Install Yarn"
    Write-Host "7. Install Git"
    Write-Host "8. DMA klonen und einrichten"
    Write-Host "9. Exit"
}

function Show-PHPVersions {
    Write-Host "Select PHP version to install:"
    $phpVersions.Keys | ForEach-Object { Write-Host "$($_)" }
    Write-Host "Back to main menu (type 'menu')"
}

# Add to PATH
function Add-ToPath {
    param (
        [string]$newPath
    )
    $envPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($envPath -notmatch [regex]::Escape($newPath)) {
        [System.Environment]::SetEnvironmentVariable('Path', "$newPath;$envPath", 'Machine')
        Write-Host "$newPath has been added to the system PATH. Please restart your terminal or log out and log back in for the changes to take effect."
    } else {
        Write-Host "$newPath already exists in the system PATH."
    }
    $env:Path = "$newPath;$env:Path"
}

# Remove from PATH
function Remove-FromPath {
    param (
        [string]$oldPath
    )
    $envPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $envPath = $envPath -replace [regex]::Escape($oldPath + ";"), ""
    [System.Environment]::SetEnvironmentVariable('Path', $envPath, 'Machine')
    Write-Host "$oldPath has been removed from the system PATH."
    $env:Path = $env:Path -replace [regex]::Escape($oldPath + ";"), ""
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
        # Remove the current PHP path from PATH
        $phpPath = (Get-Command "php").Path | Split-Path
        Remove-FromPath -oldPath $phpPath
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
        Add-ToPath -newPath "$installPath"
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

# Retry logic for Invoke-WebRequest
function Invoke-WebRequest-Retry {
    param (
        [string]$url,
        [string]$outputPath,
        [int]$maxRetries = 3,
        [int]$delaySeconds = 5
    )
    $attempt = 0
    $success = $false
    while (-not $success -and $attempt -lt $maxRetries) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $outputPath -ErrorAction Stop
            $success = $true
        } catch {
            $attempt++
            if ($attempt -lt $maxRetries) {
                Write-Host "Attempt $attempt failed. Retrying in $delaySeconds seconds..."
                Start-Sleep -Seconds $delaySeconds
            } else {
                Write-Host "Attempt $attempt failed. No more retries left."
                throw $_
            }
        }
    }
}

# Install Git
function Install-Git {
    $url = if ($is64Bit) { "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe" } else { "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-32-bit.exe" }
    $installerPath = "$env:TEMP\GitInstaller.exe"
    Invoke-WebRequest-Retry -url $url -outputPath $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Git has been installed successfully."
        Add-ToPath -newPath "C:\Program Files\Git\bin"
    } else {
        Write-Host "Failed to install Git."
    }
}

# Install Composer
function Install-Composer {
    $url = "https://getcomposer.org/Composer-Setup.exe"
    $installerPath = "$env:TEMP\Composer-Setup.exe"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Composer has been installed successfully."
        Add-ToPath -newPath "C:\ProgramData\ComposerSetup\bin"
    } else {
        Write-Host "Failed to install Composer."
    }
}

# Install nvm and Node.js
function Install-Nvm-Node {
    $nvmInstallScript = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.10/nvm-setup.exe"
    $installerPath = "$env:TEMP\nvm-setup.exe"
    Invoke-WebRequest-Retry -url $nvmInstallScript -outputPath $installerPath
    Start-Process -FilePath $installerPath -Wait
    if ($?) {
        Write-Host "nvm has been installed successfully."
        Add-ToPath -newPath "$env:APPDATA\nvm"
    } else {
        Write-Host "Failed to install nvm."
    }
}

# Install Yarn or pnpm
function Install-Yarn-Pnpm {
    param (
        [string]$choice
    )
    if ($choice -eq 'yarn') {
        npm install -g yarn
        Write-Host "Yarn has been installed successfully."
        Add-ToPath -newPath "$env:APPDATA\npm\node_modules\yarn\bin"
    } elseif ($choice -eq 'pnpm') {
        npm install -g pnpm
        Write-Host "pnpm has been installed successfully."
        Add-ToPath -newPath "$env:APPDATA\npm\node_modules\pnpm\bin"
    } else {
        Write-Host "No additional package manager will be installed."
    }
}

# DMA klonen und einrichten
function DMA-Klonen-und-Einrichten {
    $repoUrl = "https://github.com/healexsystems/cds"
    $branchName = "asz/dma-latest"
    $targetDir = Read-Host "Enter the target directory (leave blank to use the current directory)"
    
    if (-not $targetDir) {
        $targetDir = Get-Location
    }

    git clone --branch $branchName $repoUrl $targetDir
    if ($?) {
        Write-Host "Repository cloned successfully into $targetDir."
    } else {
        Write-Host "Failed to clone the repository."
    }
}

# Main menu logic
while ($true) {
    Set-ExecutionPolicy-RemoteSigned
    Show-Menu
    $choice = Read-Host "Enter your choice (1-9)"
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
            Install-Nvm-Node
        }
        4 {
            npm install -g npm
            Write-Host "npm has been installed successfully."
        }
        5 {
            Install-Yarn-Pnpm -choice 'pnpm'
        }
        6 {
            Install-Yarn-Pnpm -choice 'yarn'
        }
        7 {
            Install-Git
        }
        8 {
            DMA-Klonen-und-Einrichten
        }
        9 {
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}
