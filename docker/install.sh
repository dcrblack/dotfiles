#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "$SCRIPT_DIR"/../common

# Install docker engine 
if [[ $OSTYPE == "darwin"* ]]; then
    true
else
    # From https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Setup gpg keys and apt sources list
    sudo mkdir -p /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    fi

    if ! grep -i "docker" /etc/apt/sources.list.d/docker.list; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    # Install the docker engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Make sure the docker group exists
    if ! getent group docker; then
        sudo groupadd docker
    fi

    # Add the current user to the docker group
    sudo usermod -aG docker "$USER"
fi
