#!/bin/bash

# Step 1: Check if Python 3.11 is installed
if ! command -v python3.11 &> /dev/null
then
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

# Step 6: Start Open WebUI
echo "Starting Open WebUI..."
open-webui serve

echo "Open WebUI is now running at http://localhost:8080. Enjoy! 😄"
