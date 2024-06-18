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

# Display menu with pixel art
function Show-Menu {
    cls
    Write-Host "    __  ________  ___   _"
    Write-Host "   /  |/  /  _/ |/ / | / /"
    Write-Host "  / /|_/ // //    /  |/ / "
    Write-Host " /_/  /_/___/_/|_/|___/  "
    Write-Host " Magic installer"
    Write-Host "           .'\   /`."
    Write-Host "         .'.-.`-'.-.`."
    Write-Host "    ..._:   .-. .-.   :_..."
    Write-Host "  .'    '-.(o ) (o ).-'    `."
    Write-Host " :  _    _ _`~(_)~`_ _    _  :"
    Write-Host ":  /:   ' .-=_   _=-. `   ;\  :"
    Write-Host ":   :|-.._  '     `  _..-|:   :"
    Write-Host " :   `:| |`:-:-.-:-:'| |:'   :"
    Write-Host "  `.   `.| | | | | | |.'   .'"
    Write-Host "    `.   `-:_| | |_:-'   .'"
    Write-Host "      `-._   ````    _.-'"
    Write-Host " "
    Write-Host " Created by avnigashi"
    Write-Host " "
    Write-Host "Select an option to install:"
    Write-Host "1. Install PHP"
    Write-Host "2. Install Composer"
    Write-Host "3. Install Node.js via nvm"
    Write-Host "4. Install npm"
    Write-Host "5. Install pnpm"
    Write-Host "6. Install Yarn"
    Write-Host "7. Install Git"
    Write-Host "8. Install Docker"
    Write-Host "9. DMA klonen und einrichten"
    Write-Host "10. Exit"
}

# Show progress bar
function Show-ProgressBar {
    param (
        [string]$message,
        [int]$delaySeconds = 10
    )
    $progress = 0
    $increment = 100 / $delaySeconds
    Write-Host $message
    for ($i = 0; $i -lt $delaySeconds; $i++) {
        Write-Progress -Activity $message -PercentComplete $progress
        Start-Sleep -Seconds 1
        $progress += $increment
    }
    Write-Progress -Activity $message -Completed
}

# Show loading animation
function Show-LoadingAnimation {
    param (
        [string]$message,
        [int]$durationSeconds = 10
    )
    $animation = ("|", "/", "-", "\")
    $i = 0
    $end = [DateTime]::Now.AddSeconds($durationSeconds)
    while ([DateTime]::Now -lt $end) {
        Write-Host -NoNewline "`r$message $($animation[$i % $animation.Length])"
        Start-Sleep -Milliseconds 200
        $i++
    }
    Write-Host "`r$message done."
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
    Show-LoadingAnimation -message "Downloading Git" -durationSeconds 5
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
    Show-ProgressBar -message "Downloading Composer" -delaySeconds 5
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
    Show-LoadingAnimation -message "Downloading nvm" -durationSeconds 5
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
        Show-ProgressBar -message "Installing Yarn" -delaySeconds 5
        Write-Host "Yarn has been installed successfully."
        Add-ToPath -newPath "$env:APPDATA\npm\node_modules\yarn\bin"
    } elseif ($choice -eq 'pnpm') {
        npm install -g pnpm
        Show-ProgressBar -message "Installing pnpm" -delaySeconds 5
        Write-Host "pnpm has been installed successfully."
        Add-ToPath -newPath "$env:APPDATA\npm\node_modules\pnpm\bin"
    } else {
        Write-Host "No additional package manager will be installed."
    }
}

function Open-DockerDownloadPage {
    $url = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    Start-Process $url
    Write-Host "Docker download page has been opened in your browser."
}


# DMA klonen und einrichten
function DMA-Klonen-und-Einrichten {
    while ($true) {
        cls
        Write-Host "DMA klonen und einrichten:"
        Write-Host "1. DMA klonen"
        Write-Host "2. DMA einrichten"
        Write-Host "3. DMA starten"
        Write-Host "4. Zurück zum Hauptmenü"
        $subChoice = Read-Host "Enter your choice (1-4)"
        switch ($subChoice) {
            1 {
                DMA-Klonen
                Pause
            }
            2 {
                $projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
                if (-not $projectRoot) {
                    $projectRoot = Get-Location
                }
                DMA-Einrichten -projectRoot $projectRoot
                Pause
            }
            3 {
                $projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
                if (-not $projectRoot) {
                    $projectRoot = Get-Location
                }
                DMA-Starten -projectRoot $projectRoot
                Pause
            }
            4 {
                return
            }
            default {
                Write-Host "Invalid choice. Please try again."
            }
        }
    }
}

# DMA cloning
function DMA-Klonen {
    $repoUrl = "https://github.com/healexsystems/cds"
    $branchName = "asz/dma-latest"
    $targetDir = Read-Host "Enter the target directory (leave blank to use the current directory)"
    
    if (-not $targetDir) {
        $targetDir = (Get-Location).Path
    }

    Write-Host "Cloning repository from $repoUrl into $targetDir..."
    Show-LoadingAnimation -message "Cloning repository" -durationSeconds 10
    try {
        git clone --branch $branchName $repoUrl $targetDir
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Repository cloned successfully into $targetDir."
        } else {
            Write-Host "Failed to clone the repository."
        }
    } catch {
        Write-Host "Error cloning repository: $_"
    }
}

# DMA environment variables setup
function DMA-Einrichten {
    param (
        [string]$projectRoot
    )

    $projectRoot = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk"

    try {
        $envFilePath = Join-Path -Path $projectRoot -ChildPath "dev-ops\stacks\.env.template"
        $envDevFilePath = Join-Path -Path $projectRoot -ChildPath "dev-ops\stacks\.env.dev"
        $envBaseFilePath = Join-Path -Path $projectRoot -ChildPath "dev-ops\stacks\.env.base"

        Copy-Item -Path $envFilePath -Destination $envDevFilePath

        (Get-Content $envDevFilePath) -replace '^OIDC_CLIENT_ID=dma_ukk', '#OIDC_CLIENT_ID=dma_ukk' |
            Set-Content $envDevFilePath
        (Get-Content $envDevFilePath) -replace '^OIDC_CLIENT_SECRET=.*$', '#$&' |
            Set-Content $envDevFilePath
        Add-Content $envDevFilePath "`nOIDC_CLIENT_ID=cds_dev`nOIDC_CLIENT_SECRET=your_secret_here"

        Copy-Item -Path $envDevFilePath -Destination $envBaseFilePath

        Set-Location -Path $projectRoot
        yarn install

        Set-Location -Path (Join-Path -Path $projectRoot -ChildPath "dev-ops")
        yarn dma:build
        yarn docker:build:cds
        yarn docker:build:dma

        Write-Host "DMA environment setup completed successfully."
    } catch {
        Write-Host "Error setting environment variables: $_"
        Pause
    }
}

# DMA start
function DMA-Starten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk"
    $uiPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk/ui"

    try {
        Set-Location -Path $backendPath

        docker network create web

        # Start the backend in a new PowerShell process
        Start-Process powershell -ArgumentList "yarn dev:backend:start" -NoNewWindow

        # Change directory to UI path and start the UI
        Start-Process powershell -ArgumentList "yarn dev:ui:start" -NoNewWindow

        Write-Host "Open the application at http://localhost:8080/"

        Write-Host "If you see 'Einrichten', please enter the following:"
        Write-Host "Username: (e.g. admin)"
        Write-Host "Password: (e.g. NOT admin)"
        Write-Host "Email: your email"
        Write-Host "Setup-Token: value from APP_SETUP_TOKEN in .env.dev (could be '1')"
    } catch {
        Write-Host "Error starting DMA: $_"
        Pause
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
                Pause
            } else {
                Write-Host "Invalid choice. Please try again."
                Pause
            }
        }
        2 {
            Install-Composer
            Pause
        }
        3 {
            Install-Nvm-Node
            Pause
        }
        4 {
            npm install -g npm
            Write-Host "npm has been installed successfully."
            Pause
        }
        5 {
            Install-Yarn-Pnpm -choice 'pnpm'
            Pause
        }
        6 {
            Install-Yarn-Pnpm -choice 'yarn'
            Pause
        }
        7 {
            Install-Git
            Pause
        }
        8 {
            Install-Docker
            Pause
        }
        9 {
            DMA-Klonen-und-Einrichten
        }
        10 {
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
            Pause
        }
    }
}
