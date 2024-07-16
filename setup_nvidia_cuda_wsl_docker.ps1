# NVIDIA, CUDA, WSL2, Docker, and PyTorch Setup Script
# Run this script as Administrator

# Function to check if running as administrator
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Check if script is running as Administrator
if (-not (Test-Administrator)) {
    Write-Host "This script needs to be run as Administrator. Please restart PowerShell as an Administrator and run the script again."
    Exit
}

# Function to check Windows version
function Get-WindowsVersion {
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    return $osInfo.Caption
}

# Function to download file
function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath
    )
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($Url, $OutputPath)
}

# Function to check NVIDIA driver version
function Get-NvidiaDriverVersion {
    try {
        $nvidiaOutput = & nvidia-smi --query-gpu=driver_version --format=csv,noheader
        return $nvidiaOutput.Trim()
    } catch {
        return $null
    }
}

# Function to check CUDA version
function Get-CudaVersion {
    try {
        $nvidiaOutput = & nvidia-smi
        if ($nvidiaOutput -match "CUDA Version: (\d+\.\d+)") {
            return $matches[1]
        }
    } catch {
        return $null
    }
    return $null
}

# Function to check WSL version
function Get-WSLVersion {
    try {
        $wslOutput = & wsl --status
        if ($wslOutput -match "Default Version: (\d+)") {
            return $matches[1]
        }
    } catch {
        return $null
    }
    return $null
}

# Function to check Docker version
function Get-DockerVersion {
    try {
        $dockerOutput = & docker --version
        if ($dockerOutput -match "Docker version (\d+\.\d+\.\d+)") {
            return $matches[1]
        }
    } catch {
        return $null
    }
    return $null
}

# Function to install CUDA Toolkit
function Install-CUDAToolkit {
    $windowsVersion = Get-WindowsVersion
    if (-not $windowsVersion.Contains("Windows 11")) {
        Write-Host "This script is designed for Windows 11. Your current version is: $windowsVersion"
        Write-Host "The installation may not work correctly. Do you want to continue? (Y/N)"
        $proceed = Read-Host
        if ($proceed -ne 'Y') {
            return
        }
    }

    Write-Host "Downloading CUDA Toolkit 12.1.0..."
    $cudaUrl = "https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_531.14_windows.exe"
    $cudaInstaller = "$env:TEMP\cuda_12.1.0_531.14_windows.exe"
    Download-File -Url $cudaUrl -OutputPath $cudaInstaller

    Write-Host "Installing CUDA Toolkit 12.1.0..."
    Start-Process -FilePath $cudaInstaller -ArgumentList "-s" -Wait

    Write-Host "CUDA Toolkit 12.1.0 installation completed."
    Write-Host "Please reboot your system to complete the installation."
}

# Function to create CUDA-enabled Ubuntu WSL2 instance with PyTorch
function Create-CudaUbuntuWSL {
    param (
        [string]$UbuntuVersion
    )
    Write-Host "Creating CUDA-enabled Ubuntu $UbuntuVersion WSL2 instance with PyTorch..."
    
    # Install specified Ubuntu version
    wsl --install -d Ubuntu-$UbuntuVersion

    # Update and upgrade packages
    wsl -d Ubuntu-$UbuntuVersion -e bash -c "sudo apt update && sudo apt upgrade -y"

    # Install CUDA dependencies
    wsl -d Ubuntu-$UbuntuVersion -e bash -c "sudo apt install -y build-essential"

    # Download and install CUDA 12.1.1 for WSL
    $cudaUrl = "https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda_12.1.1_530.30.02_linux.run"
    wsl -d Ubuntu-$UbuntuVersion -e bash -c "wget $cudaUrl -O cuda_installer.run && sudo sh cuda_installer.run --silent --toolkit"

    # Set up environment variables
    wsl -d Ubuntu-$UbuntuVersion -e bash -c 'echo "export PATH=/usr/local/cuda-12.1/bin`${PATH:+:`${PATH}}" >> ~/.bashrc'
    wsl -d Ubuntu-$UbuntuVersion -e bash -c 'echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64`${LD_LIBRARY_PATH:+:`${LD_LIBRARY_PATH}}" >> ~/.bashrc'

    # Install Python and pip
    wsl -d Ubuntu-$UbuntuVersion -e bash -c "sudo apt install -y python3 python3-pip"

    # Install Conda
    wsl -d Ubuntu-$UbuntuVersion -e bash -c @"
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b
        ~/miniconda3/bin/conda init
        source ~/.bashrc
"@

    # Create Conda environment and install PyTorch dependencies
    wsl -d Ubuntu-$UbuntuVersion -e bash -c @"
        conda create -n p310-cu121 -c nvidia/label/cuda-12.1.1 -c pytorch -c defaults magma-cuda121 astunparse numpy ninja pyyaml setuptools cmake typing_extensions six requests dataclasses mkl mkl-include python=3.10 -y
        conda activate p310-cu121
        pip install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cu121
"@

    # Verify PyTorch installation and CUDA availability
    wsl -d Ubuntu-$UbuntuVersion -e bash -c @"
        conda activate p310-cu121
        python -c 'import torch; print(f"PyTorch version: {torch.__version__}"); print(f"CUDA available: {torch.cuda.is_available()}"); print(f"CUDA version: {torch.version.cuda}")'
"@

    Write-Host "CUDA-enabled Ubuntu $UbuntuVersion WSL2 instance with PyTorch created successfully."
    Write-Host "Note: If you encounter any issues with CUDA availability, you may need to build PyTorch from source."
}

# Function to display menu and get user choice
function Show-Menu {
    param (
        [string]$Title = 'Installation Options'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    $nvidiaVersion = Get-NvidiaDriverVersion
    $cudaVersion = Get-CudaVersion
    $wslVersion = Get-WSLVersion
    $dockerVersion = Get-DockerVersion

    Write-Host "1: Install/Update NVIDIA Drivers $(if ($nvidiaVersion) { "(Installed v.$nvidiaVersion)" } else { "(Not installed)" })"
    Write-Host "2: Install CUDA Toolkit 12.1.0 $(if ($cudaVersion) { "(Installed v.$cudaVersion)" } else { "(Not installed)" })"
    Write-Host "3: Enable WSL2 and Install Ubuntu 22.04 $(if ($wslVersion) { "(WSL v.$wslVersion installed)" } else { "(Not installed)" })"
    Write-Host "4: Install Docker Desktop $(if ($dockerVersion) { "(Installed v.$dockerVersion)" } else { "(Not installed)" })"
    Write-Host "5: Create CUDA-enabled Ubuntu WSL2 Instance with PyTorch"
    Write-Host "6: Install All"
    Write-Host "Q: Quit"
}

# Main script logic
do {
    Show-Menu
    $choice = Read-Host "Please make a selection"
    switch ($choice) {
        '1' {
            Write-Host "Installing/Updating NVIDIA Drivers..."
            $proceed = Read-Host "Do you want to install/update NVIDIA drivers? (Y/N)"
            if ($proceed -eq 'Y') {
                Write-Host "Downloading and installing latest NVIDIA drivers..."
                $nvDriverUrl = "https://us.download.nvidia.com/tesla/531.41/531.41-data-center-tesla-desktop-winserver-2022-2019-2016-dch-international.exe"
                $nvDriverPath = "$env:TEMP\nvidia_driver.exe"
                Download-File -Url $nvDriverUrl -OutputPath $nvDriverPath
                Start-Process -FilePath $nvDriverPath -ArgumentList "/s" -Wait
            }
        }
        '2' {
            Write-Host "Installing CUDA Toolkit 12.1.0..."
            $proceed = Read-Host "Do you want to install CUDA Toolkit 12.1.0? (Y/N)"
            if ($proceed -eq 'Y') {
                Install-CUDAToolkit
            }
        }
        '3' {
            Write-Host "Enabling WSL2 and Installing Ubuntu 22.04..."
            $proceed = Read-Host "Do you want to enable WSL2 and install Ubuntu 22.04? (Y/N)"
            if ($proceed -eq 'Y') {
                Write-Host "Enabling WSL2..."
                dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
                dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
                Write-Host "Setting WSL2 as default..."
                wsl --set-default-version 2
                Write-Host "Installing Ubuntu 22.04..."
                wsl --install -d Ubuntu-22.04
            }
        }
        '4' {
            Write-Host "Installing Docker Desktop..."
            $proceed = Read-Host "Do you want to install Docker Desktop? (Y/N)"
            if ($proceed -eq 'Y') {
                Write-Host "Downloading and installing Docker Desktop..."
                $dockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
                $dockerPath = "$env:TEMP\docker_installer.exe"
                Download-File -Url $dockerUrl -OutputPath $dockerPath
                Start-Process -FilePath $dockerPath -ArgumentList "install --quiet" -Wait
                
                Write-Host "Configuring Docker to use WSL2 backend..."
                $dockerConfigPath = "$env:USERPROFILE\.docker\daemon.json"
                $dockerConfig = @{
                    "experimental" = $true
                    "features" = @{
                        "buildkit" = $true
                    }
                    "wsl-ubuntu" = $true
                }
                $dockerConfig | ConvertTo-Json | Set-Content -Path $dockerConfigPath
            }
        }
        '5' {
            Write-Host "Creating CUDA-enabled Ubuntu WSL2 Instance with PyTorch..."
            $ubuntuVersion = Read-Host "Enter Ubuntu version (e.g., 22.04)"
            $proceed = Read-Host "Do you want to create a CUDA-enabled Ubuntu $ubuntuVersion WSL2 instance with PyTorch? (Y/N)"
            if ($proceed -eq 'Y') {
                Create-CudaUbuntuWSL -UbuntuVersion $ubuntuVersion
            }
        }
        '6' {
            Write-Host "Installing All Components..."
            $proceed = Read-Host "Do you want to install all components? (Y/N)"
            if ($proceed -eq 'Y') {
                # Run all installation steps
                Write-Host "Installing all components..."
                # NVIDIA Drivers
                Write-Host "Installing NVIDIA Drivers..."
                $nvDriverUrl = "https://us.download.nvidia.com/tesla/531.41/531.41-data-center-tesla-desktop-winserver-2022-2019-2016-dch-international.exe"
                $nvDriverPath = "$env:TEMP\nvidia_driver.exe"
                Download-File -Url $nvDriverUrl -OutputPath $nvDriverPath
                Start-Process -FilePath $nvDriverPath -ArgumentList "/s" -Wait

                # CUDA Toolkit
                Write-Host "Installing CUDA Toolkit..."
                Install-CUDAToolkit

                # WSL2 and Ubuntu
                Write-Host "Enabling WSL2 and Installing Ubuntu 22.04..."
                dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
                dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
                wsl --set-default-version 2
                wsl --install -d Ubuntu-22.04

                # Docker Desktop
                Write-Host "Installing Docker Desktop..."
                $dockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
                $dockerPath = "$env:TEMP\docker_installer.exe"
                Download-File -Url $dockerUrl -OutputPath $dockerPath
                Start-Process -FilePath $dockerPath -ArgumentList "install --quiet" -Wait

                # CUDA-enabled Ubuntu WSL2 Instance with PyTorch
                Write-Host "Creating CUDA-enabled Ubuntu 22.04 WSL2 Instance with PyTorch..."
                Create-CudaUbuntuWSL -UbuntuVersion "22.04"
            }
        }
        'Q' {
            Write-Host "Exiting..."
            return
        }
    }
    pause
}
until ($choice -eq 'Q')

Write-Host "Setup complete. Please restart your computer to finalize the installation."
Write-Host "After restart, open Docker Desktop and ensure that 'Use the WSL 2 based engine' is checked in Settings > General."
Write-Host "You may also need to enable NVIDIA GPU support in Docker Desktop settings."
