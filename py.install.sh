#!/bin/bash

# Update the package list and install prerequisites
sudo apt update
sudo apt install -y wget build-essential libssl-dev zlib1g-dev \
libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev \
libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev \
tk-dev libffi-dev uuid-dev

# Set the version of Python to install
PYTHON_VERSION=3.11.0

# Download Python 3.11 source code
cd /usr/src
sudo wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz

# Extract the tarball
sudo tar xzf Python-$PYTHON_VERSION.tgz

# Compile and install Python
cd Python-$PYTHON_VERSION
sudo ./configure --enable-optimizations
sudo make altinstall

# Verify the installation
python3.11 --version

echo "Python 3.11 installation is complete!"
