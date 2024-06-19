#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Step 1: Install necessary dependencies based on the operating system
if [ -f /etc/debian_version ]; then
    echo "Installing dependencies for Debian-based system..."
    sudo apt update
    sudo apt install -y wget git python3 python3-venv libgl1 libglib2.0-0
elif [ -f /etc/redhat-release ]; then
    echo "Installing dependencies for Red Hat-based system..."
    sudo dnf install -y wget git python3 gperftools-libs libglvnd-glx
elif [ -f /etc/arch-release ]; then
    echo "Installing dependencies for Arch-based system..."
    sudo pacman -Syu --noconfirm wget git python3
elif [ -f /etc/SuSE-release ]; then
    echo "Installing dependencies for openSUSE-based system..."
    sudo zypper install -y wget git python3 libtcmalloc4 libglvnd
else
    echo "Unsupported operating system. Please install dependencies manually."
    exit 1
fi

# Step 2: Check if Python 3.10.6 is installed
if ! command_exists python3.10; then
    echo "Python 3.10.6 is not installed. Please install Python 3.10.6 and try again."
    exit 1
fi

# Step 3: Clone the stable-diffusion-webui repository
if [ ! -d "stable-diffusion-webui" ]; then
    echo "Cloning the stable-diffusion-webui repository..."
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
fi

# Step 4: Navigate to the repository directory
cd stable-diffusion-webui || exit

# Step 5: Create a virtual environment if it does not exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3.10 -m venv venv
fi

# Step 6: Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Step 7: Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Step 8: Install required Python packages
echo "Installing required Python packages..."
pip install -r requirements.txt

# Step 9: Run the web UI server
echo "Starting the web UI server..."
bash webui.sh

echo "Stable Diffusion web UI is now running. Enjoy! 😄"
