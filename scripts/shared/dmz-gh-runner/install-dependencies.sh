#!/bin/bash

# Dependency versions
golangVersion="1.16"

# Set variable for user home directory
user=$1

# Validate input variables
user_id=`id -u $user`
if [ $user_id -eq 0 -o -z "$user" ]; then
    echo "Non root user must be provided. Usage: sudo sh ./install-dependencies.sh <non-root-user>"
    exit 1
fi

# Begin in user home directory
cd /home/$user

# Install dependencies - 

## Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to install Azure CLI. Error code: $errorCode."
    exit 1
fi

## Install Nodejs
sudo snap install node --classic
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to install Nodejs/NPM. Error code: $errorCode."
    exit 1
fi

## Install Helm
sudo snap install helm --classic
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to install Helm. Error code: $errorCode."
    exit 1
fi

## Install KubeCtl
sudo snap install kubectl --classic
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to install KubeCtl. Error code: $errorCode."
    exit 1
fi

## Install GlooCtl
curl -sL https://run.solo.io/gloo/install | sh
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to install GlooCtl. Error code: $errorCode."
    exit 1
fi
# Set in path for current user
export PATH=$PATH:$HOME/.gloo/bin
    
    # TODO: Set in path for all users via environment file ... this is my attempt; it didn't work
    # sudo sed -i "s/PATH=\"/PATH=\"\/home\/$user\/.gloo\/bin:/" /etc/environment

## Install GoLang
wget "https://golang.org/dl/go${golangVersion}.linux-amd64.tar.gz"
sudo tar -C "/usr/local" -xzf "go${golangVersion}.linux-amd64.tar.gz"
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to install GoLang. Error code: $errorCode."
    exit 1
fi
# Set in path for current user
export PATH=$PATH:/usr/local/go/bin
    
    # # TODO: Set in path for all users via environment file ... this is my attempt; it didn't work
    # sudo sed -i "s/PATH=\"/PATH=\"\/usr\/local\/go\/bin:/" /etc/environment

echo "Dependencies successfully installed."
exit 0
