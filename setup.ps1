function Set-ExecutionPolicy-RemoteSigned {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -ne 'RemoteSigned') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy set to RemoteSigned."
    } else {
        Write-Host "Execution policy is already set to RemoteSigned."
    }
}

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "You'll need at least PowerShell version 5. To determine your version, open PowerShell and type:"
    Write-Host "$PSVersionTable.PSVersion.ToString()"
    Write-Host "If you have an older version, you can upgrade it following these instructions: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell"
    exit
}

$is64Bit = [Environment]::Is64BitOperatingSystem
$phpVersions = @{
    "7.4.33" = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip" } else { "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x86.zip" }
    "8.3.8"  = if ($is64Bit) { "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip" } else { "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x86.zip" }
}

function Show-Menu {
    cls
Write-Host "⠀⠀⠀⠀HELLO!⠀⠀⠀⠀⠀⠀"
Write-Host "⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
Write-Host "⠀⠀⠀⠀⢰⣿⡿⠗⠀⠠⠄⡀⠀⠀⠀⠀"
Write-Host "⠀⠀⠀⠀⡜⠁⠀⠀⠀⠀⠀⠈⠑⢶⣶⡄"
Write-Host "⢀⣶⣦⣸⠀⢼⣟⡇⠀⠀⢀⣀⠀⠘⡿⠃"
Write-Host "⠀⢿⣿⣿⣄⠒⠀⠠⢶⡂⢫⣿⢇⢀⠃⠀"
Write-Host "⠀⠈⠻⣿⣿⣿⣶⣤⣀⣀⣀⣂⡠⠊⠀⠀"
Write-Host "⠀⠀⠀⠃⠀⠀⠉⠙⠛⠿⣿⣿⣧⠀⠀⠀"
Write-Host "⠀⠀⠘⡀⠀⠀⠀⠀⠀⠀⠘⣿⣿⡇⠀⠀"
Write-Host "⠀⠀⠀⣷⣄⡀⠀⠀⠀⢀⣴⡟⠿⠃⠀⠀"
Write-Host "⠀⠀⠀⢻⣿⣿⠉⠉⢹⣿⣿⠁⠀⠀⠀⠀"
Write-Host "⠀⠀⠀⠀⠉⠁⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀"
Write-Host "                       "
Write-Host "Im the Setup Giraffe "
Write-Host "                       "
    Write-Host "Select an option to install:"
    Write-Host "1. Install PHP"
    Write-Host "2. Install Composer"
    Write-Host "3. Install Node.js via nvm"
    Write-Host "4. Install npm"
    Write-Host "5. Install pnpm"
    Write-Host "6. Install Yarn"
    Write-Host "7. Install Git"
    Write-Host "8. Install Docker"
    Write-Host "9. Projekt Aufsetzen"
    Write-Host "10. Software Status"
    Write-Host "11. Exit"
}

function Show-ProjektAufsetzenMenu {
    cls
    Write-Host "Projekt Aufsetzen:"
    Write-Host "1. DMA klonen und einrichten"
    Write-Host "2. SF klonen und einrichten"
    Write-Host "3. Zurück zum Hauptmenü"
}

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

function Install-Git {
    $url = if ($is64Bit) { "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe" } else { "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-32-bit.exe" }
    $installerPath = "$env:TEMP\GitInstaller.exe"
    Invoke-WebRequest-Retry -url $url -outputPath $installerPath
    Show-LoadingAnimation -message "Downloading Git" -durationSeconds 5
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Git has been installed successfully."
        Add-ToPath -newPath "C:\Program Files\Git\bin"
        git lfs install
        Write-Host "Git LFS has been installed and activated."
    } else {
        Write-Host "Failed to install Git."
    }
}

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

function DMA-Klonen-und-Einrichten {
    while ($true) {
        cls
        Write-Host "DMA klonen und einrichten:"
        Write-Host "1. DMA klonen"
        Write-Host "2. DMA einrichten"
        Write-Host "3. DMA starten"
        Write-Host "4. Zurück zum Projekt Aufsetzen Menü"
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

function SF-Klonen-und-Einrichten {
    while ($true) {
        cls
        Write-Host "SF klonen und einrichten:"
        Write-Host "1. Projekt klonen"
        Write-Host "2. Projekt einrichten"
        Write-Host "3. SF Projekt starten"
        Write-Host "4. Zurück zum Projekt Aufsetzen Menü"
        $subChoice = Read-Host "Enter your choice (1-4)"
        switch ($subChoice) {
            1 {
                SF-Klonen
                Pause
            }
            2 {
                $projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
                if (-not $projectRoot) {
                    $projectRoot = Get-Location
                }
                SF-Einrichten -projectRoot $projectRoot
                Pause
            }
            3 {
                $projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
                if (-not $projectRoot) {
                    $projectRoot = Get-Location
                }
                SF-Starten -projectRoot $projectRoot
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

function DMA-Einrichten {
    param (
        [string]$projectRoot
    )
    
    $uiPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk/ui"
    $projectRoot2 = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk"

    try {
        $envFilePath = Join-Path -Path $projectRoot2 -ChildPath "dev-ops\stacks\.env.template"
        $envDevFilePath = Join-Path -Path $projectRoot2 -ChildPath "dev-ops\stacks\.env.dev"
        $envBaseFilePath = Join-Path -Path $projectRoot2 -ChildPath "dev-ops\stacks\.env.base"

        Copy-Item -Path $envFilePath -Destination $envDevFilePath

        (Get-Content $envDevFilePath) -replace '^OIDC_CLIENT_ID=dma_ukk', '#OIDC_CLIENT_ID=dma_ukk' |
            Set-Content $envDevFilePath
        (Get-Content $envDevFilePath) -replace '^OIDC_CLIENT_SECRET=.*$', '#$&' |
            Set-Content $envDevFilePath
        Add-Content $envDevFilePath "`nOIDC_CLIENT_ID=cds_dev`nOIDC_CLIENT_SECRET=your_secret_here"

        Copy-Item -Path $envDevFilePath -Destination $envBaseFilePath

        Set-Location -Path $projectRoot2
        
        Start-Process powershell -ArgumentList "yarn install" 

        Set-Location -Path $uiPath
        Start-Process powershell -ArgumentList "yarn install" 
 
        Set-Location -Path $projectRoot2
        Set-Location -Path (Join-Path -Path $projectRoot2 -ChildPath "dev-ops")
        Start-Process powershell -ArgumentList "yarn run dma:build" 
        Start-Process powershell -ArgumentList "yarn run docker:build:cds" 
        Start-Process powershell -ArgumentList "yarn run docker:build:dma" 
        Set-Location -Path $projectRoot

        Write-Host "DMA environment setup completed successfully."
    } catch {
        Write-Host "Error setting environment variables: $_"
        Pause
    }
}

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
        Start-Process powershell -ArgumentList "yarn run dev:backend:start"

        # Change directory to UI path and start the UI
        Set-Location -Path $uiPath
        Start-Process powershell -ArgumentList "yarn install"

       
        Start-Process powershell -ArgumentList "yarn dev"

        Write-Host "Open the application at http://localhost:8080/"
        Set-Location -Path $projectRoot

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

function SF-Klonen {
    $repoUrl = "https://github.com/healexsystems/cds"
    $targetDir = Read-Host "Enter the target directory (leave blank to use the current directory)"
    
    if (-not $targetDir) {
        $targetDir = (Get-Location).Path
    }

    Write-Host "Cloning repository from $repoUrl into $targetDir..."
    Show-LoadingAnimation -message "Cloning repository" -durationSeconds 10
    try {
        git clone $repoUrl $targetDir
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Repository cloned successfully into $targetDir."
        } else {
            Write-Host "Failed to clone the repository."
        }
    } catch {
        Write-Host "Error cloning repository: $_"
    }
}

function SF-Einrichten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/backend"
    $frontendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/frontend"

    try {
        Copy-Item -Path (Join-Path -Path $backendPath -ChildPath ".env.template") -Destination (Join-Path -Path $backendPath -ChildPath ".env")
        Copy-Item -Path (Join-Path -Path $frontendPath -ChildPath ".env-template") -Destination (Join-Path -Path $frontendPath -ChildPath ".env")

        Set-Location -Path $backendPath
        if ((Get-CommandVersion -command "node" -versionArg "--version").Split('.')[0] -lt 18) {
            Write-Host "Updating Node.js to version 18.12.0 or later..."
            nvm install 18.12.0
            nvm use 18.12.0
        }
        pnpm exec docker:up:db
        pnpm exec docker:up:build

        Set-Location -Path $frontendPath
        pnpm exec docker:up:build

        Write-Host "SF environment setup completed successfully."
    } catch {
        Write-Host "Error setting environment variables: $_"
        Pause
    }
}

function SF-Starten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/backend"
    $frontendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/frontend"

    try {
        Set-Location -Path $backendPath

        docker network create web

        # Start the backend in a new PowerShell process
        Start-Process powershell -ArgumentList "pnpm dev:backend:start" -NoNewWindow

        # Change directory to UI path and start the UI
        Start-Process powershell -ArgumentList "pnpm dev:ui:start" -NoNewWindow

        Write-Host "Open the application at http://localhost:8080/"
    } catch {
        Write-Host "Error starting SF: $_"
        Pause
    }
}

function Show-SoftwareStatus {
    $softwareList = @(
        @{
            Name = "PHP"
            Command = "php"
            VersionArg = "-v"
        },
        @{
            Name = "Composer"
            Command = "composer"
            VersionArg = "--version"
        },
        @{
            Name = "Node.js"
            Command = "node"
            VersionArg = "--version"
        },
        @{
            Name = "npm"
            Command = "npm"
            VersionArg = "--version"
        },
        @{
            Name = "pnpm"
            Command = "pnpm"
            VersionArg = "--version"
        },
        @{
            Name = "Yarn"
            Command = "yarn"
            VersionArg = "--version"
        },
        @{
            Name = "Git"
            Command = "git"
            VersionArg = "--version"
        },
        @{
            Name = "Docker"
            Command = "docker"
            VersionArg = "--version"
        }
    )

    foreach ($software in $softwareList) {
        $version = Get-CommandVersion -command $software.Command -versionArg $software.VersionArg
        if ($version) {
            $path = (Get-Command $software.Command).Path
            Write-Host "$($software.Name) is installed: $version"
            Write-Host "Path: $path"
        } else {
            Write-Host "$($software.Name) is not installed."
        }
        Write-Host ""
    }
}

while ($true) {
    Set-ExecutionPolicy-RemoteSigned
    Show-Menu
    $choice = Read-Host "Enter your choice (1-11)"
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
            while ($true) {
                Show-ProjektAufsetzenMenu
                $subChoice = Read-Host "Enter your choice (1-3)"
                switch ($subChoice) {
                    1 {
                        DMA-Klonen-und-Einrichten
                    }
                    2 {
                        SF-Klonen-und-Einrichten
                    }
                    3 {
                        break
                    }
                    default {
                        Write-Host "Invalid choice. Please try again."
                    }
                }
            }
        }
        10 {
            Show-SoftwareStatus
            Pause
        }
        11 {
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
            Pause
        }
    }
}
