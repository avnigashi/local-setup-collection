#!/bin/bash
  read -p "Do you want to install Docker and Docker Compose? (y/n) " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

# Check if the system is Linux and not WSL
if [ "$(uname -s)" == "Linux" ] && [ -z "$(grep -i microsoft /proc/version)" ]; then

  # Prompt user to confirm Docker installation

    # Update package index
    sudo apt-get update

    # Install prerequisite packages
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker APT repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package index again
    sudo apt-get update

    # Install Docker CE
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Add user to the docker group
    sudo usermod -aG docker ${USER}

    # Enable Docker service to start on boot
    sudo systemctl enable docker

    # Install Docker Compose
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Apply executable permissions to the Docker Compose binary
    sudo chmod +x /usr/local/bin/docker-compose

    # Verify installation
    docker --version
    docker-compose --version

    # Print completion message
    echo "Docker and Docker Compose installation completed successfully!"
    echo "Please log out and log back in to apply group changes."

    # Optionally, reboot the system
    # sudo reboot
  else
    echo "Installation cancelled by user."
  fi

fi

# Ask user if they want to install Git and configure SSH for GitHub
read -p "Do you want to install Git and configure SSH for GitHub? (y/n) " install_choice
if [[ "$install_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then

  # Update package index
  sudo apt-get update

  # Install Git
  sudo apt-get install -y git

  # Check for existing SSH keys
  if [ -f ~/.ssh/id_rsa ]; then
    echo "An existing SSH key pair was found. Do you want to overwrite it? (y/n)"
    read overwrite
    if [ "$overwrite" != "y" ]; then
      echo "Exiting without creating a new SSH key pair."
      exit 0
    fi
  fi

  # Generate a new SSH key pair
  echo "Enter your email address for the SSH key:"
  read email
  ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""

  # Start the ssh-agent in the background
  eval "$(ssh-agent -s)"

  # Add the SSH private key to the ssh-agent
  ssh-add ~/.ssh/id_rsa

  # Display the public key
  echo "Your new SSH public key has been generated:"
  cat ~/.ssh/id_rsa.pub

  # Instructions to add SSH key to GitHub
  echo "Copy the above SSH key and add it to your GitHub account under Settings > SSH and GPG keys."
else
  echo "Installation and configuration cancelled by user."
fi

#!/bin/bash

# Ask user if they want to install Node.js and npm using NVM
read -p "Do you want to install Node.js and npm using NVM? (y/n) " install_choice
if [[ "$install_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then

  # Update package index
  sudo apt-get update

  # Install required packages
  sudo apt-get install -y build-essential libssl-dev

  # Download and install NVM
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

  # Source NVM script to add nvm command to the current shell session
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Install the latest LTS version of Node.js
  nvm install --lts

  # Verify installation
  node -v
  npm -v

else
  echo "Installation cancelled by user."
fi

