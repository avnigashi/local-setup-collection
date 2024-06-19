#!/bin/bash

# Function to check if a command exists
command_exists () {
    command -v "$1" &> /dev/null ;
}

# Function to clone the AUTOMATIC1111 repository if it does not exist
clone_automatic1111_repo () {
    if [ ! -d "automatic1111" ]; then
        echo "Cloning AUTOMATIC1111 repository..."
        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git automatic1111
    fi
}

# Step 1: Check if Python 3.11 is installed
if ! command_exists python3.11 ; then
    echo "Python 3.11 is not installed. Please install Python 3.11 and try again."
    exit 1
fi

# Step 2: Create a virtual environment if it does not exist
if [ ! -d "open-webui-env" ]; then
    echo "Creating virtual environment..."
    python3.11 -m venv open-webui-env
fi

# Step 3: Activate the virtual environment
echo "Activating virtual environment..."
source open-webui-env/bin/activate

# Step 4: Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Step 5: Install Open WebUI if not already installed
if ! pip show open-webui &> /dev/null; then
    echo "Installing Open WebUI..."
    pip install open-webui
fi

# Step 6: Clone the AUTOMATIC1111 repository if not already cloned
clone_automatic1111_repo

# Step 7: Ensure the AUTOMATIC1111 script has execution permissions
echo "Ensuring AUTOMATIC1111 script has execution permissions..."
chmod +x automatic1111/webui-user.sh

# Step 8: Install ffmpeg if not already installed
if ! command_exists ffmpeg ; then
    echo "Installing ffmpeg..."
    sudo apt-get update
    sudo apt-get install -y ffmpeg
fi

# Step 9: Start AUTOMATIC1111 with API access
echo "Starting AUTOMATIC1111 with API access..."
cd automatic1111
./webui-user.sh --api --listen &

# Step 10: Wait for AUTOMATIC1111 to start
sleep 10  # Adjust this sleep duration as necessary to ensure AUTOMATIC1111 is fully started

# Step 11: Ensure required packages for Open WebUI are installed
pip install sentence-transformers transformers

# Step 12: Start Open WebUI
echo "Starting Open WebUI..."
cd ..
open-webui serve

echo "Open WebUI is now running at http://localhost:8080. Enjoy! 😄"
