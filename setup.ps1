# Ensure the script runs with appropriate execution policies
function Ensure-ExecutionPolicy {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -ne 'RemoteSigned') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy set to RemoteSigned."
    }
}

# Check PowerShell version requirement
function Verify-PowerShellVersion {
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "PowerShell 5 or newer is required. Please update your version."
        exit
    }
}

# Function to install PHP
function Install-PHP {
    Param ([string]$Version)
    $phpUrls = @{
        "7.4.33" = "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip"
        "8.0.30" = "https://windows.php.net/downloads/releases/php-8.0.30-Win32-vs16-x64.zip"
        "8.1.29" = "https://windows.php.net/downloads/releases/php-8.1.29-Win32-vs16-x64.zip"
        "8.2.20" = "https://windows.php.net/downloads/releases/php-8.2.20-Win32-vs16-x64.zip"
        "8.3.8"  = "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip"
    }

    if ($phpUrls.ContainsKey($Version)) {
        $url = $phpUrls[$Version]
        $output = "php.zip"
        Write-Host "Downloading PHP $Version from $url..."
        Invoke-WebRequest -Uri $url -OutFile $output
        Expand-Archive -Path $output -DestinationPath "C:\PHP\$Version"
        Remove-Item $output
        Write-Host "PHP $Version installed at C:\PHP\$Version"
    } else {
        Write-Host "Invalid PHP version. Please choose a valid version."
    }
}

# Function to install Composer
function Install-Composer {
    Write-Host "Installing Composer..."
    Invoke-WebRequest -Uri "https://getcomposer.org/installer" -OutFile "composer-setup.php"
    & php "composer-setup.php" --install-dir=C:\PHP --filename=composer
    Remove-Item "composer-setup.php"
    Write-Host "Composer installed."
}

# Function to install Node.js
function Install-Node {
    Param ([string]$Version)
    $url = "https://nodejs.org/dist/v$Version/node-v$Version-win-x64.zip"
    $output = "node.zip"
    Write-Host "Downloading Node.js $Version from $url..."
    Invoke-WebRequest -Uri $url -OutFile $output
    Expand-Archive -Path $output -DestinationPath "C:\Nodejs\$Version"
    Remove-Item $output
    Write-Host "Node.js $Version installed at C:\Nodejs\$Version"
}

# Function to install Yarn
function Install-Yarn {
    Param ([string]$Version)
    $url = "https://github.com/yarnpkg/yarn/releases/download/v$Version/yarn-$Version.msi"
    Write-Host "Downloading Yarn $Version from $url..."
    Invoke-WebRequest -Uri $url -OutFile "yarn.msi"
    Start-Process msiexec.exe -ArgumentList "/i yarn.msi /quiet" -Wait
    Remove-Item "yarn.msi"
    Write-Host "Yarn $Version installed."
}

# User interface: Main menu
function Show-Menu {
    Write-Host "Select an option:"
    Write-Host "1: Install PHP"
    Write-Host "2: Install Composer"
    Write-Host "3: Install Node.js"
    Write-Host "4: Install Yarn"
    Write-Host "Q: Quit"
}

# Main execution loop
Ensure-ExecutionPolicy
Verify-PowerShellVersion

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        '1' {
            Write-Host "Available PHP versions: 7.4.33, 8.0.30, 8.1.29, 8.2.20, 8.3.8"
            $version = Read-Host "Enter PHP version"
            Install-PHP -Version $version
        }
        '2' {
            Install-Composer
        }
        '3' {
            $version = Read-Host "Enter Node.js version (e.g., 14.15.1)"
            Install-Node -Version $version
        }
        '4' {
            $version = Read-Host "Enter Yarn version (e.g., 1.22.5)"
            Install-Yarn -Version $version
        }
        'Q' {
            Write-Host "Exiting script..."
            break
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }
} while ($input -ne 'Q')
