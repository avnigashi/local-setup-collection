# Automated Setup Scripts for Development Environment

## Overview

This repository contains two automated scripts to set up a development environment on both Linux and Windows systems. These scripts will install Docker, Git, Node.js, npm, Python, and additional package managers like Yarn and pnpm, configuring them as needed.

## Scripts

### Linux Setup Script

The Linux setup script performs the following tasks:
1. Asks the user for confirmation before each installation step.
2. Installs Docker and Docker Compose.
3. Installs Git and configures SSH keys for GitHub.
4. Installs Node.js and npm using NVM.
5. Optionally installs Yarn or pnpm.
6. Installs Python and related tools.

### Windows Setup Script

The Windows setup script performs the following tasks:
1. Installs Docker Desktop and configures it for WSL2.
2. Installs Git and configures SSH keys for GitHub.
3. Installs Node.js and npm using NVM.
4. Optionally installs Yarn or pnpm.
5. Installs Python and related tools.

## Usage

### Linux Setup Script

1. Save the script as `setup.local.linux.sh`.
2. Make the script executable:
    ```bash
    chmod +x setup.local.linux.sh
    ```
3. Run the script:
    ```bash
    ./setup.local.linux.sh
    ```
    
### Windows Setup Script
#### Prerequisites
- PowerShell installed.
- Administrator privileges.

#### Steps

1. **Open PowerShell as Administrator**:
   - Search for "PowerShell" in the Start menu, right-click, and select "Run as administrator."

2. **Set Execution Policy**:
   - Run:
     ```powershell
     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
     ```

3. **Execute the Script**:
   - Run:
     ```powershell
     irm https://raw.githubusercontent.com/avnigashi/local-setup-collection/main/setup.ps1 | iex
     ```
     
