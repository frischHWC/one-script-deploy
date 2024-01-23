#!/bin/bash

###############################
# Setup of all variables and help
###############################

# Main cluster info
export CLUSTER_NAME=
export NODES_BASE=
export NODE_IPA=
export NODES_KTS=

# License 
export PAYWALL_USER=
export PAYWALL_PASSWORD=
export LICENSE_FILE=
export CM_LICENSE_TYPE="enterprise"

# Nodes connection
export NODE_USER="root"
export NODE_KEY=""
export NODE_PASSWORD=""
export SETUP_HOSTS_KEYS="true"
export SETUP_ETC_HOSTS="true"

# Steps to do
export PRE_INSTALL="true"
export PREPARE_ANSIBLE_DEPLOYMENT="true"
export INSTALL="true"
export POST_INSTALL="true"
export USER_CREATION="true"
export DATA_LOAD="false"
export DEMO="false"

# Auth & Log
export DEFAULT_PASSWORD="Cloudera1234"
export DEFAULT_ADMIN_USER="francois"
export DEBUG="false"
export LOG_DIR="/tmp/deploy_to_cloudcat_logs/"$(date +%m-%d-%Y-%H-%M-%S)

# Ansible Deployment files 
export DISTRIBUTION_TO_DEPLOY="CDP"
export CLUSTER_TYPE="full"
export ANSIBLE_HOST_FILE="ansible-cdp/hosts"
export ANSIBLE_ALL_FILE="ansible-cdp/all"
export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp/cluster.yml"
export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp/extra_vars.yml"

# Security
export KERBEROS="true"
export TLS="true"
export FREE_IPA="false"
export REALM="FRISCH.COM"
export ENCRYPTION_ACTIVATED="false"

# Versions
export CM_VERSION="7.11.3.3"
export CDH_VERSION="7.1.9.3"
export CSA_VERSION="1.11.0.0"
export CFM_VERSION="2.1.6.0"
export SPARK3_VERSION="3.3.7180.14"
export WXM_VERSION="2.3.0"
export PVC_VERSION="1.5.2-h1"
export AMBARI_VERSION="2.7.5.0"
export HDP_VERSION="3.1.5.6091"
export HDF_VERSION="3.5.0.0"

# Repository (if not specified, version is used to guess repository from it)
export CM_REPO=
export CDH_REPO=
export PVC_REPO=
export CSA_BASE_REPO=
export CFM_BASE_REPO=
export SPARK3_BASE_REPO=
export WXM_BASE_REPO=
export AMBARI_REPO=
export HDP_REPO=
export HDF_REPO=

# Database
export DATABASE_TYPE="postgresql"
export DATABASE_VERSION="14"

# OS Related
export OS="centos"
export OS_VERSION="7.9"
export INSTALL_PYTHON3="true"

# PVC related
export CLUSTER_NAME_PVC=
export NODES_PVC_ECS=
export KUBECONFIG_PATH=
export INSTALL_PVC="true"
export CONFIGURE_PVC="true"
export SKIP_PVC_PREREQS="false"
export PVC="false"
export PVC_TYPE="ECS"
export CREATE_CDW="true"
export CREATE_CDE="true"
export CREATE_CML="true"
export CREATE_CML_REGISTRY="true"
export CREATE_VIZ="true"
export OC_TAR_FILE_PATH=""
export CONFIGURE_OC="true"
export SETUP_DNS_ECS="true"
export PVC_APP_DOMAIN=""
export PVC_ECO_RESOURCES="false"
export SETUP_PVC_TOOLS="false"
export ECS_SSD_DEDICATED_NODES=""
export ECS_GPU_DEDICATED_NODES=""

# External CSD
export USE_CSA="false"
export USE_CFM="false"
export USE_SPARK3="false"
export USE_WXM="false"

# WXM Related
export ALTUS_KEY_ID=
export ALTUS_PRIVATE_KEY=
export CM_BASE_URL=
export CM_BASE_USER="admin"
export CM_BASE_PASSWORD="admin"
export TP_HOST=

# Installation
export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/heads/main.zip"
export ANSIBLE_REPO_DIR="cldr-playbook-main"
export CM_COLOR="RANDOM"
export ROOT_CA_CERT=
export ROOT_CA_KEY=

# Data Load
export DATA_LOAD_REPO_URL=""
export DATAGEN_AS_A_SERVICE="true"
export DATAGEN_REPO_URL="https://github.com/frischHWC/datagen"
export DATAGEN_REPO_BRANCH="main"
export DATAGEN_REPO_PARCEL=""
export DATAGEN_CSD_URL=""
export DATAGEN_VERSION="0.4.13"
export EDGE_HOST=""

# Demo
export DEMO_REPO_URL="https://github.com/frischHWC/cdp-demo"
export DEMO_REPO_BRANCH="main"

# CDH 6 - KTS 
export CDH6_KTS_PATH="~/Downloads/keytrustee-server-6.1.0-parcels.tar.gz"
export CDH6_KTS_KMS_PATH="~/Downloads/keytrustee-kms-6.3.0-parcels.tar.gz"

# INTERNAL USAGE OF THESE VARIABLES, do no touch these
export KTS_SERVERS=""
export KTS_SERVERS_GROUP=""
export KTS_ACTIVE=""
export KTS_PASSIVE=""
export KRB5_SERVERS=""
export KRB_SERVER_TYPE=""
export CA_SERVERS=""
export KMS_SERVERS=""
export ANSIBLE_PYTHON_3_PARAMS=""
export USE_ANSIBLE_PYTHON_3="false"
export PVC_ECS_SERVER_HOST=""
export CLUSTER_NAME_STREAMING=""
export USE_ROOT_CA="false"
export USE_OUTSIDE_PAYWALL_BUILDS="false"
export FREE_IPA_TRIES=2
# To solve any potential issue with UTF-8
export ENV='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

function usage()
{
    echo "This script is to install an CDP/CDH/HDP cluster on various machines, and creates a minimal setup "
    echo ""
    echo "Usage is the following : "
    echo ""
    echo "./setup-cluster.sh"
    echo "  -h --help"
    echo ""
    echo " These are the mandatory settings to launch a deployment : "
    echo ""
    echo "  --cluster-name=$CLUSTER_NAME Required as it will be the name of the cluster (Default) $CLUSTER_NAME "
    echo ""
    echo "  --paywall-username=$PAYWALL_USER : Required since February 2021 for all versions (Default) $PAYWALL_USER  "
    echo "  --paywall-password=$PAYWALL_PASSWORD : Required since February 2021 for all versions (Default) $PAYWALL_PASSWORD  "
    echo "  --license-file=$LICENSE_FILE : The path to license file (Default) $LICENSE_FILE "
    echo ""
    echo "  --node-user=$NODE_USER : The user to connect to each node (Default) $NODE_USER "
    echo "  --node-key=$NODE_KEY : The key to connect to all nodes (Default) $NODE_KEY "
    echo "  --node-password=$NODE_PASSWORD : The password to connect to all nodes (Default) $NODE_PASSWORD "
    echo "  --setup-hosts-keys=$SETUP_HOSTS_KEYS : If needed to setup hosts keys between hosts (to allow passwordless connections) Set it to false on some Cloud Provider already setup machines (Default) $SETUP_HOSTS_KEYS "
    echo "  --setup-etc-hosts=$SETUP_ETC_HOSTS : To push an /etc/hosts configured on all host, Set it to false generally for Cloud Provider as they use internal DNS (Default) $SETUP_ETC_HOSTS "
    echo ""
    echo "  --nodes-base=$NODES_BASE : A Space separated list of all nodes (Default) $NODES_BASE "
    echo "  --node-ipa=$NODE_IPA : Required only if using FreeIPA (Default) $NODE_IPA "
    echo "  --nodes-kts=$NODES_KTS : Required only if using KTS as a space separated list of maximum two nodes (Default) $NODES_KTS "
    echo "  --nodes-ecs=$NODES_PVC_ECS : (Optional) A Space separated list of ECS nodes (external to cluster) where to install ECS (Default) $NODES_PVC_ECS  "
    echo ""
    echo "  --cluster-type=$CLUSTER_TYPE : To simplify deployment, this parameter will adjust number of nodes, security and templates to deploy.  (Default) $CLUSTER_TYPE"
    echo "       Choices: basic, basic-enc, streaming, pvc, pvc-oc, full, full-enc-pvc, wxm, cdh5, cdh6, hdp3, hdp2 (Default) $ Will install a CDP 7 with almost all services "
    echo ""
    echo ""
    echo " These are optionnal parameters to test the deployment and run certain steps only : "
    echo ""
    echo ""
    echo "  --pre-install=$PRE_INSTALL : (Optional) To do setup scripts (Default) $PRE_INSTALL "
    echo "  --install=$INSTALL : (Optional) To do the installation, it is only for debugging purpose (Default) $INSTALL "
    echo "  --post-install=$POST_INSTALL : (Optional) To do post install tasks (such as CM no unlogin) (Default) $POST_INSTALL"
    echo "  --user-creation=$USER_CREATION : (Optional) Creates two users with their keytabs and home directory on all nodes (Required if loading data) (Default) $USER_CREATION " 
    echo "  --data-load=$DATA_LOAD : (Optional) Whether to initiate post deployment tasks including data loading (Default) $DATA_LOAD "
    echo "  --demo=$DEMO : (Optional) Whether to setup or not demo data, users and jobs on the cluster (Default) $DEMO "
    echo "  --prepare-ansible-deployment=$PREPARE_ANSIBLE_DEPLOYMENT : (Optional) To prepare deployment by copying and setting all files for deployment on node 1 (Default) $PREPARE_ANSIBLE_DEPLOYMENT"
    echo "  --install-pvc=$INSTALL_PVC : (Optional) To launch installation of PVC (Default) $INSTALL_PVC"
    echo "  --configure-pvc=$CONFIGURE_PVC : (Optional) To launch configuration of PVC (Default) $CONFIGURE_PVC"
    echo "  --skip-pvc-prereqs=$SKIP_PVC_PREREQS : (Optional) To avoid launching pvc prerequisites (TLS DB) $SKIP_PVC_PREREQS"
    echo "  --debug=$DEBUG : (Optional) To setup debug mode for all playbooks (Default) $DEBUG"
    echo "  --log-dir=$LOG_DIR : (Optional) To specify where this script will logs its files (Default) $LOG_DIR "
    echo ""
    echo ""
    echo " These are optionnal parameters to tune and configure differently the deployment :"
    echo ""
    echo ""
    echo "  --default-password=$DEFAULT_PASSWORD : (Optional) Password used for UIs (Default) $DEFAULT_PASSWORD "
    echo "  --default-admin-user=$DEFAULT_ADMIN_USER : (Optional) User setup with its keytab and rights on all services (It has default password) (Default) $DEFAULT_ADMIN_USER "
    echo ""
    echo "  --ansible-host-file=$ANSIBLE_HOST_FILE : (Optional) The path to ansible hosts file (Default) $ANSIBLE_HOST_FILE "
    echo "  --ansible-all-file=$ANSIBLE_ALL_FILE : (Optional) The path to ansible all file  (Default) $ANSIBLE_ALL_FILE"
    echo "  --ansible-cluster-file=$ANSIBLE_CLUSTER_YML_FILE : (Optional) The path to ansible yaml cluster file (Default) $ANSIBLE_CLUSTER_YML_FILE"
    echo "  --ansible-extravars-file=$ANSIBLE_EXTRA_VARS_YML_FILE : (Optional) The path to ansible extra_vars file  (Default) $ANSIBLE_EXTRA_VARS_YML_FILE"
    echo "  --distribution-to-deploy=$DISTRIBUTION_TO_DEPLOY : (Optional) Choose between CDP, CDH, HDP (Default) $DISTRIBUTION_TO_DEPLOY"
    echo "  --cm-color=$CM_COLOR : (Optional) Only for CDP: Choose between BROWN, RED, BLACK, GREEN, TEAL, PINK, YELLOW, GRAY, PURPLE, BLUE, DARKBLUE or RANDOM (Default) RANDOM"
    echo "  --cm-license-type=$CM_LICENSE_TYPE : (Optional) Change this to trial if you do not have a license (Default) $CM_LICENSE_TYPE"
    echo ""
    echo "  --cm-version=$CM_VERSION : (Optional) Version of CM (Default) $CM_VERSION "
    echo "  --cdh-version=$CDH_VERSION : (Optional) Version of CDH (Default) $CDH_VERSION "
    echo "  --csa-version=$CSA_VERSION : (Optional) Version of CSA (Default) $CSA_VERSION "
    echo "  --cfm-version=$CFM_VERSION : (Optional) Version of CFM (Default) $CFM_VERSION "
    echo "  --ambari-version=$AMBARI_VERSION : (Optional) Version of Ambari (Default) $AMBARI_VERSION "
    echo "  --hdp-version=$HDP_VERSION : (Optional) Version of HDP (Default) $HDP_VERSION "
    echo "  --hdf-version=$HDF_VERSION : (Optional) Version of HDP (Default) $HDF_VERSION "
    echo "  --spark3-version=$SPARK3_VERSION : (Optional) Version of SPARK3 (Default) $SPARK3_VERSION"
    echo "  --wxm-version=$WXM_VERSION : (Optional) Version of WXM (Default) $WXM_VERSION"
    echo "  --pvc-version=$PVC_VERSION : (Optional) Version of PVC for CDP deployment (Default) $PVC_VERSION "
    echo ""
    echo "  --cm-repo=$CM_REPO : (Optional) repo of CM (Default) $CM_REPO "
    echo "  --cdh-repo=$CDH_REPO : (Optional) repo of CDH (Default) $CDH_REPO "
    echo "  --csa-repo=$CSA_BASE_REPO : (Optional) repo of CSA (Default) $CSA_BASE_REPO "
    echo "  --cfm-repo=$CFM_BASE_REPO : (Optional) repo of CFM (Default) $CFM_BASE_REPO "
    echo "  --spark3-repo=$SPARK3_BASE_REPO : (Optional) repo of SPARK3 (Default) $SPARK3_BASE_REPO "
    echo "  --wxm-repo=$WXM_BASE_REPO : (Optional) repo of WXM (Default) $WXM_BASE_REPO "
    echo "  --ambari-repo=$AMBARI_REPO : (Optional) repo of Ambari (Default) $AMBARI_REPO "
    echo "  --hdp-repo=$HDP_REPO : (Optional) repo of HDP (Default) $HDP_REPO "
    echo "  --hdf-repo=$HDF_REPO : (Optional) repo of HDP (Default) $HDF_REPO "
    echo "  --pvc-repo=$PVC_REPO : (Optional) repo of PVC for CDP deployment (Default) $PVC_REPO "
    echo ""
    echo "  --database-type=$DATABASE_TYPE : (Optional) Type of the base database to deploy among: postgres, mysql, mariadb  (Default) $DATABASE_TYPE "
    echo "  --database-version=$DATABASE_VERSION : (Optional) Version of the base database to deploy  (Default) $DATABASE_VERSION "
    echo ""
    echo "  --kerberos=$KERBEROS : (Optional) To set up Kerberos or not (Default) $KERBEROS "
    echo "  --realm=$REALM : (Optional) Realm specified for kerberos(Default) $REALM "
    echo "  --tls=$TLS : (Optional) DEPRECATED for CDP: Use auto-tls instead, To set up TLS or not (Default) $TLS "
    echo "  --free-ipa=$FREE_IPA : (Optional) To install Free IPA and use it or not (Default) $FREE_IPA "
    echo "  --encryption-activated=$ENCRYPTION_ACTIVATED : (Optional) To setup TDE with KTS/KMS (only on CDP) (Default) $ENCRYPTION_ACTIVATED  "
    echo "  --root-ca-cert=$ROOT_CA_CERT : (Optional) To provide your own root certificate that will sign all others for convenience use (only on CDP) (Default) $ROOT_CA_CERT  "
    echo "  --root-ca-key=$ROOT_CA_KEY : (Optional) To provide your own root certificate that will sign all others for convenience use (only on CDP) (Default) $ROOT_CA_KEY  "
    echo ""
    echo "  --os=$OS : (Optional) OS to use (Default) $OS"
    echo "  --os-version=$OS_VERSION : (Optional) OS version to use (Default) $OS_VERSION" 
    echo "  --install-python3=$INSTALL_PYTHON3 : (Optional) To install python3 on all hosts (Default) $INSTALL_PYTHON3 "
    echo "  --ansible-python-3=$USE_ANSIBLE_PYTHON_3 : (Optional) To use python3 for ansible (Default) $USE_ANSIBLE_PYTHON_3 "
    echo ""
    echo "  --pvc=$PVC : (Optional) If PVC should be deployed and configured (Default) $PVC "
    echo "  --pvc-type=$PVC_TYPE : (Optional) Which type of PVC (OC or ECS) (Default) $PVC_TYPE "
    echo "  --nodes-ecs=$NODES_PVC_ECS : (Optional) A Space separated list of ECS nodes (external to cluster) where to install ECS (Default) $NODES_PVC_ECS  "
    echo "  --pvc-app-domain=$PVC_APP_DOMAIN (Optional) To use with PVC ECS to specify the app domain (that will be suffix url for all your deployments) (Default) $PVC_APP_DOMAIN "
    echo "  --kubeconfig-path=$KUBECONFIG_PATH : (Optional) To use with CDP PvC on Open Shift, it is then required (Default) $KUBECONFIG_PATH   "
    echo "  --oc-tar-file-path=$OC_TAR_FILE_PATH Required if using OpenShift, local path to oc.tar file provided by RedHat (Default) $OC_TAR_FILE_PATH "
    echo "  --configure-oc=$CONFIGURE_OC (Optional) Set it to false if your Open Shift is not dedicated to your cluster (Default) $CONFIGURE_OC "
    echo "  --setup-dns-ecs=$SETUP_DNS_ECS (Optional) Set it to false if you already have DNS setup with wildcard for ECS (Default) $SETUP_DNS_ECS "
    echo "  --cluster-name-pvc=$CLUSTER_NAME_PVC Optional as it is derived from cluster-name (Default) ${CLUSTER_NAME}-pvc"
    echo "  --create-cdw=$CREATE_CDW Optional, used to auto setup a CDW if PVC is deployed (Default) $CREATE_CDW"
    echo "  --create-cde=$CREATE_CDE Optional, used to auto setup a CDE if PVC is deployed (Default) $CREATE_CDE"
    echo "  --create-cml=$CREATE_CML Optional, used to auto setup a CML if PVC is deployed (Default) $CREATE_CML"
    echo "  --create-cml-registry=$CREATE_CML_REGISTRY Optional, used to auto setup a CML Registry if PVC is deployed (Default) $CREATE_CML_REGISTRY"
    echo "  --create-viz=$CREATE_VIZ Optional, used to auto setup a Data Viz if PVC is deployed (Default) $CREATE_VIZ"
    echo "  --pvc-eco-resources=$PVC_ECO_RESOURCES : (Optional) To reduce footprint of pvc deployment by making a mini-small cluster (Default) $PVC_ECO_RESOURCES"
    echo "  --ecs-gpu-dedicated-nodes=$ECS_GPU_DEDICATED_NODES : (Optional) To specify an ECS node that will be tainted for only GPU Use (assuming it has GPU) (Default) $ECS_GPU_DEDICATED_NODES"
    echo "  --ecs-ssd-dedicated-nodes=$ECS_SSD_DEDICATED_NODES : (Optional) To specify an ECS node that will be tainted for only SSD Use for CDW (isolating CDW workloads also) (Default) $ECS_SSD_DEDICATED_NODES"
    echo ""
    echo "  --install-repo-url=$INSTALL_REPO_URL : (Optional) Install repo URL (Default) $INSTALL_REPO_URL  "
    echo "  --ansible-repo-dir=$ANSIBLE_REPO_DIR : (Optional) Directory where install repo will be deployed (Default) $ANSIBLE_REPO_DIR "
    echo "  --data-load-repo-url=$DATA_LOAD_REPO_URL : (Optional) Data Load repo URL (Default) $DATA_LOAD_REPO_URL "
    echo "  --datagen-as-a-service=$DATAGEN_AS_A_SERVICE : To deploy DATAGEN as a Service on CDP (Default) $DATAGEN_AS_A_SERVICE "
    echo "  --datagen-repo-url=$DATAGEN_REPO_URL : (Optional) Git URL of DATAGEN repository to use (Default) $DATAGEN_REPO_URL"
    echo "  --datagen-repo-branch=$DATAGEN_REPO_BRANCH : (Optional) Branch of DATAGEN repository to use (Default) $DATAGEN_REPO_BRANCH "
    echo "  --datagen-repo-parcel=$DATAGEN_REPO_PARCEL : (Optional) Parcel Repository of Datagen (should contains parcel, sha and manifest.json) (Default) $DATAGEN_REPO_PARCEL "
    echo "  --datagen-csd-url=$DATAGEN_CSD_URL : (Optional) URL to the CSD of DATAGEN (Default) $DATAGEN_CSD_URL "
    echo "  --datagen-version=$DATAGEN_VERSION : (Optional) Datagen version, used to guess URL of Datagen if not provided (Default) $DATAGEN_VERSION"
    echo "  --demo-repo-url=$DEMO_REPO_URL : (Optional) Demo repo URL (Default) $DEMO_REPO_URL"
    echo "  --demo-repo-branch=$DEMO_REPO_BRANCH : (Optional) Demo repo URL (Default) $DEMO_REPO_BRANCH"
    echo ""
    echo "  --use-csa=$USE_CSA : (Optional) Use of CSA (Default) $USE_CSA "
    echo "  --use-cfm=$USE_CFM : (Optional) Use of CFM (Default) $USE_CFM "
    echo "  --use-spark3=$USE_SPARK3 : (Optional) Use of Spark 3 (Default) $USE_SPARK3 "
    echo "  --use-wxm=$USE_WXM : (Optional) Use of WXM (Default) $USE_WXM "
    echo ""
    echo "  --altus-key-id=$ALTUS_KEY_ID : (Optional) Altus key ID needed for WXM (Default) $ALTUS_KEY_ID "
    echo "  --altus-private-key=$ALTUS_PRIVATE_KEY : (Optional) Path to th Altus Private Key file needed for WXM (Default) $ALTUS_PRIVATE_KEY "
    echo "  --cm-base-url=$CM_BASE_URL : (Optional) CM URL in http://<hostname>:<port> form for associating this cluster to WXM (Default) $CM_BASE_URL "
    echo "  --cm-base-user=$CM_BASE_USER : (Optional) CM user to associate this cluster to WXM (Default) $CM_BASE_USER "
    echo "  --cm-base-password=$CM_BASE_PASSWORD : (Optional)  CM password to associate this cluster to WXM (Default) $CM_BASE_PASSWORD "
    echo "  --tp-host=$TP_HOST : (Optional)  On base cluster, where to install Telemetry (Default) $TP_HOST "
    echo ""
    echo "  --cdh6-kts-path=$CDH6_KTS_PATH : (Optional) Path to KTS tar gz for CDH6 (Default) $CDH6_KTS_PATH "
    echo "  --cdh6-kts-kms-path=$CDH6_KTS_KMS_PATH : (Optional) Path to KTS-KMS tar gz for CDH6 (Default) $CDH6_KTS_KMS_PATH "
    echo ""
    echo "  --edge-host=$EDGE_HOST : (Optional) Node where user creation and data loading will be launched (Default) $EDGE_HOST "
    echo ""
}


while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --cluster-name)
            CLUSTER_NAME=$VALUE
            ;;  
        --paywall-username)
            PAYWALL_USER=$VALUE
            ;;
        --paywall-password)
            PAYWALL_PASSWORD=$VALUE
            ;;
        --license-file)
            LICENSE_FILE=$VALUE
            ;;
        --node-user)
            NODE_USER=$VALUE
            ;;
        --node-key)
            NODE_KEY=$VALUE
            ;;
        --setup-hosts-keys)
            SETUP_HOSTS_KEYS=$VALUE
            ;;
        --setup-etc-hosts)
            SETUP_ETC_HOSTS=$VALUE
            ;;
        --node-password)
            NODE_PASSWORD=$VALUE
            ;;  
        --nodes-base)
            NODES_BASE=$VALUE
            ;;  
        --node-ipa)
            NODE_IPA=$VALUE
            ;;
        --nodes-kts)
            NODES_KTS=$VALUE
            ;;
         --cluster-type)
            CLUSTER_TYPE=$VALUE
            ;;
        --pre-install)
            PRE_INSTALL=$VALUE
            ;;
        --install)
            INSTALL=$VALUE
            ;; 
        --post-install)
            POST_INSTALL=$VALUE
            ;;  
        --user-creation)
            USER_CREATION=$VALUE
            ;;
        --data-load)
            DATA_LOAD=$VALUE
            ;;
        --demo)
            DEMO=$VALUE
            ;;    
        --prepare-ansible-deployment)
            PREPARE_ANSIBLE_DEPLOYMENT=$VALUE
            ;;
        --install-pvc)
            INSTALL_PVC=$VALUE
            ;;
        --configure-pvc)
            CONFIGURE_PVC=$VALUE
            ;;
        --skip-pvc-prereqs)
            SKIP_PVC_PREREQS=$VALUE
            ;;
        --debug)
            DEBUG=$VALUE
            ;;
        --log-dir)
            LOG_DIR=$VALUE
            ;; 
        --default-password)
            DEFAULT_PASSWORD=$VALUE
            ;;  
        --default-admin-user)
            DEFAULT_ADMIN_USER=$VALUE
            ;; 
        --ansible-host-file)
            ANSIBLE_HOST_FILE=$VALUE
            ;;
        --ansible-all-file)
            ANSIBLE_ALL_FILE=$VALUE
            ;;
        --ansible-cluster-file)
            ANSIBLE_CLUSTER_YML_FILE=$VALUE
            ;;
        --ansible-extravars-file)
            ANSIBLE_EXTRA_VARS_YML_FILE=$VALUE
            ;;
        --distribution-to-deploy)
            DISTRIBUTION_TO_DEPLOY=$VALUE
            ;;
        --cm-color)
            CM_COLOR=$VALUE
            ;;  
        --cm-license-type)
            CM_LICENSE_TYPE=$VALUE
            ;;  
        --cm-version)
            CM_VERSION=$VALUE
            ;;
        --cdh-version)
            CDH_VERSION=$VALUE
            ;;
        --csa-version)
            CSA_VERSION=$VALUE
            ;;
        --cfm-version)
            CFM_VERSION=$VALUE
            ;;
        --ambari-version)
            AMBARI_VERSION=$VALUE
            ;; 
        --hdp-version)
            HDP_VERSION=$VALUE
            ;;  
        --hdf-version)
            HDF_VERSION=$VALUE
            ;;
        --spark3-version)
            SPARK3_VERSION=$VALUE
            ;;
        --wxm-version)
            WXM_VERSION=$VALUE
            ;;
        --pvc-version)
            PVC_VERSION=$VALUE
            ;;
        --cm-repo)
            CM_REPO=$VALUE
            ;;
        --cdh-repo)
            CDH_REPO=$VALUE
            ;;
        --csa-repo)
            CSA_BASE_REPO=$VALUE
            ;;
        --cfm-repo)
            CFM_BASE_REPO=$VALUE
            ;;
        --ambari-repo)
            AMBARI_REPO=$VALUE
            ;;
        --hdp-repo)
            HDP_REPO=$VALUE
            ;;
        --hdf-repo)
            HDF_REPO=$VALUE
            ;;
        --spark3-repo)
            SPARK3_BASE_REPO=$VALUE
            ;;
        --wxm-repo)
            WXM_BASE_REPO=$VALUE
            ;;
        --pvc-repo)
            PVC_REPO=$VALUE
            ;;
        --database-type)
            DATABASE_TYPE=$VALUE
            ;;
        --database-version)
            DATABASE_VERSION=$VALUE
            ;;
        --kerberos)
            KERBEROS=$VALUE
            ;;
        --realm)
            REALM=$VALUE
            ;;
        --tls)
            TLS=$VALUE
            ;;
        --free-ipa)
            FREE_IPA=$VALUE
            ;;
        --encryption-activated)
            ENCRYPTION_ACTIVATED=$VALUE
            ;;
        --root-ca-cert)
            ROOT_CA_CERT=$VALUE
            ;;
        --root-ca-key)
            ROOT_CA_KEY=$VALUE
            ;;
        --os)
            OS=$VALUE
            ;;
        --os-version)
            OS_VERSION=$VALUE
            ;;
        --install-python3)
            INSTALL_PYTHON3=$VALUE
            ;;
        --use-ansible-python-3)
            USE_ANSIBLE_PYTHON_3=$VALUE
            ;;
        --pvc)
            PVC=$VALUE
            ;;
        --pvc-type)
            PVC_TYPE=$VALUE
            ;;
        --nodes-ecs)
            NODES_PVC_ECS=$VALUE
            ;;
        --kubeconfig-path)
            KUBECONFIG_PATH=$VALUE
            ;;
        --oc-tar-file-path)
            OC_TAR_FILE_PATH=$VALUE
            ;;
        --configure-oc)
            CONFIGURE_OC=$VALUE
            ;;
        --setup-dns-ecs)
            SETUP_DNS_ECS=$VALUE
            ;;
        --cluster-name-pvc)
            CLUSTER_NAME_PVC=$VALUE
            ;;
        --create-cdw)
            CREATE_CDW=$VALUE
            ;;  
        --create-cde)
            CREATE_CDE=$VALUE
            ;;
        --create-cml)
            CREATE_CML=$VALUE
            ;;
        --create-cml-registry)
            CREATE_CML_REGISTRY=$VALUE
            ;;
        --create-viz)
            CREATE_VIZ=$VALUE
            ;;
        --pvc-eco-resources)
            PVC_ECO_RESOURCES=$VALUE
            ;;  
        --ecs-gpu-dedicated-nodes)
            ECS_GPU_DEDICATED_NODES=$VALUE
            ;;
        --ecs-ssd-dedicated-nodes)
            ECS_SSD_DEDICATED_NODES=$VALUE
            ;;
        --setup-pvc-tools)
            SETUP_PVC_TOOLS=$VALUE
            ;;  
        --pvc-app-domain)
            PVC_APP_DOMAIN=$VALUE
            ;;
        --install-repo-url)
            INSTALL_REPO_URL=$VALUE
            ;;
        --ansible-repo-dir)
            ANSIBLE_REPO_DIR=$VALUE
            ;;
        --data-load-repo-url)
            DATA_LOAD_REPO_URL=$VALUE
            ;;
        --datagen-as-a-service)
            DATAGEN_AS_A_SERVICE=$VALUE
            ;;
        --datagen-repo-url)
            DATAGEN_REPO_URL=$VALUE
            ;;
        --datagen-repo-branch)
            DATAGEN_REPO_BRANCH=$VALUE
            ;;  
        --datagen-repo-parcel)
            DATAGEN_REPO_PARCEL=$VALUE
            ;;  
        --datagen-csd-url)
            DATAGEN_CSD_URL=$VALUE
            ;;
        --datagen-version)
            DATAGEN_VERSION=$VALUE
            ;;        
        --demo-repo-url)
            DEMO_REPO_URL=$VALUE
            ;;
        --demo-repo-branch)
            DEMO_REPO_BRANCH=$VALUE
            ;;    
        --use-csa)
            USE_CSA=$VALUE
            ;;
        --use-cfm)
            USE_CFM=$VALUE
            ;;
        --use-spark3)
            USE_SPARK3=$VALUE
            ;;    
        --use-wxm)
            USE_WXM=$VALUE
            ;;
        --altus-key-id)
            ALTUS_KEY_ID=$VALUE
            ;;
        --altus-private-key)
            ALTUS_PRIVATE_KEY=$VALUE
            ;;
        --cm-base-url)
            CM_BASE_URL=$VALUE
            ;;
        --cm-base-user)
            CM_BASE_USER=$VALUE
            ;; 
        --cm-base-url)
            CM_BASE_PASSWORD=$VALUE
            ;;
        --tp-host)
            TP_HOST=$VALUE
            ;;
        --cdh6-kts-path)
            CDH6_KTS_PATH=$VALUE
            ;;
        --cdh6-kts-kms-path)
            CDH6_KTS_KMS_PATH=$VALUE
            ;;
        --edge-host)
            EDGE_HOST=$VALUE                      
            ;;
        *)
            ;;
    esac
    shift
done

#############################################################################################
##### Check on important variables before starting
#############################################################################################

if [ -z ${CLUSTER_NAME_PVC} ]
then
    export CLUSTER_NAME_PVC="${CLUSTER_NAME}-pvc"
fi

if [ -z ${CM_REPO} ] || [ -z ${CDH_REPO} ]
then
if [ -z ${HDP_REPO} ] || [ -z ${HDF_REPO} ]
then
    if [ -z ${PAYWALL_USER} ] || [ -z ${PAYWALL_PASSWORD} ]
    then
        echo " Since february 2021, you must have a username/password to download binaries, please provide --paywall-username and --paywall-password"
        echo " '${PAYWALL_USER}'/'${PAYWALL_PASSWORD}' are not valid credentials"  
        if [ ${DISTRIBUTION_TO_DEPLOY} == 'CDP' ]
        then
            echo " Will use default out of the paywall available builds for CDP, made only for test purposes"
            export USE_OUTSIDE_PAYWALL_BUILDS="true"
        else
            exit 1
        fi
    fi
fi
fi

if [ "${DISTRIBUTION_TO_DEPLOY}" = "CDP" ] && [ "${CM_COLOR}" = "RANDOM" ]
then
    RANDOM=$$$(date +%s)
    colors=("PURPLE" "RED" "YELLOW" "GREEN" "TEAL" "PINK" "BLACK" "GRAY" "BROWN" "BLUE" "DARKBLUE")
    export CUSTOM_HEADER_COLOR="${colors[ $RANDOM % ${#colors[@]} ]}"
    echo " Will use color for CM : ${CUSTOM_HEADER_COLOR}"
else
    export CUSTOM_HEADER_COLOR=${CM_COLOR}
fi

if [ ! -z ${ROOT_CA_CERT} ] && [ ! -z ${ROOT_CA_KEY} ]
then
    echo " Will use root CA file cert (and key) located locally at ${ROOT_CA_CERT}"
    export USE_ROOT_CA="true"
fi

# TODO: add check on pvc if no nodes are set or no kubeconfig file
# TODO: add checks


# To ensure log dirs exists 
mkdir -p ${LOG_DIR}/

#############################################################################################
# Setup of deployment type
# SIMPLIFY ALL deployment by using ONE Parameter to know what to deploy
#############################################################################################
if [ ! -z ${CLUSTER_TYPE} ]
then
    if [ "${CLUSTER_TYPE}" = "basic" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-basic/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-basic/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-basic/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-basic/extra_vars.yml"
    elif [ "${CLUSTER_TYPE}" = "basic-enc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-basic-enc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-basic-enc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-basic-enc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-basic-enc/extra_vars.yml"
        export ENCRYPTION_ACTIVATED="true"
    elif [ "${CLUSTER_TYPE}" = "full" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp/extra_vars.yml"
    elif [ "${CLUSTER_TYPE}" = "streaming" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-streaming/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-streaming/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-streaming/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-streaming/extra_vars.yml"
        export USE_SPARK3="true"
        export USE_CSA="true"
        export USE_CFM="true"
        export CLUSTER_NAME_STREAMING="${CLUSTER_NAME}-stream"
    elif [ "${CLUSTER_TYPE}" = "all-services" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-all-services/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-all-services/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-all-services/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-all-services/extra_vars.yml"
        export USE_CSA="true"
        export USE_CFM="true"
        export USE_SPARK3="true"
        export ENCRYPTION_ACTIVATED="true"  
    elif [ "${CLUSTER_TYPE}" = "all-services-pvc-oc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-all-services-pvc-oc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-all-services-pvc-oc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-all-services-pvc-oc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-all-services-pvc-oc/extra_vars.yml"
        export USE_CSA="true"
        export USE_CFM="true"
        export USE_SPARK3="true"
        export PVC="true"
        export FREE_IPA="true"
        export PVC_TYPE="OC"
        export ENCRYPTION_ACTIVATED="true"  
    elif [ "${CLUSTER_TYPE}" = "all-services-pvc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-all-services-pvc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-all-services-pvc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-all-services-pvc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-all-services-pvc/extra_vars.yml"
        export USE_CSA="true"
        export USE_CFM="true"
        export USE_SPARK3="true"
        export PVC="true"
        export FREE_IPA="true"
        export PVC_TYPE="ECS"
        export ENCRYPTION_ACTIVATED="true"
    elif [ "${CLUSTER_TYPE}" = "pvc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-pvc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-pvc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-pvc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-pvc/extra_vars.yml"
        export PVC="true"
        export FREE_IPA="true"
    elif [ "${CLUSTER_TYPE}" = "pvc-oc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-pvc-oc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-pvc-oc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-pvc-oc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-pvc-oc/extra_vars.yml"
        export PVC="true"
        export PVC_TYPE="OC"
        export FREE_IPA="true"
    elif [ "${CLUSTER_TYPE}" = "wxm" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-wxm/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-wxm/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-wxm/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-wxm/extra_vars.yml"
        export USE_WXM="true"
        export USER_CREATION="false"
        export DATA_LOAD="false"
        export FREE_IPA="false"
        export CM_VERSION="7.7.1"
        export CDH_VERSION="7.1.8.0"
    elif [ "${CLUSTER_TYPE}" = "cdp-717" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-717/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-717/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-717/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-717/extra_vars.yml"
        export CM_VERSION="7.6.7"
        export CDH_VERSION="7.1.7.2026"
        export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/tags/CDP-7.1.7.zip"
        export ANSIBLE_REPO_DIR="cldr-playbook-CDP-7.1.7"
        export DATAGEN_REPO_PARCEL="https://datagen-repo.s3.eu-west-3.amazonaws.com/${DATAGEN_VERSION}/7.1.7.2000/parcels/"
        export DATAGEN_CSD_URL="https://datagen-repo.s3.eu-west-3.amazonaws.com/${DATAGEN_VERSION}/7.1.7.2000/csd/DATAGEN-${DATAGEN_VERSION}.7.1.7.2000.jar"
    elif [ "${CLUSTER_TYPE}" = "cdh6" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdh-6/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdh-6/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdh-6/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdh-6/extra_vars.yml"
        export DISTRIBUTION_TO_DEPLOY="CDH"
        export CM_VERSION="6.3.4"
        export CDH_VERSION="6.3.4"
        export TLS="false"
        export DATA_LOAD="false"
        export DATABASE_VERSION="12"
        export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/tags/CDP-7.1.7.zip"
        export ANSIBLE_REPO_DIR="cldr-playbook-CDP-7.1.7"
    elif [ "${CLUSTER_TYPE}" = "cdh6-enc-stream" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdh6-enc-stream/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdh6-enc-stream/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdh6-enc-stream/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdh6-enc-stream/extra_vars.yml"
        export DISTRIBUTION_TO_DEPLOY="CDH"
        export CM_VERSION="6.3.4"
        export CDH_VERSION="6.3.4"
        export TLS="true"
        export ENCRYPTION_ACTIVATED="true"
        export DATA_LOAD="false"
        export DATABASE_VERSION="12"
        export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/tags/CDP-7.1.7.zip"
        export ANSIBLE_REPO_DIR="cldr-playbook-CDP-7.1.7"
    elif [ "${CLUSTER_TYPE}" = "cdh5" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdh-5/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdh-5/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdh-5/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdh-5/extra_vars.yml"
        export DISTRIBUTION_TO_DEPLOY="CDH"
        export CM_VERSION="5.16.2"
        export CDH_VERSION="5.16"
        export TLS="false"
        export DATA_LOAD="false"
        export POST_INSTALL="false"
        export USER_CREATION="false"
        export DATABASE_VERSION="12"
        export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/tags/CDP-7.1.7.zip"
        export ANSIBLE_REPO_DIR="cldr-playbook-CDP-7.1.7"
    elif [ "${CLUSTER_TYPE}" = "hdp2" ]
    then
        export ANSIBLE_HOST_FILE="ansible-hdp-2/hosts"
        export ANSIBLE_ALL_FILE="ansible-hdp-2/all"
        export DISTRIBUTION_TO_DEPLOY="HDP"
        export AMBARI_VERSION="2.6.2.2"
        export HDP_VERSION="2.6.5.0"
        export HDF_VERSION="3.1.2.0"
        export INSTALL_REPO_URL="https://github.com/frischHWC/ansible-hortonworks/archive/refs/heads/master.zip"
        export ANSIBLE_REPO_DIR="ansible-hortonworks-master"
        export DATA_LOAD="false"
        export POST_INSTALL="false"
        export USER_CREATION="false"
        export DATABASE_TYPE="mysql"
    elif [ "${CLUSTER_TYPE}" = "hdp3" ]
    then
        export ANSIBLE_HOST_FILE="ansible-hdp-3/hosts"
        export ANSIBLE_ALL_FILE="ansible-hdp-3/all"
        export DISTRIBUTION_TO_DEPLOY="HDP"
        export INSTALL_REPO_URL="https://github.com/frischHWC/ansible-hortonworks/archive/refs/heads/master.zip"
        export ANSIBLE_REPO_DIR="ansible-hortonworks-master"
        export DATA_LOAD="false"
        export POST_INSTALL="false"
        export USER_CREATION="false"
        export DATABASE_TYPE="mysql"
    else
        export ANSIBLE_HOST_FILE="${CLUSTER_TYPE}/hosts"
        export ANSIBLE_ALL_FILE="${CLUSTER_TYPE}/all"
        export ANSIBLE_CLUSTER_YML_FILE="${CLUSTER_TYPE}/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="${CLUSTER_TYPE}/extra_vars.yml"
    fi

fi

###############################
# Setup of Repositories
###############################

# Cloudera repository required variables
if [ "${OS}" = "centos" ] || [ "${OS}" = "rhel" ]
then
    export OS_BY_CLDR="redhat"
else
    export OS_BY_CLDR=${OS}
fi

if [ "${OS}" = "ubuntu" ]
then
    export OS_INSTALLER_BY_CLDR="apt"
else
    export OS_INSTALLER_BY_CLDR="yum"
fi

if [ -z "${INSTALL_REPO_URL}" ]
then
    export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/heads/main.zip"
fi

if [ -z "${CDH_REPO}" ]
then
    if [ "${CDH_VERSION:0:1}" = "5" ]
    then
        export CDH_REPO="https://archive.cloudera.com/p/cdh${CDH_VERSION:0:1}/parcels/${CDH_VERSION}/"
    else    
        export CDH_REPO="https://archive.cloudera.com/p/cdh${CDH_VERSION:0:1}/${CDH_VERSION}/parcels/"
    fi
fi

if [ -z "${CM_REPO}" ]
then
    if [ "${CDH_VERSION:0:1}" = "5" ]
    then
        export CM_REPO="https://archive.cloudera.com/p/cm5/${OS_BY_CLDR}/${OS_VERSION:0:1}/x86_64/cm/5.16.2.4505"
    else    
        export CM_REPO="https://archive.cloudera.com/p/cm${CM_VERSION:0:1}/${CM_VERSION}/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}"
        
        # Starting from CM 7.11.3.3, patch are behind a /patch URL
        if [ "${CM_VERSION}" = "7.11.3.3" ]
        then 
            export CM_REPO="https://archive.cloudera.com/p/cm${CM_VERSION:0:1}/patch/${CM_VERSION}-47960007/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}"
        fi
    fi
fi

if [ "${USE_OUTSIDE_PAYWALL_BUILDS}" = "true" ]
then
    export CM_REPO="https://archive.cloudera.com/cm7/7.4.4/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}"
    export CDH_REPO="https://archive.cloudera.com/cdh7/7.1.7.0/parcels/"
    export CM_VERSION="7.4.4"
    export CDH_VERSION="7.1.7.0"
    export CM_LICENSE_TYPE="trial"
fi

if [ -z "${PVC_REPO}" ]
then
    if [ $PVC_VERSION = '1.4.0' ]
    then
        export PVC_REPO="https://archive.cloudera.com/p/cdp-pvc-ds/1.4.0-h1"
    else 
        export PVC_REPO="https://archive.cloudera.com/p/cdp-pvc-ds/${PVC_VERSION}"
    fi
fi


# Setup of External CSD URLs

if [ "${USE_SPARK3}" = "true" ] 
then
    if [ -z "${SPARK3_BASE_REPO}" ]   
    then
        export SPARK3_REPO="https://archive.cloudera.com/p/spark3/${SPARK3_VERSION}/parcels/"
        export SPARK3_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/spark3/${SPARK3_VERSION}/csd/ | grep .jar | grep YARN | cut -d '>' -f 3 | cut -d '<' -f 1)
        export SPARK3_LIVY_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/spark3/${SPARK3_VERSION}/csd/ | grep .jar | grep LIVY | cut -d '>' -f 3 | cut -d '<' -f 1)
        export SPARK3_CSD="https://archive.cloudera.com/p/spark3/${SPARK3_VERSION}/csd/${SPARK3_CSD_JAR}"
        export SPARK3_LIVY_CSD="https://archive.cloudera.com/p/spark3/${SPARK3_VERSION}/csd/${SPARK3_LIVY_CSD_JAR}"
    else 
        export SPARK3_REPO="${SPARK3_BASE_REPO}/parcels/"
        export SPARK3_CSD_JAR=$(curl -s -X GET ${SPARK3_BASE_REPO}/csd/ | grep .jar | grep YARN | cut -d '>' -f 3 | cut -d '<' -f 1)
        export SPARK3_LIVY_CSD_JAR=$(curl -s -X GET ${SPARK3_BASE_REPO}/csd/ | grep .jar | grep LIVY | cut -d '>' -f 3 | cut -d '<' -f 1)
        export SPARK3_CSD="${SPARK3_BASE_REPO}/csd/${SPARK3_CSD_JAR}"
        export SPARK3_LIVY_CSD="${SPARK3_BASE_REPO}/csd/${SPARK3_LIVY_CSD_JAR}"
    fi
fi

if [ "${USE_CSA}" = "true" ]
then
    if [ -z "${CSA_BASE_REPO}" ] 
    then
        export CSA_REPO="https://archive.cloudera.com/p/csa/${CSA_VERSION}/parcels/"
        export CSA_FLINK_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/csa/${CSA_VERSION}/csd/ | grep .jar | grep FLINK | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CSA_SSB_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/csa/${CSA_VERSION}/csd/ | grep .jar | grep SQL | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CSA_FLINK_CSD="https://archive.cloudera.com/p/csa/${CSA_VERSION}/csd/${CSA_FLINK_CSD_JAR}"
        export CSA_SSB_CSD="https://archive.cloudera.com/p/csa/${CSA_VERSION}/csd/${CSA_SSB_CSD_JAR}"
    else
        export CSA_REPO="${CSA_BASE_REPO}parcels"
        export CSA_FLINK_CSD_JAR=$(curl -s -X GET ${CSA_BASE_REPO}csd/ | grep .jar | grep FLINK | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CSA_SSB_CSD_JAR=$(curl -s -X GET ${CSA_BASE_REPO}csd/ | grep .jar | grep SQL | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CSA_FLINK_CSD="${CSA_BASE_REPO}csd/${CSA_FLINK_CSD_JAR}"
        export CSA_SSB_CSD="${CSA_BASE_REPO}csd/${CSA_SSB_CSD_JAR}"
    fi
fi

if [ "${USE_CFM}" = "true" ]
then
    if [ -z "${CFM_BASE_REPO}" ] 
    then
        export CFM_REPO="https://archive.cloudera.com/p/cfm2/${CFM_VERSION}/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/"
        export CFM_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/cfm2/${CFM_VERSION}/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/ | grep .jar | grep NIFI- | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_REGISTRY_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/cfm2/${CFM_VERSION}/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/ | grep .jar | grep NIFIREGISTRY | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_CSD="https://archive.cloudera.com/p/cfm2/${CFM_VERSION}/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/${CFM_CSD_JAR}"
        export CFM_REGISTRY_CSD="https://archive.cloudera.com/p/cfm2/${CFM_VERSION}/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/${CFM_REGISTRY_CSD_JAR}"
    else
        export CFM_REPO="${CFM_BASE_REPO}/tars/parcel/"
        export CFM_CSD_JAR=$(curl -s -X GET ${CFM_BASE_REPO}/tars/parcel/ | grep .jar | grep NIFI- | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_REGISTRY_CSD_JAR=$(curl -s -X GET ${CFM_BASE_REPO}/tars/parcel/ | grep .jar | grep NIFIREGISTRY | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_CSD="${CFM_BASE_REPO}/tars/parcel/${CFM_CSD_JAR}"
        export CFM_REGISTRY_CSD="${CFM_BASE_REPO}/tars/parcel/${CFM_REGISTRY_CSD_JAR}"
    fi
fi

if [ "${USE_WXM}" = "true" ]
then
    if [ -z "${WXM_BASE_REPO}" ] 
    then
        export WXM_REPO="https://archive.cloudera.com/p/wxm/${WXM_VERSION}/parcels/"
        export WXM_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/wxm/${WXM_VERSION}/csd/ | grep .jar | grep WXM | cut -d '>' -f 3 | cut -d '<' -f 1)
        export WXM_CSD="https://archive.cloudera.com/p/wxm/${WXM_VERSION}/csd/${WXM_CSD_JAR}"
    else
        export WXM_REPO="${CFM_BASE_REPO}/parcels/"
        export WXM_CSD_JAR=$(curl -s -X GET ${WXM_REPO}/csd/ | grep .jar | grep NIFI- | cut -d '>' -f 3 | cut -d '<' -f 1)
        export WXM_CSD="${WXM_REPO}/csd/${WXM_CSD_JAR}"
    fi
fi

if [ "${DISTRIBUTION_TO_DEPLOY}" = "CDP" ] && [ -z ${DATAGEN_CSD_URL} ] && [ -z ${DATAGEN_REPO_PARCEL} ]
then
    echo " Will guess Datagen Parcel Repo and CSD from Version"
    export DATAGEN_REPO_PARCEL="https://datagen-repo.s3.eu-west-3.amazonaws.com/${DATAGEN_VERSION}/${CDH_VERSION}/parcels/"
    export DATAGEN_CSD_URL="https://datagen-repo.s3.eu-west-3.amazonaws.com/${DATAGEN_VERSION}/${CDH_VERSION}/csd/DATAGEN-${DATAGEN_VERSION}.${CDH_VERSION}.jar"
fi

# Set HDP/Ambari repository 

if [ -z "${HDP_REPO}" ] 
then
    export HDP_REPO="https://${PAYWALL_USER}:${PAYWALL_PASSWORD}@archive.cloudera.com/p"
    if [ "${HDP_VERSION:0:1}" = "3" ]
    then
        export GPL_REPO="${HDP_REPO}/HDP-GPL/${OS}${OS_VERSION:0:1}/3.x/updates/${HDP_VERSION}/"
        export HDP_MAIN_REPO="${HDP_REPO}/HDP/${OS}${OS_VERSION:0:1}/3.x/updates/${HDP_VERSION}/"
    else 
        export GPL_REPO="${HDP_REPO}/HDP-GPL/${HDP_VERSION:0:1}.x/${HDP_VERSION}/${OS}${OS_VERSION:0:1}/"
        export HDP_MAIN_REPO="${HDP_REPO}/HDP/${HDP_VERSION:0:1}.x/${HDP_VERSION}/${OS}${OS_VERSION:0:1}/"
    fi 
fi
if [ -z "${AMBARI_REPO}" ] 
then
    if [ "${AMBARI_VERSION}" = "2.7.5.0" ]
    then
        export AMBARI_REPO="${HDP_REPO}/ambari/${OS}${OS_VERSION:0:1}/2.x/updates/2.7.5.0/"
    else 
        export AMBARI_REPO="${HDP_REPO}/ambari/2.x/${AMBARI_VERSION}/${OS}${OS_VERSION:0:1}/"
    fi 
fi

# Old RD repo if not using as a service
if [ "${DATAGEN_AS_A_SERVICE}" = "false" ] && [ -z "${DATAGEN_REPO_URL}" ]
then
    export DATAGEN_REPO_URL="https://github.com/frischHWC/random-datagen"
fi    

###############################
# Setup of files to interact with the cluster
###############################

export NODES_SORTED=$( echo ${NODES_BASE} | uniq )
export NODES=( ${NODES_SORTED} )
export HOSTS_FILE=$(mktemp)
export HOSTS_ETC=$(mktemp)
export KNOWN_HOSTS=$(mktemp)
export AUTHORIZED_KEYS=$(mktemp)
export TO_DEPLOY_FOLDER=$(mktemp -d)

# Create directory to gather all cluster files in one
mkdir -p ~/cluster-${CLUSTER_NAME}/

echo "############ Setup connections to all nodes  ############"
touch ~/.ssh/known_hosts
touch ~/.ssh/authorized_keys

echo "[base]" >> ${HOSTS_FILE} 
for i in ${!NODES[@]}
do
    export "NODE_$i"=${NODES[$i]}
    echo "${NODES[$i]}" >> ${HOSTS_FILE}
    
    if [ "${PRE_INSTALL}" = "true" ] 
    then
        SSHKey=`ssh-keyscan ${NODES[$i]} 2> /dev/null`
        echo $SSHKey >> ~/.ssh/known_hosts
        echo $SSHKey >> ${KNOWN_HOSTS}
        IP_ADRESS_SOLVED=$(cat /etc/hosts | grep ${NODES[$i]} | head -n1 | cut -d' ' -f1)
        if [ -z "${IP_ADRESS_SOLVED}" ]
        then
            IP_ADRESS_SOLVED=$( dig +short ${NODES[$i]} )
        fi
        echo "${IP_ADRESS_SOLVED} ${NODES[$i]}" >> ${HOSTS_ETC}
        echo "**** Connection setup to ${NODES[$i]} ****"
    fi
done
echo "" >> ${HOSTS_FILE}

if [ ! -z "${NODE_IPA}" ]
then
    echo "[ipa]" >> ${HOSTS_FILE} 
    echo "${NODE_IPA}" >> ${HOSTS_FILE}
    echo "" >> ${HOSTS_FILE}
    if [ "${PRE_INSTALL}" = "true" ] 
    then
        SSHKey=`ssh-keyscan ${NODE_IPA} 2> /dev/null`
        echo $SSHKey >> ~/.ssh/known_hosts
        echo $SSHKey >> ${KNOWN_HOSTS}
        IP_ADRESS_SOLVED=$(cat /etc/hosts | grep ${NODE_IPA} | head -n1 | cut -d' ' -f1)
        if [ -z ${IP_ADRESS_SOLVED} ]
        then
            IP_ADRESS_SOLVED=$( dig +short ${NODE_IPA} )
        fi
        echo "${IP_ADRESS_SOLVED} ${NODE_IPA}" >> ${HOSTS_ETC}
        echo "**** Connection setup to ${NODE_IPA} ****"
    fi
fi

if [ ! -z "${NODES_KTS}" ]
then
    export NODES_KTS_ARRAY=$( echo ${NODES_KTS} | sort | uniq )
    export NODES_KTS_SORTED=( ${NODES_KTS_ARRAY} )
    export KTS_ACTIVE=${NODES_KTS_SORTED[0]}
    if [ ${#NODES_KTS_SORTED[@]} == 2 ]
    then
        export KTS_PASSIVE=${NODES_KTS_SORTED[1]}
    fi
    echo "[kts]" >> ${HOSTS_FILE}
    for i in ${!NODES_KTS_SORTED[@]}
    do
        echo "${NODES_KTS_SORTED[$i]}" >> ${HOSTS_FILE}
        
        if [ "${PRE_INSTALL}" = "true" ] 
        then
            SSHKey=`ssh-keyscan ${NODES_KTS_SORTED[$i]} 2> /dev/null`
            echo $SSHKey >> ~/.ssh/known_hosts
            echo $SSHKey >> ${KNOWN_HOSTS}
            IP_ADRESS_SOLVED=$(cat /etc/hosts | grep ${NODES_KTS_SORTED[$i]} | head -n1 | cut -d' ' -f1)
            if [ -z ${IP_ADRESS_SOLVED} ]
            then
                IP_ADRESS_SOLVED=$( dig +short ${NODES_KTS_SORTED[$i]} )
            fi
            echo "${IP_ADRESS_SOLVED} ${NODES_KTS_SORTED[$i]}" >> ${HOSTS_ETC}
            echo "**** Connection setup to ${NODES_KTS_SORTED[$i]} ****"
        fi
    done
    echo "" >> ${HOSTS_FILE}
fi

if [ ! -z "${NODES_PVC_ECS}" ]
then
    export NODES_PVC_ECS_SORTED_ARRAY=$( echo ${NODES_PVC_ECS} | uniq )
    export NODES_PVC_ECS_SORTED=( ${NODES_PVC_ECS_SORTED_ARRAY} )
    echo "[pvc]" >> ${HOSTS_FILE}
    for i in ${!NODES_PVC_ECS_SORTED[@]}
    do
        echo "${NODES_PVC_ECS_SORTED[$i]}" >> ${HOSTS_FILE}
        if [ "${PRE_INSTALL}" = "true" ] 
        then
            SSHKey=`ssh-keyscan ${NODES_PVC_ECS_SORTED[$i]} 2> /dev/null`
            echo $SSHKey >> ~/.ssh/known_hosts
            echo $SSHKey >> ${KNOWN_HOSTS}
            IP_ADRESS_SOLVED=$(cat /etc/hosts | grep ${NODES_PVC_ECS_SORTED[$i]} | head -n1 | cut -d' ' -f1)
            if [ -z ${IP_ADRESS_SOLVED} ]
            then
                IP_ADRESS_SOLVED=$( dig +short ${NODES_PVC_ECS_SORTED[$i]} )
            fi
            echo "${IP_ADRESS_SOLVED} ${NODES_PVC_ECS_SORTED[$i]}" >> ${HOSTS_ETC}
            echo "**** Connection setup to ${NODES_PVC_ECS_SORTED[$i]} ****"
        fi
    done
    echo "" >> ${HOSTS_FILE}

    new_line=$'\n'
    export NODES_ECS_PRINTABLE="$(echo ${NODES_PVC_ECS} | sed 's/ /'"\\${new_line}"'/g')"
    export PVC_ECS_SERVER_HOST="${NODES_PVC_ECS_SORTED[0]}"

    if [ -z "${PVC_APP_DOMAIN}" ]
    then
        export PVC_APP_DOMAIN=${PVC_ECS_SERVER_HOST}
    fi
fi

# To adjust the number of lines to analyze from ansible response
NUMBER_OF_NODES=$(wc ${HOSTS_FILE} | awk '{print $1}')
ANSIBLE_LINES_NUMBER=$(expr 3 + ${NUMBER_OF_NODES})

echo "############ Setup of files to interact with cluster  ############"

# Prepare hosts file to interact with cluster 
if [ -z ${TP_HOST} ]
then
    export TP_HOST=${NODE_0}
fi
echo "
[tp_host]
$TP_HOST
" >> ${HOSTS_FILE}

if [ -z ${EDGE_HOST} ]
then
    export EDGE_HOST=${NODE_0}
fi

echo "
[edge]
${EDGE_HOST}
" >> ${HOSTS_FILE}

echo "
[cloudera_manager]
${NODE_0}
" >> ${HOSTS_FILE}

echo "
[main]
${NODE_0}
" >> ${HOSTS_FILE}

echo "
[cluster:children]
base" >> ${HOSTS_FILE}

if [ ! -z "${NODES_KTS}" ]
then 
    echo "kts" >> ${HOSTS_FILE}
fi

echo "
[all:vars]
ansible_connection=ssh
ansible_user=${NODE_USER}" >> ${HOSTS_FILE}

if [ ! -z ${NODE_KEY} ]
then 
    echo "ansible_ssh_private_key_file=${NODE_KEY}" >> ${HOSTS_FILE}
elif [ ! -z ${NODE_PASSWORD} ]
then
    echo "ansible_ssh_pass=${NODE_PASSWORD}" >> ${HOSTS_FILE}
fi

echo "host_pattern_mismatch=ignore
" >> ${HOSTS_FILE}

cp ${HOSTS_FILE} ~/cluster-${CLUSTER_NAME}/hosts

###############################
# Preparation of files for ansible installation
###############################

if [ "${DISTRIBUTION_TO_DEPLOY}" == "CDH" ] && [ "${ENCRYPTION_ACTIVATED}" = "true" ]
then
    kts_paths=$(echo $CDH6_KTS_PATH | tr "/" "\n")
    for kts_path in $kts_paths
    do
        export CDH6_KTS_FILE=$kts_path
    done

    kts_kms_paths=$(echo $CDH6_KTS_KMS_PATH | tr "/" "\n")
    for kts_kms_path in $kts_kms_paths
    do
        export CDH6_KTS_KMS_FILE=$kts_kms_path
    done
fi

export DAS_AUTH="NONE"
export HBASE_AUTH="simple"
export KAFKA_PROTOCOL="PLAINTEXT"
export BOOTSTRAP_SERVERS_PORT="9092"
export KAFKA_CONNECT_PROTOCOL="http"
export KAFKA_CONNECT_PORT="28083"
export HDP_KDC_TYPE="none"

if [ "${KERBEROS}" = "true" ]
then
    DAS_AUTH="SPNEGO"
    HBASE_AUTH="kerberos"
    KAFKA_PROTOCOL="SASL_PLAINTEXT"
    HDP_KDC_TYPE="mit-kdc"
    if [ ${TLS} = "true" ]
    then
        BOOTSTRAP_SERVERS_PORT="9093"
        KAFKA_PROTOCOL="SASL_SSL"
        KAFKA_CONNECT_PROTOCOL="https"
        KAFKA_CONNECT_PORT="28085"
    fi
fi

echo "############ Configure Ansible files to deploy ${DISTRIBUTION_TO_DEPLOY} ############"
if [ "${DISTRIBUTION_TO_DEPLOY}" != "HDP" ]
then
    cp ${ANSIBLE_CLUSTER_YML_FILE} ${TO_DEPLOY_FOLDER}/cluster.yml
    cp ${ANSIBLE_EXTRA_VARS_YML_FILE} ${TO_DEPLOY_FOLDER}/extra_vars.yml
    cp ${TO_DEPLOY_FOLDER}/cluster.yml ~/cluster-${CLUSTER_NAME}/deploy-cluster.yml
fi
cp ${ANSIBLE_HOST_FILE} ${TO_DEPLOY_FOLDER}/hosts
cp ${ANSIBLE_ALL_FILE} ${TO_DEPLOY_FOLDER}/all
cp ansible.cfg ${TO_DEPLOY_FOLDER}/ansible.cfg
if [ ! -z ${KUBECONFIG_PATH} ]
then
    cp ${KUBECONFIG_PATH} ${TO_DEPLOY_FOLDER}/kubeconfig
fi

if [ "${KERBEROS}" = "true" ] && [ "${DISTRIBUTION_TO_DEPLOY}" != "HDP"  ]
then
    if [ "${FREE_IPA}" = "true" ]
    then
        export KRB5_SERVERS="
[krb5_server]
${NODE_IPA}"
    else
        export KRB5_SERVERS="
[krb5_server]
${NODE_0}"
    fi
fi

if [ "${ENCRYPTION_ACTIVATED}" = "true" ]
then
    if [ -z "${KTS_PASSIVE}" ]
    then
        export KTS_SERVERS="
[kts_active]
${KTS_ACTIVE}

[kts_servers:children]
kts_active"

        export KMS_SERVERS="
[kms_servers]
${NODE_1}"
    else
        export KTS_SERVERS="
[kts_active]
${KTS_ACTIVE}

[kts_passive]
${KTS_PASSIVE}

[kts_servers:children]
kts_active
kts_passive"
        export KMS_SERVERS="
[kms_servers]
${NODE_1}
${NODE_2}"
    fi

    export KTS_SERVERS_GROUP="kts_servers"
fi

if [ ! -z ${NODE_IPA} ]
then
    export KRB_SERVER_TYPE="Red Hat IPA"
else
    export KRB_SERVER_TYPE="MIT KDC"
fi

if [ "${CLUSTER_NAME_STREAMING}" == "" ]
then
    export CLUSTER_NAME_STREAMING=${CLUSTER_NAME}
fi

export OS_VERSION_LAST_DIGIT=${OS_VERSION:0:1}

if [ "${DISTRIBUTION_TO_DEPLOY}" != "HDP" ]
then
    envsubst < ${TO_DEPLOY_FOLDER}/extra_vars.yml > ${TO_DEPLOY_FOLDER}/extra_vars.yml.tmp && mv ${TO_DEPLOY_FOLDER}/extra_vars.yml.tmp ${TO_DEPLOY_FOLDER}/extra_vars.yml
    cp ${TO_DEPLOY_FOLDER}/all ~/cluster-${CLUSTER_NAME}/deploy-extra_vars.yml
fi

envsubst < ${TO_DEPLOY_FOLDER}/hosts > ${TO_DEPLOY_FOLDER}/hosts.tmp && mv ${TO_DEPLOY_FOLDER}/hosts.tmp ${TO_DEPLOY_FOLDER}/hosts
envsubst < ${TO_DEPLOY_FOLDER}/all > ${TO_DEPLOY_FOLDER}/all.tmp && mv ${TO_DEPLOY_FOLDER}/all.tmp ${TO_DEPLOY_FOLDER}/all

if [ "${NODE_USER}" != "root" ]
then
    echo "ansible_user=${NODE_USER}" >> ${TO_DEPLOY_FOLDER}/hosts

    if [ ! -z ${NODE_KEY} ]
    then 
        echo "ansible_ssh_private_key_file=~/node_key" >> ${TO_DEPLOY_FOLDER}/hosts
    elif [ ! -z ${NODE_PASSWORD} ]
    then
        echo "ansible_ssh_pass=${NODE_PASSWORD}" >> ${TO_DEPLOY_FOLDER}/hosts
    fi
fi

cp ${TO_DEPLOY_FOLDER}/all ~/cluster-${CLUSTER_NAME}/deploy-all
cp ${TO_DEPLOY_FOLDER}/hosts ~/cluster-${CLUSTER_NAME}/deploy-hosts

# Set ANSIBLE_CONFIG FILE
export ANSIBLE_CONFIG=$(pwd)/ansible.cfg

if [ "${USE_ANSIBLE_PYTHON_3}" == "true" ]
then
    export ANSIBLE_PYTHON_3_PARAMS='-e ansible_python_interpreter=/usr/bin/python3'
fi

# Print Env variables
if [ "${DEBUG}" = "true" ]
then
    echo ""
    echo "****************************** ENV VARIABLES ******************************"
    env | sort 
    echo "***************************************************************************"
    echo ""
fi

###############################
# Launch of scripts to deploy
###############################

if [ "${PRE_INSTALL}" = "true" ] 
then
    echo "############ Setup cluster hosts ############"
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/pre_install/main.yml --extra-vars \"@/tmp/pre_install_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS} "
    fi
    cp playbooks/pre_install/extra_vars.yml /tmp/pre_install_extra_vars.yml
    envsubst < /tmp/pre_install_extra_vars.yml > /tmp/pre_install_extra_vars.yml.tmp && mv /tmp/pre_install_extra_vars.yml.tmp /tmp/pre_install_extra_vars.yml
    echo " Follow progression in: ${LOG_DIR}/pre_install.log "
    ansible-playbook -i ${HOSTS_FILE} playbooks/pre_install/main.yml --extra-vars "@/tmp/pre_install_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > ${LOG_DIR}/pre_install.log 2>&1
    OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/pre_install.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: Hosts successfully Setup "
    else
      echo " FAILURE: Could not setup hosts " 
      echo " See details in file: ${LOG_DIR}/pre_install.log "
      exit 1
    fi
fi

if [ "${PREPARE_ANSIBLE_DEPLOYMENT}" = "true" ]
then
    echo "############ On ${NODE_0} : Prepare Ansible Deployment ############"
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/ansible_install_preparation/main.yml --extra-vars \"@/tmp/ansible_install_preparation_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS} "
    fi
    cp playbooks/ansible_install_preparation/extra_vars.yml /tmp/ansible_install_preparation_extra_vars.yml
    envsubst < /tmp/ansible_install_preparation_extra_vars.yml > /tmp/ansible_install_preparation_extra_vars.yml.tmp && mv /tmp/ansible_install_preparation_extra_vars.yml.tmp /tmp/ansible_install_preparation_extra_vars.yml
    echo " Follow progression in: ${LOG_DIR}/prepare_ansible_deployment.log "
    ansible-playbook -i ${HOSTS_FILE} playbooks/ansible_install_preparation/main.yml --extra-vars "@/tmp/ansible_install_preparation_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > ${LOG_DIR}/prepare_ansible_deployment.log 2>&1
    OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/prepare_ansible_deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: Ansible deployment prepared "
    else
      echo " FAILURE: Could not prepare ansible deployment " 
      echo " See details in file: ${LOG_DIR}/prepare_ansible_deployment.log "
      exit 1
    fi
fi

if [ "${INSTALL}" = "true" ]
then
    echo "############ On ${NODE_0} : Launch Ansible Deployment ############"
    echo " Follow progression in: ${LOG_DIR}/deployment.log "
    if [ "${DISTRIBUTION_TO_DEPLOY}" = "HDP" ]
    then
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; export CLOUD_TO_USE=static ; export INVENTORY_TO_USE=hosts ; bash install_cluster.sh' > ${LOG_DIR}/deployment.log
    else
        echo "******* Installing required packages *******"
        if [ "${USE_ANSIBLE_PYTHON_3}" == "true" ]
        then
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; export PYTHON_PATH=/usr/bin/python3 ; ansible-galaxy install -r requirements.yml --force ; ansible-galaxy collection install -r requirements.yml --force" > ${LOG_DIR}/deployment.log 2>&1
        else
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-galaxy install -r requirements.yml --force ; ansible-galaxy collection install -r requirements.yml --force" > ${LOG_DIR}/deployment.log 2>&1
        fi

        ################################################
        ######## Installation of CDP step by step in order to be able to track installation #######
        ################################################
        echo "******* Verificating cluster Definition *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_inventory_and_definition.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_inventory_and_definition.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Verififcation of Cluster Definition"
        else
          echo " FAILURE: Could not Verify Cluster Definition" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        echo "******* Applying nodes pre-requisites *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_nodes.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_nodes.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Nodes pre-requisites"
        else
          echo " FAILURE: Could not apply pre-requisites for nodes" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        echo "******* Installation of DB, (KDC) etc... *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_infrastructure.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_infrastructure.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Creation of DB, (KDC) etc..."
        else
          echo " FAILURE: Could not create DB, KDC and HA Proxy" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        echo "******* Verificating parcels *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_parcels.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi 
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_parcels.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Verification of Parcels"
        else
          echo " FAILURE: Could verify Parcels" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        if [ "${FREE_IPA}" = "true" ]
        then
            # Free IPA has intermittent failures (usually due to hosts joining the realm too fast), so a simple retry make it work
            FREE_IPA_LAUNCH_TRIED=0
            FREE_IPA_FAILED=true
            while [ $FREE_IPA_LAUNCH_TRIED -lt $FREE_IPA_TRIES ] ; do
                if [ $FREE_IPA_LAUNCH_TRIED -gt 0 ]; then
                    echo "Launching a retry because installation failed, retry is : $FREE_IPA_LAUNCH_TRIED out of $FREE_IPA_TRIES possible tries" 
                fi
                echo "******* Installing Free IPA *******"
                if [ "${DEBUG}" = "true" ]
                then
                    echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_freeipa.yml ${ANSIBLE_PYTHON_3_PARAMS} "
                fi
                ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_freeipa.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
                OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
                if [ "${OUTPUT}" == "2" ]
                then
                  echo " SUCCESS: Deployment of Free IPA"
                  FREE_IPA_FAILED=false
                  break
                else
                  echo " FAILURE: Could not deploy Free IPA" 
                  echo " See details in file: ${LOG_DIR}/deployment.log "
                fi
                FREE_IPA_LAUNCH_TRIED=$((FREE_IPA_LAUNCH_TRIED + 1))
            done
            if [ "${FREE_IPA_FAILED}" == "true" ]
            then
                echo " Total FAILURE: Could not deploy Free IPA after $FREE_IPA_TRIES tries"
                exit 1 
            fi
        fi

        echo "******* Installing Cloudera Manager *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cloudera_manager.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cloudera_manager.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Cloudera Manager Installation"
        else
          echo " FAILURE: Could not install Cloudera Manager" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        if [ "${CM_VERSION:0:1}" = "5" ]
        then
            echo "******* Fixing CDH 5 Paywall *******"
            if [ "${DEBUG}" = "true" ]
            then
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_for_cdh5_paywall.yml ${ANSIBLE_PYTHON_3_PARAMS} "
            fi
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_for_cdh5_paywall.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
            OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
            if [ "${OUTPUT}" == "2" ]
            then
              echo " SUCCESS: Fix CDH 5 paywall "
            else
              echo " FAILURE: Could not fix CDH 5 paywall" 
              echo " See details in file: ${LOG_DIR}/deployment.log "
              exit 1
            fi
        fi

        echo "******* Setting up Kerberos *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_security.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_security.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Setup of Kerberos"
        else
          echo " FAILURE: Could not setup Kerberos" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        if [ "${TLS}" = "true" ]
        then
            echo "******* Enabling Auto-TLS *******"
            if [ "${DEBUG}" = "true" ]
            then
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml extra_auto_tls.yml ${ANSIBLE_PYTHON_3_PARAMS} "
            fi
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml extra_auto_tls.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
            OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
            if [ "${OUTPUT}" == "2" ]
            then
              echo " SUCCESS: Enable Auto-TLS "
            else
              echo " FAILURE: Could not enable Auto-TLS" 
              echo " See details in file: ${LOG_DIR}/deployment.log "
              exit 1
            fi
        fi

        echo "******* Installing Cluster *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cluster.yml ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cluster.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Installation of Cluster"
        else
          echo " FAILURE: Could not Install Cluster" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        if [ "${TLS}" = "true" ]
        then
            echo "******* Fixing Auto-TLS Settings *******"
            if [ "${DEBUG}" = "true" ]
            then
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_auto_tls.yml ${ANSIBLE_PYTHON_3_PARAMS} "
            fi
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_auto_tls.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
            OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
            if [ "${OUTPUT}" == "2" ]
            then
              echo " SUCCESS: Fix settings after Auto-TLS "
            else
              echo " FAILURE: Could not fix settings for Auto-TLS" 
              echo " See details in file: ${LOG_DIR}/deployment.log "
              exit 1
            fi
        fi
        
        if [ "${ENCRYPTION_ACTIVATED}" = "true" ]
        then
            echo "******* Setting up Data Encryption at Rest *******"
            if [ "${DEBUG}" = "true" ]
            then
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml setup_hdfs_encryption.yml ${ANSIBLE_PYTHON_3_PARAMS} "
            fi
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml setup_hdfs_encryption.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> ${LOG_DIR}/deployment.log 2>&1
            OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
            if [ "${OUTPUT}" == "2" ]
            then
              echo " SUCCESS: Setup Data Encryption at Rest "
            else
              echo " FAILURE: Could not Setup Data Encryption at Rest" 
              echo " See details in file: ${LOG_DIR}/deployment.log "
              exit 1
            fi
        fi
        
    fi

    #### Final Success of deployment #####
    OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: Deployment "
    else
      echo " FAILURE: Could not Deploy cluster " 
      echo " See details in file: ${LOG_DIR}/deployment.log "
      exit 1
    fi
fi

if [ "${POST_INSTALL}" = "true" ]
then
    echo "############ Post-Install configuration for CDP ############"
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/post_install/main.yml --extra-vars \"@/tmp/post_install_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS}"
    fi
    cp playbooks/post_install/extra_vars.yml /tmp/post_install_extra_vars.yml
    envsubst < /tmp/post_install_extra_vars.yml > /tmp/post_install_extra_vars.yml.tmp && mv /tmp/post_install_extra_vars.yml.tmp /tmp/post_install_extra_vars.yml
    echo " Follow progression in: ${LOG_DIR}/post_install.log "
    ansible-playbook -i ${HOSTS_FILE} playbooks/post_install/main.yml --extra-vars "@/tmp/post_install_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > ${LOG_DIR}/post_install.log 2>&1
    OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/post_install.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: Post Install Configs "
    else
      echo " FAILURE: Could not apply post install configs " 
      echo " See details in file: ${LOG_DIR}/post_install.log "
      exit 1
    fi
fi

if [ "${USER_CREATION}" = "true" ]
then
    echo "############ User Creation ############"
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/user_creation/main.yml --extra-vars \"@/tmp/user_creation_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS}"
    fi
    cp playbooks/user_creation/extra_vars.yml /tmp/user_creation_extra_vars.yml
    envsubst < /tmp/user_creation_extra_vars.yml > /tmp/user_creation_extra_vars.yml.tmp && mv /tmp/user_creation_extra_vars.yml.tmp /tmp/user_creation_extra_vars.yml 
    echo " Follow progression in: ${LOG_DIR}/user_creation.log "
    ansible-playbook -i ${HOSTS_FILE} playbooks/user_creation/main.yml --extra-vars "@/tmp/user_creation_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > ${LOG_DIR}/user_creation.log 2>&1
    OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/user_creation.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: Users Creation "
    else
      echo " FAILURE: Could not create users " 
      echo " See details in file: ${LOG_DIR}/user_creation.log "
      exit 1
    fi
fi

if [ "${PVC}" = "true" ] && [ "${INSTALL_PVC}" = "true" ]
then
    echo "############ Creating PvC cluster ############" 
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml pvc.yml ${ANSIBLE_PYTHON_3_PARAMS}"
    fi
    echo " Follow progression in: ${LOG_DIR}/pvc_deployment.log "
    ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml pvc.yml ${ANSIBLE_PYTHON_3_PARAMS}" > ${LOG_DIR}/pvc_deployment.log 2>&1
    OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/pvc_deployment.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: PvC Deployed "
    else
      echo " FAILURE: Could not deploy PVC " 
      echo " See details in file: ${LOG_DIR}/pvc_deployment.log "
      exit 1
    fi
fi

if [ "${PVC}" = "true" ] && [ "${CONFIGURE_PVC}" = "true" ]
then
    echo "############ Configuring PvC cluster ############" 
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/pvc_setup/main.yml --extra-vars \"@/tmp/pvc_setup_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS} "
    fi
    cp playbooks/pvc_setup/extra_vars.yml /tmp/pvc_setup_extra_vars.yml
    envsubst < /tmp/pvc_setup_extra_vars.yml > /tmp/pvc_setup_extra_vars.yml.tmp && mv /tmp/pvc_setup_extra_vars.yml.tmp /tmp/pvc_setup_extra_vars.yml
    echo " Follow progression in: ${LOG_DIR}/pvc_configuration.log "
    ansible-playbook -i ${HOSTS_FILE} playbooks/pvc_setup/main.yml --extra-vars "@/tmp/pvc_setup_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > ${LOG_DIR}/pvc_configuration.log 2>&1
    OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/pvc_configuration.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: PvC Configured "
    else
      echo " FAILURE: Could not configure PVC " 
      echo " See details in file: ${LOG_DIR}/pvc_configuration.log "
      exit 1
    fi
fi

if [ "${DATA_LOAD}" = "true" ]
then
    echo "############ Data Loading ############" 
    if [ "${DISTRIBUTION_TO_DEPLOY}" = "HDP" ]
    then
        export RD_VERSION='2.6.5'
    else
        CDH_VERSION_LENGTH=$(echo ${#CDH_VERSION})
        if [ ${CDH_VERSION_LENGTH} = 10 ]
        then
            export RD_VERSION="${CDH_VERSION}"
        else
            export RD_VERSION="${CDH_VERSION:0:5}"
        fi
    fi
    if [ -z ${DATA_LOAD_REPO_URL} ]
    then
        export DATA_LOAD_REPO_URL="https://github.com/frischHWC/random-datagen/releases/download/${DISTRIBUTION_TO_DEPLOY}-${RD_VERSION}/random-datagen-${DISTRIBUTION_TO_DEPLOY}-${RD_VERSION}.tar.gz"
    fi

    if [ "${DATAGEN_AS_A_SERVICE}" == "true" ]
    then
    # New way to deploy DATA using DATAGEN as a Service
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/data_load/main.yml --extra-vars \"@/tmp/data_load_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        cp playbooks/data_load/extra_vars.yml /tmp/data_load_extra_vars.yml
        envsubst < /tmp/data_load_extra_vars.yml > /tmp/data_load_extra_vars.yml.tmp && mv /tmp/data_load_extra_vars.yml.tmp /tmp/data_load_extra_vars.yml
        echo " Follow progression in: ${LOG_DIR}/data_load.log "
        ansible-playbook -i ${HOSTS_FILE} playbooks/data_load/main.yml --extra-vars "@/tmp/data_load_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} >> ${LOG_DIR}/data_load.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/data_load.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Datagen installed and Data loaded "
        else
          echo " FAILURE: Could not load data " 
          echo " See details in file: ${LOG_DIR}/data_load.log "
          exit 1
        fi

    else
    # Old way to deploy data using old releases of random-datagen
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/data_load/main_old.yml --extra-vars \"@/tmp/data_load_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS} "
        fi
        cp playbooks/data_load/extra_vars.yml /tmp/data_load_extra_vars.yml
        envsubst < /tmp/data_load_extra_vars.yml > /tmp/data_load_extra_vars.yml.tmp && mv /tmp/data_load_extra_vars.yml.tmp /tmp/data_load_extra_vars.yml
        echo " Follow progression in: ${LOG_DIR}/data_load.log "
        ansible-playbook -i ${HOSTS_FILE} playbooks/data_load/main_old.yml --extra-vars "@/tmp/data_load_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > ${LOG_DIR}/data_load.log 2>&1
        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/data_load.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Data loaded "
        else
          echo " FAILURE: Could not load data " 
          echo " See details in file: ${LOG_DIR}/data_load.log "
          exit 1
        fi
    fi    
fi


if [ "${DEMO}" = "true" ]
then
    echo "############ Launching Demo ############" 
    CURRENT_DIR=$(pwd)
    cd /tmp/
    rm -rf cdp-demo-repo
    mkdir -p cdp-demo-repo
    git clone ${DEMO_REPO_URL} cdp-demo-repo
    cd cdp-demo-repo
    git checkout ${DEMO_REPO_BRANCH}
    git pull
    export ANSIBLE_CONFIG="ansible.cfg"
    if [ "${DEBUG}" = "true" ]
    then
        echo "Launching this command in a bash way: "
        echo "./cdp_demo.sh --cluster-name=${CLUSTER_NAME} --cm-host=${NODE_0} --edge-host=${EDGE_HOST} --ipa-server=${NODE_IPA} --ssh-key=${NODE_KEY} --ssh-password=${NODE_PASSWORD} --debug=${DEBUG} --use-ipa=${FREE_IPA} --ipa-password=${DEFAULT_PASSWORD}"
    fi
    ./cdp_demo.sh --cluster-name=${CLUSTER_NAME} --cm-host=${NODE_0} --edge-host=${EDGE_HOST} --ipa-server=${NODE_IPA} --ssh-key=${NODE_KEY} --ssh-password=${NODE_PASSWORD} --debug=${DEBUG} --use-ipa=${FREE_IPA} --ipa-password=${DEFAULT_PASSWORD}
    cd $CURRENT_DIR
fi

###############################
# Clean up and end
###############################

echo "############ Remove temporary local files  ############"
rm -rf ${HOSTS_ETC}
rm -rf ${KNOWN_HOSTS}
rm -rf ${AUTHORIZED_KEYS}
rm -rf ${TO_DEPLOY_FOLDER}
rm -rf ${HOSTS_FILE}

echo ""
echo "############ Print Informations about the cluster  ############"
echo ""
if [ "${DISTRIBUTION_TO_DEPLOY}" = "HDP" ]
then 
    echo " Ambari is available at : http://${NODE_0}:8080/ "
else
    if [ "${TLS}" = "true" ]
    then
        echo " Cloudera Manager is available at : https://${NODE_0}:7183/ "
    else
        echo " Cloudera Manager is available at : http://${NODE_0}:7180/ "
    fi
fi
echo ""

if [ "${FREE_IPA}" = "true" ]
then
    echo " Free IPA UI is available at : https://${NODE_IPA}/ipa/ui/ "
    echo ""
fi

if [ "${PVC}" = "true" ] && [ "${PVC_TYPE}" = "ECS" ]
then
    echo " **** WARNING: It is required to have this wildcard DNS entry *apps.${PVC_APP_DOMAIN} to access Control Plane UI ****"
    echo " Add this line to your /etc/hosts: "
    echo "$(cat /etc/hosts | grep -m1 ${PVC_ECS_SERVER_HOST} | cut -d ' ' -f1 ) *apps.${PVC_APP_DOMAIN}"
fi

if [ "${KERBEROS}" = "true" ] && [ "${USER_CREATION}" = "true" ]
then
    echo ""
    echo " Some Kerberos users have been created and their keytabs are on all machines in /home/<username>/, such as /home/${DEFAULT_ADMIN_USER}/ "
    echo " Their keytabs have been retrieved locally in ~/cluster-${CLUSTER_NAME}/ and the krb5.conf has been copied in ~/cluster-${CLUSTER_NAME}/ also, allowing you to directly kinit from your computer with: "
    echo "      env KRB5_CONFIG=~/cluster-${CLUSTER_NAME}/krb5.conf kinit -kt ~/cluster-${CLUSTER_NAME}/${DEFAULT_ADMIN_USER}.keytab ${DEFAULT_ADMIN_USER}"
    echo ""
fi
echo ""
echo ""
echo " To allow easy interaction with the cluster the hosts file used to setup the cluster has been copied to ~/${CLUSTER_NAME}/hosts "
echo " Examples:"
echo ""
echo "  ansible-playbook -i ~/cluster-${CLUSTER_NAME}/hosts ansible_playbook.yml --extra-vars \"\" "
echo "  ansible all -i ~/cluster-${CLUSTER_NAME}/hosts -a \"cat /etc/hosts\" "
echo ""
