import os
import subprocess
import time

def install_docker_desktop():
    url = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    installer_path = os.path.join(os.environ['TEMP'], "DockerDesktopInstaller.exe")
    subprocess.run(["curl", "-L", url, "-o", installer_path], check=True)
    subprocess.run([installer_path], check=True)

def enable_wsl2():
    subprocess.run(["wsl", "--set-default-version", "2"], check=True)

def configure_docker_desktop():
    subprocess.run(["powershell", "-Command", "Start-Process", "Docker Desktop", "-Verb", "runas"], check=True)
    time.sleep(60)  # Wait for Docker Desktop to start
    settings_script = '''
        $settings = @{
            "useWsl2" = $true
            "wslDistroName" = "Ubuntu"
        }
        $settings | ConvertTo-Json | Out-File -FilePath "$env:APPDATA\\Docker\\settings.json" -Encoding utf8
    '''
    subprocess.run(["powershell", "-Command", settings_script], check=True)
    subprocess.run(["powershell", "-Command", "Stop-Process -Name 'Docker Desktop'"], check=True)
    subprocess.run(["powershell", "-Command", "Start-Process 'Docker Desktop' -Verb runas"], check=True)

def set_wsl_distro_version(distro_name):
    subprocess.run(["wsl", "--set-version", distro_name, "2"], check=True)

def configure_wsl_integration():
    integration_script = '''
        $integrations = @{
            "enabledDistributions" = @("Ubuntu")
        }
        $integrations | ConvertTo-Json | Out-File -FilePath "$env:APPDATA\\Docker\\integrations.json" -Encoding utf8
    '''
    subprocess.run(["powershell", "-Command", integration_script], check=True)
    subprocess.run(["powershell", "-Command", "Stop-Process -Name 'Docker Desktop'"], check=True)
    subprocess.run(["powershell", "-Command", "Start-Process 'Docker Desktop' -Verb runas"], check=True)

def install_git():
    url = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.36.1.1-64-bit.exe"
    installer_path = os.path.join(os.environ['TEMP'], "GitInstaller.exe")
    subprocess.run(["curl", "-L", url, "-o", installer_path], check=True)
    subprocess.run([installer_path, "/VERYSILENT"], check=True)

def configure_ssh_for_github():
    ssh_dir = os.path.expanduser("~/.ssh")
    os.makedirs(ssh_dir, exist_ok=True)
    key_path = os.path.join(ssh_dir, "id_rsa")
    if os.path.isfile(key_path):
        overwrite = input("An existing SSH key pair was found. Do you want to overwrite it? (y/n) ")
        if overwrite.lower() != "y":
            print("Exiting without creating a new SSH key pair.")
            return

    email = input("Enter your email address for the SSH key: ")
    subprocess.run(["ssh-keygen", "-t", "rsa", "-b", "4096", "-C", email, "-f", key_path, "-N", ""])

    subprocess.run(["powershell", "-Command", "Start-Process ssh-agent -Verb runAs"])
    subprocess.run(["powershell", "-Command", f"ssh-add {key_path}"])

    with open(f"{key_path}.pub", "r") as pub_key:
        print("Your new SSH public key has been generated:")
        print(pub_key.read())

    print("Copy the above SSH key and add it to your GitHub account under Settings > SSH and GPG keys.")

def install_nvm_node():
    nvm_install_script = "https://raw.githubusercontent.com/coreybutler/nvm-windows/master/nvm-setup.exe"
    installer_path = os.path.join(os.environ['TEMP'], "nvm-setup.exe")
    subprocess.run(["curl", "-L", nvm_install_script, "-o", installer_path], check=True)
    subprocess.run([installer_path], check=True)
    subprocess.run(["nvm", "install", "latest"], check=True)
    subprocess.run(["nvm", "use", "latest"], check=True)
    subprocess.run(["npm", "install", "-g", "npm"], check=True)

def install_yarn_pnpm():
    choice = input("Do you want to install Yarn, pnpm, or none? (yarn/pnpm/none) ")
    if choice.lower() == "yarn":
        subprocess.run(["npm", "install", "-g", "yarn"], check=True)
        subprocess.run(["yarn", "-v"], check=True)
    elif choice.lower() == "pnpm":
        subprocess.run(["npm", "install", "-g", "pnpm"], check=True)
        subprocess.run(["pnpm", "-v"], check=True)
    else:
        print("No additional package manager will be installed.")

def install_python():
    subprocess.run(["winget", "install", "-e", "--id", "Python.Python.3"], check=True)
    subprocess.run(["python", "--version"], check=True)
    subprocess.run(["pip", "--version"], check=True)
    subprocess.run(["pip", "install", "--upgrade", "pip"], check=True)
    subprocess.run(["pip", "install", "virtualenv"], check=True)
    subprocess.run(["virtualenv", "--version"], check=True)
    print("Python, pip, and virtual environment setup is complete.")
    print("To create a virtual environment, run: python -m venv <your-env-name>")
    print("To activate the virtual environment, run: <your-env-name>\\Scripts\\activate")
    print("To deactivate the virtual environment, simply run: deactivate")

def main():
    install_docker_desktop()
    enable_wsl2()
    configure_docker_desktop()
    set_wsl_distro_version("Ubuntu")
    configure_wsl_integration()
    install_git()
    configure_ssh_for_github()
    install_nvm_node()
    install_yarn_pnpm()
    install_python()

if __name__ == "__main__":
    main()
