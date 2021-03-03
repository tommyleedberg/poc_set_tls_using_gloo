# readme

## Execute install dependencies script

```shell
sudo sh ./install-dependencies.sh ghrunner
```

## Execute configure script

```Shell
sudo sh ./configure-gh-runner.sh ghrunner https://github.com/peterotoole/github-actions-course-template AP4PSXU6EYECL6GWFU6VD2TAGURGQ
```

## DMZ GitHub Runner VM Deployment

```PowerShell
az login
az account set --subscription "f2f53eaa-44eb-4a72-9270-130f0c9f1582"

# Create resource group
az group create --location eastus --name dp-dev-petertesting-rg-eu

# Run template deployment
az deployment create --location eastus --template-file .\vm-creation.template.json --parameters .\vm-creation.parameters.json --name dmz-github-runner-vm
```

## DMZ GitHub Runner VM Script Execution

```PowerShell
az login
az account set --subscription "f2f53eaa-44eb-4a72-9270-130f0c9f1582"

# Create container
az storage container create --account-name tdpdevpeterfileshare --name github-runner-scripts

# Upload scripts
az storage blob upload --account-name tdpdevpeterfileshare --container-name github-runner-scripts --file .\configure-gh-runner.sh --name configure-gh-runner.sh
az storage blob upload --account-name tdpdevpeterfileshare --container-name github-runner-scripts --file .\install-dependencies.sh --name install-dependencies.sh

# Generate SAS tokens
$end=date -u -d "90 minutes" '+%Y-%m-%dT%H:%MZ'
az storage blob generate-sas --account-name tdpdevpeterfileshare --container-name github-runner-scripts --name configure-gh-runner.sh --permissions r --expiry $end --https-only --full-uri
az storage blob generate-sas --account-name tdpdevpeterfileshare --container-name github-runner-scripts --name install-dependencies.sh --permissions r --expiry $end --https-only --full-uri

# Run template deployment for dependency installation
az deployment create --location eastus --template-file .\run-dependencies-installation-script.template.json --parameters .\run-dependencies-installation-script.parameters.json --name dmz-github-runner-install-dependencies

# Run template deployment for github runner package configuration
az deployment create --location eastus --template-file .\run-config-script.template.json --parameters .\run-config-script.parameters.json --name dmz-github-runner-configure-gh-runner
```

## Scratch Pad

```Shell

/home/ghrunner/.gloo/bin

52.168.139.249
ghrunner
gTQApKwR9UfTLUBJ

curl -sL https://run.solo.io/gloo/install | sudo -u $user sh

export PATH=/usr/local/go/bin:$PATH
export PATH=/home/$user/.gloo/bin:$PATH
export PATH=/home/ghrunner/.gloo/bin:$PATH

/etc/environment

sed 's/# PATH="/PATH="/home/peter/.gloo/bin:' ./test.txt

sed 's%PATH=% c PATH=123%' ./test.txt

sed -i 's/# PATh/PATH123/' ./test.txt
```
