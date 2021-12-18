#!/bin/sh
#update package mananger
apt-get update

#install Kafkacat
apt-get install -y kafkacat

# Install Ansible
# apt-get install -y npm
# apt install -y software-properties-common
# add-apt-repository --yes --update ppa:ansible/ansible
# apt install -y ansible
pip3 install ansible
pip3 install kubernetes

# Install npm
apt-get install -y npm

#Install node
# apt install nodejs

# Install Elasticdump
npm install elasticdump -g

# Install jq
apt-get install -y jq

# Install cloudctl
# curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz -o cloudctl-darwin-amd64.tar.gz
# tar xfvz cloudctl-darwin-amd64.tar.gz
# mv -f cloudctl-darwin-amd64 /usr/local/bin/cloudctl
# rm -f cloudctl-darwin-amd64.tar.gz
curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz
# wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz.sig
tar xzfv cloudctl-linux-amd64.tar.gz
mv -f cloudctl-linux-amd64 /usr/local/bin/cloudctl
rm -f cloudctl-linux-amd64.tar.gz

# Install helm
wget -L https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz -O helm.tar.gz
tar xfvz helm.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -r linux-amd64/
rm helm.tar.gz

# Install OpenShift Client
wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-linux-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
mv -f oc /usr/local/bin
mv -f kubectl /usr/local/bin
rm -f oc.tar.gz
rm -f README.md

# install k9's
# wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
# tar xfzv k9s_Linux_x86_64.tar.gz
# mv k9s /usr/local/bin
# rm LICENSE
# rm README.md