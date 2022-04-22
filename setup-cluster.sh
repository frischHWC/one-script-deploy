#!/bin/bash

###############################
# Setup of all variables and help
###############################

# TODO: Test with new release

# Main cluster info
export CLUSTER_NAME=
export NODES_BASE=
export NODE_IPA=
export NODE_KTS=

# License 
export PAYWALL_USER=
export PAYWALL_PASSWORD=
export LICENSE_FILE=

# Nodes connection
export NODE_USER="root"
export NODE_KEY=""
export NODE_PASSWORD=""

# Steps to do
export PRE_INSTALL="true"
export PREPARE_ANSIBLE_DEPLOYMENT="true"
export INSTALL="true"
export POST_INSTALL="true"
export USER_CREATION="true"
export DATA_LOAD="true"

# Auth & Log
export DEFAULT_PASSWORD="Cloudera1234"
export DEBUG="false"
export LOG_DIR="/tmp/deploy_to_cloudcat_logs/"$(date +%m-%d-%Y-%H-%M-%S)

# Ansible Deployment files 
export DISTRIBUTION_TO_DEPLOY="CDP"
export CLUSTER_TYPE="full-pvc"
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
export CM_VERSION="7.6.1"
export CDH_VERSION="7.1.7.1000"
export PVC_VERSION="1.3.4"
export CSA_VERSION="1.6.2.0"
export CFM_VERSION="2.1.3.0"
export SPARK3_VERSION="3.2.7171000.0"
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
export AMBARI_REPO=
export HDP_REPO=
export HDF_REPO=

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
export PVC="false"
export PVC_TYPE="ECS"
export CREATE_CDW="true"
export CREATE_CDE="true"
export CREATE_CML="true"
export OC_TAR_FILE_PATH=""

# External CSD
export USE_CSA="false"
export USE_CFM="false"
export USE_SPARK3="false"

# Installation
export INSTALL_REPO_URL="https://github.com/frischHWC/cldr-playbook/archive/refs/heads/main.zip"
export ANSIBLE_REPO_DIR="cldr-playbook-main"

# Data Load
export DATA_LOAD_REPO_URL=""

# Demo
export DEMO_REPO_URL=""


# INTERNAL USAGE OF THESE VARIABLES, do no touch these
export KTS_SERVERS=""
export KTS_SERVERS_GROUP=""
export KRB5_SERVERS=""
export KRB_SERVER_TYPE=""
export CA_SERVERS=""
export KMS_SERVERS=""

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
    echo "  --cluster-name=$CLUSTER_NAME Required as it will be the name of the cluster (Default) "
    echo ""
    echo "  --paywall-username=$PAYWALL_USER : Required since February 2021 for all versions (Default)  "
    echo "  --paywall-password=$PAYWALL_PASSWORD : Required since February 2021 for all versions (Default)  "
    echo "  --license-file=$LICENSE_FILE : The path to license file (Default) "
    echo ""
    echo "  --node-user=$NODE_USER : The user to connect to each node (Default) root"
    echo "  --node-key=$NODE_KEY : The key to connect to all nodes (Default) "
    echo "  --node-password=$NODE_PASSWORD : The password to connect to all nodes (Default) "
    echo ""
    echo "  --nodes-base=$NODES_BASE : space separated list of all nodes (Default) "
    echo "  --node-ipa=$NODE_IPA : Required only if using FreeIPA (Default) "
    echo "  --node-kts=$NODE_KTS : Required only if using KTS (Default) "
    echo ""
    echo "  --cluster-type=$CLUSTER_TYPE : To simplify deployment, this parameter will adjust number of nodes, security and templates to deploy.  "
    echo "       Choices: basic, streaming, pvc, pvc-oc, full, full-pvc, cdh5, cdh6, hdp3, hdp2 (Default) Will install a CDP 7 with almost all services"
    echo ""
    echo ""
    echo " These are optionnal parameters to test the deployment and run certain steps only : "
    echo ""
    echo ""
    echo "  --pre-install=$PRE_INSTALL : (Optional) To do setup scripts (Default) true "
    echo "  --install=$INSTALL : (Optional) To do the installation, it is only for debugging purpose (Default) true "
    echo "  --post-install=$POST_INSTALL : (Optional) To do post install tasks (such as CM no unlogin) (Default) true"
    echo "  --user-creation=$USER_CREATION : (Optional) Creates two users with their keytabs and home directory on all nodes (Required if loading data) (Default) true " 
    echo "  --data-load=$DATA_LOAD : (Optional) Whether to initiate post deployment tasks including data loading (Default) false "
    echo "  --prepare-ansible-deployment=$PREPARE_ANSIBLE_DEPLOYMENT : (Optional) To prepare deployment by copying and setting all files for deployment on node 1 (Default) true"
    echo "  --install-pvc=$INSTALL_PVC : (Optional) To launch installation of PVC (Default) true"
    echo "  --configure-pvc=$CONFIGURE_PVC : (Optional) To launch configuration of PVC (Default) true"
    echo "  --debug=$DEBUG : (Optional) To setup debug mode for all playbooks (Default) false"
    echo "  --log-dir=$LOG_DIR : (Optional) To specify where this script will logs its files (Default) ~/deploy_to_cloudcat_logs/ "
    echo ""
    echo ""
    echo " These are optionnal parameters to tune and configure differently the deployment :"
    echo ""
    echo ""
    echo "  --default-password=$DEFAULT_PASSWORD : (Optional) Password used for UIs (Default) Admin1234 "
    echo ""
    echo "  --ansible-host-file=$ANSIBLE_HOST_FILE : (Optional) The path to ansible hosts file (Default) ansible-cdp/hosts "
    echo "  --ansible-all-file=$ANSIBLE_ALL_FILE : (Optional) The path to ansible all file  (Default) ansible-cdp/all"
    echo "  --ansible-cluster-file=$ANSIBLE_CLUSTER_YML_FILE : (Optional) The path to ansible yaml cluster file (Default) ansible-cdp/cluster.yml"
    echo "  --ansible-extravars-file=$ANSIBLE_EXTRA_VARS_YML_FILE : (Optional) The path to ansible extra_vars file  (Default) ansible-cdp/extra_vars.yml"
    echo "  --distribution-to-deploy=$DISTRIBUTION_TO_DEPLOY : (Optional) Choose between CDP, CDH, HDP (Default) CDP"
    echo ""
    echo "  --cm-version=$CM_VERSION : (Optional) Version of CM (Default) $CM_VERSION "
    echo "  --cdh-version=$CDH_VERSION : (Optional) Version of CDH (Default) $CDH_VERSION "
    echo "  --csa-version=$CSA_VERSION : (Optional) Version of CSA (Default) $CSA_VERSION "
    echo "  --cfm-version=$CFM_VERSION : (Optional) Version of CFM (Default) $CFM_VERSION "
    echo "  --ambari-version=$AMBARI_VERSION : (Optional) Version of Ambari (Default) $AMBARI_VERSION "
    echo "  --hdp-version=$HDP_VERSION : (Optional) Version of HDP (Default) $HDP_VERSION "
    echo "  --hdf-version=$HDF_VERSION : (Optional) Version of HDP (Default) $HDF_VERSION "
    echo "  --spark3-version=$SPARK3_VERSION : (Optional) Version of SPARK3 (Default) $SPARK3_VERSION"
    echo "  --pvc-version=$PVC_VERSION : (Optional) Version of PVC for CDP deployment (Default) $PVC_VERSION "
    echo ""
    echo "  --cm-repo=$CM_REPO : (Optional) repo of CM (Default) $CM_REPO "
    echo "  --cdh-repo=$CDH_REPO : (Optional) repo of CDH (Default) $CDH_REPO "
    echo "  --csa-repo=$CSA_BASE_REPO : (Optional) repo of CSA (Default) $CSA_BASE_REPO "
    echo "  --cfm-repo=$CFM_BASE_REPO : (Optional) repo of CFM (Default) $CFM_BASE_REPO "
    echo "  --spark3-repo=$SPARK3_BASE_REPO : (Optional) repo of SPARK3 (Default) $SPARK3_BASE_REPO "
    echo "  --ambari-repo=$AMBARI_REPO : (Optional) repo of Ambari (Default) $AMBARI_REPO "
    echo "  --hdp-repo=$HDP_REPO : (Optional) repo of HDP (Default) $HDP_REPO "
    echo "  --hdf-repo=$HDF_REPO : (Optional) repo of HDP (Default) $HDF_REPO "
    echo "  --pvc-repo=$PVC_REPO : (Optional) repo of PVC for CDP deployment (Default) $PVC_REPO "
    echo ""
    echo "  --kerberos=$KERBEROS : (Optional) To set up Kerberos or not (Default) true "
    echo "  --realm=$REALM : (Optional) Realm specified for kerberos(Default) FRISCH.COM "
    echo "  --tls=$TLS : (Optional) DEPRECATED for CDP: Use auto-tls instead, To set up TLS or not (Default) false "
    echo "  --free-ipa=$FREE_IPA : (Optional) To install Free IPA and use it or not (Default) false "
    echo "  --encryption-activated=$ENCRYPTION_ACTIVATED : (Optional) To setup TDE with KTS/KMS (only on CDP) (Default) false  "
    echo ""
    echo "  --os=$OS : (Optional) OS to use (Default) centos"
    echo "  --os-version=$OS_VERSION : (Optional) OS version to use (Default) 7.7" 
    echo "  --install-python3=$INSTALL_PYTHON3 : (Optional) To install python3 on all hosts (Default) false "
    echo ""
    echo "  --pvc=$PVC : (Optional) If PVC should be deployed and configured (Default) false "
    echo "  --pvc-type=$PVC_TYPE : (Optional) Which type of PVC (OC or ECS) (Default) ECS "
    echo "  --nodes-ecs=$NODES_PVC_ECS : (Optional) A comma separated list of ECS nodes (external to cluster) where to install ECS (Default)  "
    echo "  --kubeconfig-path=$KUBECONFIG_PATH : (Optional) To use with CDP PvC on Open Shift, it is then required (Default)   "
    echo "  --oc-tar-file-path=$OC_TAR_FILE_PATH Required if using OpenShift, local path to oc.tar file provided by RedHat (Default) "
    echo "  --cluster-name-pvc=$CLUSTER_NAME_PVC Optional as it is derived from cluster-name (Default) <cluster-name>-pvc"
    echo "  --create-cdw=$CREATE_CDW Optional, used to auto setup a CDW if PVC is deployed (Default) false"
    echo "  --create-cde=$CREATE_CDE Optional, used to auto setup a CDE if PVC is deployed (Default) false"
    echo "  --create-cml=$CREATE_CML Optional, used to auto setup a CML if PVC is deployed (Default) false"
    echo ""
    echo "  --install-repo-url=$INSTALL_REPO_URL : (Optional) Install repo URL (Default)  "
    echo "  --ansible-repo-dir=$ANSIBLE_REPO_DIR : (Optional) Directory where install repo will be deployed (Default) cldr-playbook-master "
    echo "  --data-load-repo-url=$DATA_LOAD_REPO_URL : (Optional) Data Load repo URL (Default) "
    echo "  --demo-repo-url=$DEMO_REPO_URL : (Optional) Demo repo URL (Default)"
    echo ""
    echo "  --use-csa=$USE_CSA : (Optional) Use of CSA (Default) false "
    echo "  --use-cfm=$USE_CFM : (Optional) Use of CFM (Default) false "
    echo "  --use-spark3=$USE_SPARK3 : (Optional) Use of Spark 3 (Default) false "
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
        --node-password)
            NODE_PASSWORD=$VALUE
            ;;  
        --nodes-base)
            NODES_BASE=$VALUE
            ;;  
        --node-ipa)
            NODE_IPA=$VALUE
            ;;
        --node-kts)
            NODE_KTS=$VALUE
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
        --prepare-ansible-deployment)
            PREPARE_ANSIBLE_DEPLOYMENT=$VALUE
            ;;
        --install-pvc)
            INSTALL_PVC=$VALUE
            ;;
        --configure-pvc)
            CONFIGURE_PVC=$VALUE
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
            CSA_REPO=$VALUE
            ;;
        --cfm-repo)
            CFM_REPO=$VALUE
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
            SPARK3_REPO=$VALUE
            ;;
        --pvc-repo)
            PVC_REPO=$VALUE
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
        --os)
            OS=$VALUE
            ;;
        --os-version)
            OS_VERSION=$VALUE
            ;;
        --install-python3)
            INSTALL_PYTHON3=$VALUE
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
        --install-repo-url)
            INSTALL_REPO_URL=$VALUE
            ;;
        --ansible-repo-dir)
            ANSIBLE_REPO_DIR=$VALUE
            ;;
        --data-load-repo-url)
            DATA_LOAD_REPO_URL=$VALUE
            ;;
        --demo-repo-url)
            DEMO_REPO_URL=$VALUE
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
        *)
            ;;
    esac
    shift
done

#############################################################################################
##### Check on important variables before starting
#############################################################################################
if [ -z ${CLUSTER_NAME} ] || [ "${#CLUSTER_NAME}" -lt 4 ] || [[ "${CLUSTER_NAME}" =~ ['!@#$%^&*()_+-'] ]]
then
    echo "Cluster Name should be specified properly with option --cluster-name, must contain 3 characters, only lowercases and no special characters " 
    echo " '${CLUSTER_NAME}' is not a valid name"  
    exit 1 
fi

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
        exit 1
    fi
fi
fi

# TODO: add check on pvc if no nodes are set or no kubeconfig file
# TODO: add checks


# To ensure log dirs exists 
mkdir -p ${LOG_DIR}/

# TODO: Add a default with: security + FreeIPA + KTS + Streaming with Nifi + Optional pvc

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
    elif [ "${CLUSTER_TYPE}" = "pvc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-pvc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-pvc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-pvc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-pvc/extra_vars.yml"
        export CM_VERSION="7.5.5"
        export CDH_VERSION="7.1.7.0"
        export PVC="true"
    elif [ "${CLUSTER_TYPE}" = "pvc-oc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-pvc-oc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-pvc-oc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-pvc-oc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-pvc-oc/extra_vars.yml"
        export CM_VERSION="7.5.5"
        export CDH_VERSION="7.1.7.0"
        export PVC="true"
        export PVC_TYPE="OC"
    elif [ "${CLUSTER_TYPE}" = "streaming" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-streaming/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-streaming/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-streaming/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-streaming/extra_vars.yml"
        export USE_SPARK3="true"
        export USE_CSA="true"
        export USE_CFM="true"
    elif [ "${CLUSTER_TYPE}" = "full-enc-pvc" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdp-full-enc-pvc/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdp-full-enc-pvc/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdp-full-enc-pvc/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdp-full-enc-pvc/extra_vars.yml"
        export USE_CSA="true"
        export USE_CFM="true"
        export CM_VERSION="7.5.5"
        export CDH_VERSION="7.1.7.0"
        export PVC="true"
        export ENCRYPTION_ACTIVATED="true"
    elif [ "${CLUSTER_TYPE}" = "cdh6" ]
    then
        export ANSIBLE_HOST_FILE="ansible-cdh-6/hosts"
        export ANSIBLE_ALL_FILE="ansible-cdh-6/all"
        export ANSIBLE_CLUSTER_YML_FILE="ansible-cdh-6/cluster.yml"
        export ANSIBLE_EXTRA_VARS_YML_FILE="ansible-cdh-6/extra_vars.yml"
        export DISTRIBUTION_TO_DEPLOY="CDH"
        export CM_VERSION="6.3.3"
        export CDH_VERSION="6.3.3"
        export TLS="false"
        export DATA_LOAD="false"
        export POST_INSTALL="false"
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
    elif [ "${CLUSTER_TYPE}" = "hdp3" ]
    then
        export ANSIBLE_HOST_FILE="ansible-hdp-3/hosts"
        export ANSIBLE_ALL_FILE="ansible-hdp-3/all"
        export DISTRIBUTION_TO_DEPLOY="HDP"
        export INSTALL_REPO_URL="https://github.com/frischHWC/ansible-hortonworks/archive/refs/heads/master.zip"
        export ANSIBLE_REPO_DIR="ansible-hortonworks-master"
        export DATA_LOAD="false"
        export POST_INSTALL="false"
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
if [ "${OS}" = "centos" ]
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
    fi
fi

if [ -z "${PVC_REPO}" ]
then
    export PVC_REPO="https://archive.cloudera.com/p/cdp-pvc-ds/latest/"
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
        export CFM_REPO="https://archive.cloudera.com/p/CFM/2.x/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/"
        export CFM_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/CFM/2.x/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/ | grep .jar | grep NIFI- | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_REGISTRY_CSD_JAR=$(curl -s -X GET -u ${PAYWALL_USER}:${PAYWALL_PASSWORD} https://archive.cloudera.com/p/CFM/2.x/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/ | grep .jar | grep NIFIREGISTRY | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_CSD="https://archive.cloudera.com/p/CFM/2.x/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/${CFM_CSD_JAR}"
        export CFM_REGISTRY_CSD="https://archive.cloudera.com/p/CFM/2.x/${OS_BY_CLDR}${OS_VERSION:0:1}/${OS_INSTALLER_BY_CLDR}/tars/parcel/${CFM_REGISTRY_CSD_JAR}"
    else
        export CFM_REPO="${CFM_BASE_REPO}tars/parcel/"
        export CFM_CSD_JAR=$(curl -s -X GET ${CFM_BASE_REPO}/tars/parcel/ | grep .jar | grep NIFI- | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_REGISTRY_CSD_JAR=$(curl -s -X GET ${CFM_BASE_REPO}/tars/parcel/ | grep .jar | grep NIFIREGISTRY | cut -d '>' -f 3 | cut -d '<' -f 1)
        export CFM_CSD="${CFM_BASE_REPO}tars/parcel/${CFM_CSD_JAR}"
        export CFM_REGISTRY_CSD="${CFM_BASE_REPO}tars/parcel/${CFM_REGISTRY_CSD_JAR}"
    fi
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

###############################
# Setup of files to interact with the cluster
###############################

export NODES_SORTED=$( echo ${NODES_BASE} | sort | uniq )
export NODES=( ${NODES_SORTED} )
export HOSTS_FILE=$(mktemp)
export HOSTS_ETC=$(mktemp)
export KNOWN_HOSTS=$(mktemp)
export AUTHORIZED_KEYS=$(mktemp)
export TO_DEPLOY_FOLDER=$(mktemp -d)

echo "############ Setup connections to all nodes  ############"
touch ~/.ssh/known_hosts

for i in ${!NODES[@]}
do
    export "NODE_$i"=${NODES[$i]}    
    echo "${NODES[$i]}" >> ${HOSTS_FILE}

    if [ "${PRE_INSTALL}" = "true" ] 
    then
        SSHKey=`ssh-keyscan ${NODES[$i]} 2> /dev/null`
        echo $SSHKey >> ~/.ssh/known_hosts
        echo $SSHKey >> ${KNOWN_HOSTS}
        IP_ADRESS_SOLVED=$( dig +short ${NODES[$i]} )
        echo "${IP_ADRESS_SOLVED} ${NODES[$i]}" >> ${HOSTS_ETC}
        echo "**** Connection setup to ${NODES[$i]} ****"
    fi
done

if [ ! -z "${NODE_IPA}" ]
then
    echo "${NODE_IPA}" >> ${HOSTS_FILE}
    if [ "${PRE_INSTALL}" = "true" ] 
    then
        SSHKey=`ssh-keyscan ${NODE_IPA} 2> /dev/null`
        echo $SSHKey >> ~/.ssh/known_hosts
        echo $SSHKey >> ${KNOWN_HOSTS}
        IP_ADRESS_SOLVED=$( dig +short ${NODE_IPA} )
        echo "${IP_ADRESS_SOLVED} ${NODE_IPA}" >> ${HOSTS_ETC}
        echo "**** Connection setup to ${NODE_IPA} ****"
    fi
fi

if [ ! -z "${NODE_KTS}" ]
then
    echo "${NODE_KTS}" >> ${HOSTS_FILE}
    if [ "${PRE_INSTALL}" = "true" ] 
    then
        SSHKey=`ssh-keyscan ${NODE_KTS} 2> /dev/null`
        echo $SSHKey >> ~/.ssh/known_hosts
        echo $SSHKey >> ${KNOWN_HOSTS}
        IP_ADRESS_SOLVED=$( dig +short ${NODE_KTS} )
        echo "${IP_ADRESS_SOLVED} ${NODE_KTS}" >> ${HOSTS_ETC}
        echo "**** Connection setup to ${NODE_KTS} ****"
    fi
fi

if [ ! -z "${NODES_PVC_ECS}" ]
then
export NODES_PVC_ECS_SORTED=$( echo ${NODES_PVC_ECS} | sort | uniq )
    for i in ${!NODES_PVC_ECS_SORTED[@]}
    do
        echo "${NODES_PVC_ECS_SORTED[$i]}" >> ${HOSTS_FILE}
        if [ "${PRE_INSTALL}" = "true" ] 
        then
            SSHKey=`ssh-keyscan ${NODES_PVC_ECS_SORTED[$i]} 2> /dev/null`
            echo $SSHKey >> ~/.ssh/known_hosts
            echo $SSHKey >> ${KNOWN_HOSTS}
            IP_ADRESS_SOLVED=$( dig +short ${NODES_PVC_ECS_SORTED[$i]} )
            echo "${IP_ADRESS_SOLVED} ${NODES_PVC_ECS_SORTED[$i]}" >> ${HOSTS_ETC}
            echo "**** Connection setup to ${NODES_PVC_ECS_SORTED[$i]} ****"
        fi
    done

new_line=$'\n'
export NODES_ECS_PRINTABLE="$(echo ${NODES_PVC_ECS} | sed 's/,/'"\\${new_line}"'/g')"

fi


echo "############ Setup of files to interact with cluster  ############"

# Prepare hosts file to interact with cluster 
echo "
[main]
${NODE_0}

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

cp ${HOSTS_FILE} /tmp/hosts-${CLUSTER_NAME}

###############################
# Preparation of files for ansible installation
###############################

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
    export KTS_SERVERS="
[kts_active]
${NODE_KTS}

[kts_servers:children]
kts_active"

    export KTS_SERVERS_GROUP="kts_servers"

    export KMS_SERVERS="
[kms_servers]
${NODE_0}"
fi

if [ ! -z ${NODE_IPA} ]
then
    export KRB_SERVER_TYPE="Red Hat IPA"
else
    export KRB_SERVER_TYPE="MIT KDC"
fi

if [ "${DISTRIBUTION_TO_DEPLOY}" != "HDP" ]
then
    envsubst < ${TO_DEPLOY_FOLDER}/extra_vars.yml > ${TO_DEPLOY_FOLDER}/extra_vars.yml.tmp && mv ${TO_DEPLOY_FOLDER}/extra_vars.yml.tmp ${TO_DEPLOY_FOLDER}/extra_vars.yml
fi
envsubst < ${TO_DEPLOY_FOLDER}/hosts > ${TO_DEPLOY_FOLDER}/hosts.tmp && mv ${TO_DEPLOY_FOLDER}/hosts.tmp ${TO_DEPLOY_FOLDER}/hosts
envsubst < ${TO_DEPLOY_FOLDER}/all > ${TO_DEPLOY_FOLDER}/all.tmp && mv ${TO_DEPLOY_FOLDER}/all.tmp ${TO_DEPLOY_FOLDER}/all

if [ "${DEBUG}" = "true" ]
then
    env | tr '\n' '\t' | sort 
fi

###############################
# Launch of scripts to deploy
###############################

if [ "${PRE_INSTALL}" = "true" ] 
then
    echo "############ Setup cluster hosts ############"
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/pre_install/main.yml --extra-vars \"@/tmp/pre_install_extra_vars.yml\" "
        echo " Follow advancement at: ${LOG_DIR}/pre_install.log "
    fi
    cp playbooks/pre_install/extra_vars.yml /tmp/pre_install_extra_vars.yml
    envsubst < /tmp/pre_install_extra_vars.yml > /tmp/pre_install_extra_vars.yml.tmp && mv /tmp/pre_install_extra_vars.yml.tmp /tmp/pre_install_extra_vars.yml
    ansible-playbook -i ${HOSTS_FILE} playbooks/pre_install/main.yml --extra-vars "@/tmp/pre_install_extra_vars.yml" 2>&1 > ${LOG_DIR}/pre_install.log
    OUTPUT=$(tail -20 ${LOG_DIR}/pre_install.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
        echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/ansible_install_preparation/main.yml --extra-vars \"@/tmp/ansible_install_preparation_extra_vars.yml\" "
        echo " Follow advancement at: ${LOG_DIR}/prepare_ansible_deployment.log "
    fi
    cp playbooks/ansible_install_preparation/extra_vars.yml /tmp/ansible_install_preparation_extra_vars.yml
    envsubst < /tmp/ansible_install_preparation_extra_vars.yml > /tmp/ansible_install_preparation_extra_vars.yml.tmp && mv /tmp/ansible_install_preparation_extra_vars.yml.tmp /tmp/ansible_install_preparation_extra_vars.yml
    ansible-playbook -i ${HOSTS_FILE} playbooks/ansible_install_preparation/main.yml --extra-vars "@/tmp/ansible_install_preparation_extra_vars.yml" 2>&1 > ${LOG_DIR}/prepare_ansible_deployment.log
    OUTPUT=$(tail -20 ${LOG_DIR}/prepare_ansible_deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
    echo " Follow advancement at: ${LOG_DIR}/deployment.log "
    if [ "${DISTRIBUTION_TO_DEPLOY}" = "HDP" ]
    then
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; export CLOUD_TO_USE=static ; export INVENTORY_TO_USE=hosts ; bash install_cluster.sh' > ${LOG_DIR}/deployment.log
    else
        echo "******* Installing required packages *******"
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-galaxy install -r requirements.yml ; ansible-galaxy collection install -r requirements.yml ' 2>&1 > ${LOG_DIR}/deployment.log
        
        ################################################
        ######## Installation of CDP step by step in order to be able to track installation #######
        ################################################
        echo "******* Verificating cluster Definition *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_inventory_and_definition.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_inventory_and_definition.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Verififcation of Cluster Definition"
        else
          echo " FAILURE: Could not Verify Cluster Definition" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        echo "******* Installation of DB, Java, (KDC) etc... *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_infrastructure.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_infrastructure.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Creation of DB, Java, (KDC) etc..."
        else
          echo " FAILURE: Could not create DB, KDC and HA Proxy" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        echo "******* Verificating parcels *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_parcels.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml verify_parcels.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
            echo "******* Installing Free IPA *******"
            if [ "${DEBUG}" = "true" ]
            then
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_freeipa.yml "
            fi
            ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml create_freeipa.yml' 2>&1 >> ${LOG_DIR}/deployment.log
            OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
            if [ "${OUTPUT}" == "2" ]
            then
              echo " SUCCESS: Deployment of Free IPA"
            else
              echo " FAILURE: Could not deploy Free IPA" 
              echo " See details in file: ${LOG_DIR}/deployment.log "
              exit 1
            fi
        fi

        echo "******* Applying nodes pre-requisites *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_nodes.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_nodes.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ]
        then
          echo " SUCCESS: Nodes pre-requisites"
        else
          echo " FAILURE: Could not apply pre-requisites for nodes" 
          echo " See details in file: ${LOG_DIR}/deployment.log "
          exit 1
        fi

        echo "******* Installing Cloudera Manager *******"
        if [ "${DEBUG}" = "true" ]
        then
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cloudera_manager.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cloudera_manager.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_for_cdh5_paywall.yml "
            fi
            ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_for_cdh5_paywall.yml' 2>&1 >> ${LOG_DIR}/deployment.log
            OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_security.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml prepare_security.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml extra_auto_tls.yml "
            fi
            ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml extra_auto_tls.yml' 2>&1 >> ${LOG_DIR}/deployment.log
            OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
            echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cluster.yml "
        fi
        ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml install_cluster.yml' 2>&1 >> ${LOG_DIR}/deployment.log
        OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_auto_tls.yml "
            fi
            ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml fix_auto_tls.yml' 2>&1 >> ${LOG_DIR}/deployment.log
            OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
                echo " Command launched on controller: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml setup_hdfs_encryption.yml "
            fi
            ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml setup_hdfs_encryption.yml' 2>&1 >> ${LOG_DIR}/deployment.log
            OUTPUT=$(tail -20 ${LOG_DIR}/deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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

if [ "${POST_INSTALL}" = "true" ] && [ "${DISTRIBUTION_TO_DEPLOY}" = "CDP" ]
then
    echo "############ Post-Install configuration for CDP ############"
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/ansible_install_preparation/main.yml --extra-vars \"@/tmp/post_install_extra_vars.yml\" "
        echo " Follow advancement at: ${LOG_DIR}/post_install.log "
    fi
    cp playbooks/post_install/extra_vars.yml /tmp/post_install_extra_vars.yml
    envsubst < /tmp/post_install_extra_vars.yml > /tmp/post_install_extra_vars.yml.tmp && mv /tmp/post_install_extra_vars.yml.tmp /tmp/post_install_extra_vars.yml
    ansible-playbook -i ${HOSTS_FILE} playbooks/post_install/main.yml --extra-vars "@/tmp/post_install_extra_vars.yml" 2>&1 > ${LOG_DIR}/post_install.log
    OUTPUT=$(tail -20 ${LOG_DIR}/post_install.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
        echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/user_creation/main.yml --extra-vars \"@/tmp/user_creation_extra_vars.yml\" "
        echo " Follow advancement at: ${LOG_DIR}/user_creation.log "
    fi
    cp playbooks/user_creation/extra_vars.yml /tmp/user_creation_extra_vars.yml
    envsubst < /tmp/user_creation_extra_vars.yml > /tmp/user_creation_extra_vars.yml.tmp && mv /tmp/user_creation_extra_vars.yml.tmp /tmp/user_creation_extra_vars.yml
    ansible-playbook -i ${HOSTS_FILE} playbooks/user_creation/main.yml --extra-vars "@/tmp/user_creation_extra_vars.yml" 2>&1 > ${LOG_DIR}/user_creation.log
    OUTPUT=$(tail -20 ${LOG_DIR}/user_creation.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
    echo " Follow advancement at: ${LOG_DIR}/pvc_deployment.log "
    ssh ${NODE_USER}@${NODE_0} 'cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml pvc.yml' 2>&1 > ${LOG_DIR}/pvc_deployment.log
    OUTPUT=$(tail -20 ${LOG_DIR}/pvc_deployment.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
        echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/pvc_setup/main.yml --extra-vars \"@/tmp/pvc_setup_extra_vars.yml\" "
        echo " Follow advancement at: ${LOG_DIR}/pvc_configuration.log "
    fi
    cp playbooks/pvc_setup/extra_vars.yml /tmp/pvc_setup_extra_vars.yml
    envsubst < /tmp/pvc_setup_extra_vars.yml > /tmp/pvc_setup_extra_vars.yml.tmp && mv /tmp/pvc_setup_extra_vars.yml.tmp /tmp/pvc_setup_extra_vars.yml
    ansible-playbook -i ${HOSTS_FILE} playbooks/pvc_setup/main.yml --extra-vars "@/tmp/pvc_setup_extra_vars.yml" 2>&1 > ${LOG_DIR}/pvc_configuration.log
    OUTPUT=$(tail -20 ${LOG_DIR}/pvc_configuration.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
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
    if [ "${DEBUG}" = "true" ]
    then
        echo " Command launched: ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} playbooks/data_load/main.yml --extra-vars \"@/tmp/data_load_extra_vars.yml\" "
        echo " Follow advancement at: ${LOG_DIR}/data_load.log "
    fi
    cp playbooks/data_load/extra_vars.yml /tmp/data_load_extra_vars.yml
    envsubst < /tmp/data_load_extra_vars.yml > /tmp/data_load_extra_vars.yml.tmp && mv /tmp/data_load_extra_vars.yml.tmp /tmp/data_load_extra_vars.yml
    ansible-playbook -i ${HOSTS_FILE} playbooks/data_load/main.yml --extra-vars "@/tmp/data_load_extra_vars.yml" 2>&1 > ${LOG_DIR}/data_load.log
    OUTPUT=$(tail -20 ${LOG_DIR}/data_load.log | grep -A20 RECAP | grep -v "failed=0" | wc -l | xargs)
    if [ "${OUTPUT}" == "2" ]
    then
      echo " SUCCESS: Data loaded "
    else
      echo " FAILURE: Could not load data " 
      echo " See details in file: ${LOG_DIR}/data_load.log "
      exit 1
    fi
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
    echo " Cloudera Manager is available at : http://${NODE_0}:7180/ "
fi
echo ""

if [ "${FREE_IPA}" = "true" ]
then
    echo " Free IPA UI is available at : http://${NODE_IPA}/ipa/ui/ "
    echo ""
fi

if [ "${KERBEROS}" = "true" ] && [ "${USER_CREATION}" = "true" ]
then
    echo ""
    echo " Two Kerberos users have been created and their keytabs are on all machines in /home/dev/ or /home/administrator/ "
    echo " Their keytabs have been retrieved locally in /tmp/ and the krb5.conf has been copied in /tmp/ also, allowing you to directly kinit from your computer with: "
    echo "      env KRB5_CONFIG=/tmp/krb5-${CLUSTER_NAME}.conf kinit -kt /tmp/dev-${CLUSTER_NAME}.keytab dev"
    echo ""
fi
echo ""
echo ""
echo " To allow easy interaction with the cluster the hosts file used to setup the cluster has been copied to /tmp/hosts-${CLUSTER_NAME} "
echo " Examples:"
echo ""
echo "  ansible-playbook -i /tmp/hosts-${CLUSTER_NAME} ansible_playbook.yml --extra-vars \"\" "
echo "  ansible all -i /tmp/hosts-${CLUSTER_NAME} -a \"cat /etc/hosts\" "
echo ""
