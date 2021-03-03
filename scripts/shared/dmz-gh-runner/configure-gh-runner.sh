#!/bin/bash

# Package versions
runnerVersion="2.277.1"

# Additional variables :) 
runnerDownloadUrl="https://github.com/actions/runner/releases/download/v$runnerVersion/actions-runner-linux-x64-$runnerVersion.tar.gz"
runnerPackageName="./actions-runner-linux-x64-$runnerVersion.tar.gz"
defaultLabels="'self-hosted,Linux,X64'"

# Set variables for user, repo url, and token
user=$1
repo_url=$2
repo_token=$3
runner_labels=$4

# Validate input variables
user_id=`id -u $user`
if [ $user_id -eq 0 -o -z "$user" ]; then
    echo "Non root user must be provided. Usage: sudo sh ./configure-gh-runner.sh <non-root-user> <repo-url> <repo-token> <optional:labels>"
    exit 1
fi

if [ -z "$repo_url" ]; then
    echo "Repo URL must be provided. Usage: sudo sh ./configure-gh-runner.sh <non-root-user> <repo-url> <repo-token> <optional:labels>"
    exit 1
fi

if [ -z "$repo_token" ]; then
    echo "Repo token must be provided. Usage: sudo sh ./configure-gh-runner.sh <non-root-user> <repo-url> <repo-token> <optional:labels>"
    exit 1
fi

if [ -z "$runner_labels" ]; then
    runner_labels=$defaultLabels
fi

# Create a folder for the GitHub runner installation/setup and cd into it
cd /home/$user
sudo -u $user mkdir actions-runner
cd actions-runner
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Cannot open directory /home/$user/actions-runner. Error code: $errorCode."
    exit 1
fi

# Download the latest runner package
curl -O -L $runnerDownloadUrl
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Failed to download runner package from $runnerDownloadUrl. Error code: $errorCode."
    exit 1
fi

# Extract the installer
sudo -u $user tar xzf $runnerPackageName
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "Package $runnerPackageName extract (using tar) failed. Error code: $errorCode."
    exit 1
fi

# Create the runner with default configuration (running in unattended mode)
sudo -u $user ./config.sh --url $repo_url --token $repo_token --labels $runner_labels --unattended
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "GitHub runner config script failed. Error code: $errorCode."
    exit 1
fi

# Install as a systemd service
sudo ./svc.sh install
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "GitHub runner service installation failed. Error code: $errorCode."
    exit 1
fi

# Start the service
sudo ./svc.sh start
errorCode=$?
if [ $errorCode -ne 0 ]; then
    echo "GitHub runner service start failed. Error code: $errorCode."
    exit 1
fi

echo "GitHub self-hosted runner setup completed successfully."
exit 0
