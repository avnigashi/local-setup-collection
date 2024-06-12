#!/bin/bash

# Function to ask the user for confirmation
ask_user() {
  read -p "$1 (y/n) " choice
  if [[ "$choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  else
    return 1
  fi
}

# Docker and Docker Compose installation
if ask_user "Do you want to install Docker and Docker Compose?"; then
  if [ "$(uname -s)" == "Linux" ] && [ -z "$(grep -i microsoft /proc/version)" ]; then
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker ${USER}
    sudo systemctl enable docker
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker --version
    docker-compose --version
    echo "Docker and Docker Compose installation completed successfully!"
    echo "Please log out and log back in to apply group changes."
  else
    echo "Docker installation cancelled by user."
  fi
fi

# Git and SSH configuration for GitHub
if ask_user "Do you want to install Git and configure SSH for GitHub?"; then
  sudo apt-get update
  sudo apt-get install -y git
  if [ -f ~/.ssh/id_rsa ]; then
    echo "An existing SSH key pair was found. Do you want to overwrite it? (y/n)"
    read overwrite
    if [ "$overwrite" != "y" ]; then
      echo "Exiting without creating a new SSH key pair."
      exit 0
    fi
  fi
  echo "Enter your email address for the SSH key:"
  read email
  ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  echo "Your new SSH public key has been generated:"
  cat ~/.ssh/id_rsa.pub
  echo "Copy the above SSH key and add it to your GitHub account under Settings > SSH and GPG keys."
else
  echo "Git installation cancelled by user."
fi

# Node.js and npm installation using NVM
if ask_user "Do you want to install Node.js and npm using NVM?"; then
  sudo apt-get update
  sudo apt-get install -y build-essential libssl-dev
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  node -v
  npm -v
  read -p "Do you want to install Yarn, pnpm, or none? (yarn/pnpm/none) " package_manager_choice
  case "$package_manager_choice" in
    yarn)
      npm install -g yarn
      yarn -v
      ;;
    pnpm)
      npm install -g pnpm
      pnpm -v
      ;;
    none)
      echo "No additional package manager will be installed."
      ;;
    *)
      echo "Invalid choice. No additional package manager will be installed."
      ;;
  esac
else
  echo "Node.js installation cancelled by user."
fi

# Python and related tools installation
if ask_user "Do you want to install Python and related tools?"; then
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y python3 python3-dev python3-venv python3-pip python-is-python3
  python3 --version
  pip3 --version
  pip3 install --upgrade pip
  pip3 install virtualenv
  virtualenv --version
  echo "Python, pip, and virtual environment setup is complete."
  echo "To create a virtual environment, run: python3 -m venv <your-env-name>"
  echo "To activate the virtual environment, run: source <your-env-name>/bin/activate"
  echo "To deactivate the virtual environment, simply run: deactivate"
else
  echo "Python installation cancelled by user."
fi

# PHP and Composer installation
if ask_user "Do you want to install PHP and Composer?"; then
  echo "Please provide a PHP version. Usage: ./switch_php_version.sh <version>"
  read PHP_VERSION
  sudo apt update
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:ondrej/php
  sudo apt update
  if ! dpkg -l | grep -q "php${PHP_VERSION}"; then
    sudo apt install -y php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-common php${PHP_VERSION}-mysql php${PHP_VERSION}-fpm php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-simplexml php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-dom
  fi
  CURRENT_PHP=$(update-alternatives --query php | grep Value: | awk '{print $2}' | sed 's#/usr/bin/php##')
  if [ "$CURRENT_PHP" != "$PHP_VERSION" ]; then
    sudo update-alternatives --set php /usr/bin/php${PHP_VERSION}
    sudo update-alternatives --set phar /usr/bin/phar${PHP_VERSION}
    sudo update-alternatives --set phar.phar /usr/bin/phar.phar${PHP_VERSION}
    sudo update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION}
    sudo update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION}
    if systemctl list-unit-files | grep -q apache2.service; then
      sudo systemctl restart apache2
    fi
    if systemctl list-unit-files | grep -q php${PHP_VERSION}-fpm.service; then
      sudo systemctl restart php${PHP_VERSION}-fpm
    fi
  fi
  if ! command -v composer &> /dev/null; then
    echo "Composer not found. Installing Composer..."
    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', 'composer-setup.php');")
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
      >&2 echo 'ERROR: Invalid installer signature'
      rm composer-setup.php
      exit 1
    fi
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    RESULT=$?
    rm composer-setup.php
    if [ $RESULT -ne 0 ]; then
      >&2 echo 'ERROR: Composer installation failed'
      exit 1
    fi
  fi
  sudo apt install -y php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-simplexml php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-dom
  echo "Switched to PHP $PHP_VERSION and Composer is installed."
else
  echo "PHP installation cancelled by user."
fi
