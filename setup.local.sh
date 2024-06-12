#!/bin/bash

# Check if the system is Linux and not WSL
if [ "$(uname -s)" == "Linux" ] && [ -z "$(grep -i microsoft /proc/version)" ]; then

  # Prompt user to confirm Docker installation
  read -p "Do you want to install Docker and Docker Compose? (y/n) " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

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
