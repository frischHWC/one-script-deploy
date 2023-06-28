#!/bin/bash
# TODO: Make it for Debian, Suse & Mac

if [ $# -ne 1 ]
then
  echo "ERROR: missing machine_type=[rhel|debian|suse|mac] argument"
  exit 1
fi

machine_type=$1

if [ -z $machine_type ]
then
    machine_type="rhel"
fi

echo "Will run requirements for $machine_type"

### Requirements to run this script #####

echo "Set script runnable"
chmod +x *.sh

if [ "$machine_type" == "rhel" ]
then

    echo "Install wget"
    yum -y install wget

    echo "Install Git"
    yum -y install git

    echo "Install Unzip"
    yum -y install unzip

    echo "Install network packages"
    yum -y install dnsutils
    yum -y install bind-utils

    echo "Install Python 3"
    yum -y install python3

    echo "Install ansible"
    yum -y install epel-release
    yum -y install ansible


elif [ "$machine_type" == "debian" ]
then

    echo "Install wget"
    apt -y install wget

    echo "Install Git"
    apt -y install wget

    echo "Install Unzip"
    apt -y install unzip

    echo "Install network packages"
    apt -y install dnsutils
    apt -y install bind9-utils

    echo "Install Python 3"
    apt -y install python3

    echo "Install ansible"
    apt -y install ansible


elif [ "$machine_type" == "suse" ]
then

    echo "Install wget"
    zypper -n install wget

    echo "Install Git"
    zypper -n install git

    echo "Install Unzip"
    zypper -n install unzip

    echo "Install network packages"
    zypper -n install bind-utils

    echo "Install Python 3"
    zypper -n install python3

    echo "Install ansible"
    zypper -n install ansible

elif [ "$machine_type" == "mac" ]
then

    echo "TODO: Install wget"

    echo "TODO: Install Git"

    echo "TODO: Install Unzip"

    echo "TODO: Install network packages"

    echo "TODO: Install Python 3"

    echo "TODO:Install ansible"

fi

if [ ! -d "~/.ssh/" ]
then
  echo "Creates .ssh directory"
  mkdir -p ~/.ssh/
fi
if [ ! -f "~/.ssh/id_rsa" ]
then
  echo "Generates a local key"
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
fi

echo "Install ansible required collections"
ansible-galaxy collection install community.general
ansible-galaxy collection install freeipa.ansible_freeipa
ansible-galaxy collection install community.crypto
