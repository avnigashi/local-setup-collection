function Install-PHP {
    Param (
        [string]$Version
    )
    $url = "https://windows.php.net/downloads/releases/php-$Version-Win32-VC15-x64.zip"
    $output = "php.zip"
    Write-Host "Downloading PHP..."
    Invoke-WebRequest -Uri $url -OutFile $output
    Expand-Archive -Path $output -DestinationPath C:\PHP
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\PHP", [EnvironmentVariableTarget]::Machine)
    Write-Host "PHP installed."
}

function Install-Composer {
    Write-Host "Installing Composer..."
    Invoke-WebRequest -Uri "https://getcomposer.org/installer" -OutFile "composer-setup.php"
    & php.exe "composer-setup.php" --install-dir=C:\PHP --filename=composer
    Remove-Item "composer-setup.php"
    Write-Host "Composer installed."
}

function Install-Node {
    Param (
        [string]$Version
    )
    $url = "https://nodejs.org/dist/v$Version/node-v$Version-win-x64.zip"
    $output = "node.zip"
    Write-Host "Downloading Node.js..."
    Invoke-WebRequest -Uri $url -OutFile $output
    Expand-Archive -Path $output -DestinationPath C:\Nodejs
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Nodejs", [EnvironmentVariableTarget]::Machine)
    Write-Host "Node.js installed."
}

function Install-Yarn {
    Param (
        [string]$Version
    )
    $url = "https://github.com/yarnpkg/yarn/releases/download/v$Version/yarn-$Version.msi"
    $output = "yarn.msi"
    Write-Host "Downloading Yarn..."
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process "msiexec.exe" -ArgumentList "/i yarn.msi /quiet" -Wait
    Remove-Item "yarn.msi"
    Write-Host "Yarn installed."
}

function Show-Menu {
    param (
        [string]$Title = 'Installation Menu'
    )
    cls
    Write-Host "================ $Title ================"
    
    Write-Host "1: Install PHP"
    Write-Host "2: Install Composer"
    Write-Host "3: Install Node.js"
    Write-Host "4: Install Yarn"
    Write-Host "Q: Quit"
}

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        '1' {
            $version = Read-Host "Enter PHP version"
            Install-PHP -Version $version
            pause
        }
        '2' {
            Install-Composer
            pause
        }
        '3' {
            $version = Read-Host "Enter Node.js version"
            Install-Node -Version $version
            pause
        }
        '4' {
            $version = Read-Host "Enter Yarn version"
            Install-Yarn -Version $version
            pause
        }
        'Q' {
            return
        }
        default {
            Write-Host "Invalid option, please try again."
            pause
        }
    }
} while ($input -ne 'Q')
