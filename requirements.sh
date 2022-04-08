#!/bin/bash
# TODO: Make it for Debian, Suse & Mac

### WARNING: Only Working on RHEL machines actually ####

### Requirements to run this script #####

echo "Set script runnable"
chmod +x *.sh

echo "Install Unzip"
yum -y install unzip

echo "Install network packages"
yum -y install dnsutils
yum -y install bind-utils

echo "Install ansible"
yum -y install ansible

echo "Generates a local key"
mkdir -p ~/.ssh/
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''

echo "Install ansible required collections"
ansible-galaxy collection install community.general
