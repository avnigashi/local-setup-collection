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
if [ ! -d "auto1111-env" ]; then
    echo "Creating virtual environment..."
    python3.11 -m venv auto1111-env
fi

# Step 3: Activate the virtual environment
echo "Activating virtual environment..."
source auto1111-env/bin/activate

# Step 4: Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Step 5: Clone the AUTOMATIC1111 repository if not already cloned
clone_automatic1111_repo

# Step 6: Ensure the AUTOMATIC1111 script has execution permissions
echo "Ensuring AUTOMATIC1111 script has execution permissions..."
chmod +x automatic1111/webui-user.sh

# Step 8: Install required Python packages for AUTOMATIC1111
echo "Installing required Python packages..."
pip install -r automatic1111/requirements.txt

# Step 9: Start AUTOMATIC1111 with API access
echo "Starting AUTOMATIC1111 with API access..."
cd automatic1111
./webui-user.sh --api --listen

echo "AUTOMATIC1111 is now running with API access. Enjoy! 😄"
