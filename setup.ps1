# Ensure the script runs with appropriate execution policies
function Set-ExecutionPolicy-IfNeeded {
    try {
        $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
        if ($currentPolicy -ne 'RemoteSigned') {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "Execution policy set to RemoteSigned."
        }
    } catch {
        Write-Host "Failed to set execution policy. Run PowerShell as Administrator."
    }
}

# Check PowerShell version before proceeding
function Check-PowerShellVersion {
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "PowerShell version 5 or higher is required. Your version: $($PSVersionTable.PSVersion)"
        exit
    }
}

# Function definitions for software installation
function Install-PHP {
    Param ([string]$Version)
    $url = "https://windows.php.net/downloads/releases/php-$Version-Win32-VC15-x64.zip"
    $output = "php.zip"
    Write-Host "Downloading PHP $Version..."
    Invoke-WebRequest -Uri $url -OutFile $output
    Expand-Archive -Path $output -DestinationPath "C:\PHP\$Version"
    Remove-Item $output
    Write-Host "PHP $Version installed."
}

function Install-Composer {
    Write-Host "Installing Composer..."
    Invoke-WebRequest -Uri "https://getcomposer.org/installer" -OutFile "composer-setup.php"
    & php "composer-setup.php" --install-dir=C:\PHP --filename=composer
    Remove-Item "composer-setup.php"
    Write-Host "Composer installed."
}

function Install-Node {
    Param ([string]$Version)
    $url = "https://nodejs.org/dist/v$Version/node-v$Version-win-x64.zip"
    $output = "node.zip"
    Write-Host "Downloading Node.js $Version..."
    Invoke-WebRequest -Uri $url -OutFile $output
    Expand-Archive -Path $output -DestinationPath "C:\Nodejs\$Version"
    Remove-Item $output
    Write-Host "Node.js $Version installed."
}

function Install-Yarn {
    Param ([string]$Version)
    $url = "https://github.com/yarnpkg/yarn/releases/download/v$Version/yarn-$Version.msi"
    Write-Host "Downloading Yarn $Version..."
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

# Main execution block
Set-ExecutionPolicy-IfNeeded
Check-PowerShellVersion

do {
    Show-Menu
    $input = Read-Host "Enter your choice"
    switch ($input) {
        '1' {
            $version = Read-Host "Enter PHP version (e.g., 7.4.1)"
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
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }
} while ($input -ne 'Q')
