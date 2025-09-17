#!/bin/bash
#
################################################################################
#============================= deploy a django app =============================
################################################################################
#
# Version: 1.0
# Author: Vedansh kumar
# Description: This script builds a Docker image from a Dockerfile and pushes it to Docker Hub.
#
#
# testing (change to set -xeou pipefail for testing)
set +xeou pipefail

# define variables
SUDO='sudo'

echo "Updating ubuntu..."
$SUDO apt-get update

# check git installed or not
if git --version >/dev/null 2>&1; then
    echo "Git is already installed."
else
    echo "Git is not enabled. Installing Git..."
    $SUDO apt install git -y
fi

code_clone() {
    echo "Cloning the repository..."
    git clone https://github.com/Vedansh134/django-notes-app.git
    # check if dir exists or not
    if [[ ! -d django-notes-app]]; then
        echo "Directory django-notes-app does not exist. Exiting..."
        exit 1
    fi
    cd django-notes-app
}

install_requirements() {
    echo "Installing required packages..."
    if docker --version >/dev/null 2>&1 && nginx --version >/dev/null 2>&1; then
        echo "Docker and Nginx are already installed."
    else
        echo "Docker and nginx are not installed. Installing Docker & Nginx..."
        $SUDO apt-get install docker.io nginx -y
        $SUDO systemctl start docker.service nginx.service
        $SUDO systemctl enable docker.service nginx.service
    fi
}

required_restarts() {
    echo "Enabling docker and nginx services..."
    $SUDO systemctl restart docker.service nginx.service
}

deploy(){
    docker build -t vedansh134/django-notes-app:latest .
    docker run -d -p 8000:8000 vedansh134/django-notes-app:latest
}

# main function to call other functions
main() {
    echo "Starting deployment process..."
    code_clone
    if ! install_requirements; then
        echo "Failed to install required packages. Exiting..."
        exit 1
    fi
    required_restarts
    deploy
}

# invoke main function
main
