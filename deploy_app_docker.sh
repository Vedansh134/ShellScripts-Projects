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
REPO_URL="https://github.com/Vedansh134/devops-task.git"
REPO_DIR="devops-task"
BRANCH="main"

echo "Updating ubuntu..."
$SUDO apt-get update

# check git installed or not
if command -v git >/dev/null 2>&1; then
    echo "Git is already installed."
else
    echo "Git is not enabled. Installing Git..."
    $SUDO apt install git -y
fi

code_clone() {
    echo "Cloning (or updating) the repository..."
    if [[ -d $REPO_DIR ]]; then
        echo "Directory $REPO_DIR already exists. Pulling latest changes..."
        cd $REPO_DIR
        git pull
    else
        echo "Cloning the repository..."
        git clone --branch "$BRANCH" "$REPO_URL"
        cd $REPO_DIR
    fi
}

install_requirements() {
    echo "Installing required packages..."
    if command -v docker >/dev/null 2>&1 && command -v nginx >/dev/null 2>&1; then
        echo "Docker and Nginx are already installed."
    else
        echo "Docker and nginx are not installed. Installing Docker & Nginx..."
        $SUDO apt-get install docker.io nginx -y
        $SUDO systemctl start docker.service nginx.service
        $SUDO systemctl enable docker.service nginx.service
    fi
}

required_restarts() {
    $SUDO chown $USER /var/run/docker.sock
    echo "Enabling docker and nginx services..."
    $SUDO systemctl restart docker.service
}

deploy(){
    docker build -t devops-task:latest .
    docker run -d --name devops-task -p 3000:3000 devops-task:latest
}

# main function to call other functions
main() {
    echo "Starting deployment process..."
    code_clone;
    install_requirements;
    required_restarts
    deploy
}

# invoke main function
main
