#!/bin/bash

# Define the installation directory, defaulting to $HOME/.local/bin if not provided
INSTALL_DIR="${DIR:-$HOME/.local/bin}"

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download and run the LazyDocker install script
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR="$INSTALL_DIR" bash

# Add the installation directory to PATH if it's not already there
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
  source "$HOME/.bashrc"
fi

echo "LazyDocker installation complete. You may need to restart your terminal session for changes to take effect."
