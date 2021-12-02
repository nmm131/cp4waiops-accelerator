#!/bin/sh

# Install Homebrew"
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
# Install Ansible"
brew install ansible

# Install kafkacat"
brew install kafkacat

#Install node"
brew install node

# Install wget"
brew install wget

#  Install elasticdump"
npm install elasticdump -g

# Install jq"
brew install jq

# Install cloudctl"
curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz -o cloudctl-darwin-amd64.tar.gz
tar xfvz cloudctl-darwin-amd64.tar.gz
mv cloudctl-darwin-amd64 /usr/local/bin/cloudctl
rm cloudctl-darwin-amd64.tar.gz


# Install OpenShift Client"
wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-mac-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
mv oc /usr/local/bin
mv kubectl /usr/local/bin
rm oc.tar.gz
rm README.md

# Install K9s"
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Darwin_x86_64.tar.gz
tar xfzv k9s_Linux_x86_64.tar.gz
mv k9s /usr/local/bin


yum groupinstall 'Development Tools'
yum install procps-ng curl file git
yum install libxcrypt-compat # needed by Fedora 30 and up