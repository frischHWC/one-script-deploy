#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#!/bin/bash


echo "Starting Destroying Machines on the Cloud"

# Mandatory settings
export CLUSTER_NAME=
export CLOUD_PROVIDER="AWS" 

# Related to AWS
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

# For Debugging
export DEBUG="false"
export TF_BASE_WORK_DIR="/tmp"


function usage()
{
    echo "This script aims to provision machines on cloud and then launch installation of a cluster"
    echo ""
    echo "Usage is the following : "
    echo ""
    echo "./destroy-cluster-on-cloud.sh"
    echo "  -h --help"
    echo "  --cluster-name=$CLUSTER_NAME Required as it will be the name of the cluster in cloudcat (Default) "
    echo "  --cloud-provider=$CLOUD_PROVIDER : The cloud provider to use among AWS, (GCP, AZURE not supported) (Default) AWS"
    echo ""
    echo " Parameters only required for AWS : "
    echo "  --aws-access-key=$AWS_ACCESS_KEY_ID : Mandatory to get access to AWS account"
    echo "  --aws-secret-access-key=$AWS_SECRET_ACCESS_KEY : Mandatory to get access to AWS account"
    echo ""
    echo "  --debug=$DEBUG : (Optional) To activate debug "
    echo "  --tf-base-work-dir=$TF_BASE_WORK_DIR : (Optional) To change the default base working directory of terraform (Default) ${TF_BASE_WORK_DIR} "
    echo ""
}

export ALL_PARAMETERS=$(echo $@)


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
        --cloud-provider)
            CLOUD_PROVIDER=$VALUE
            ;;
        --cluster-type)
            CLUSTER_TYPE=$VALUE
            ;;
        --debug)
            DEBUG=$VALUE
            ;;
        --aws-access-key)
            AWS_ACCESS_KEY_ID=$VALUE
            ;;
        --aws-secret-access-key)
            AWS_SECRET_ACCESS_KEY=$VALUE
            ;;
        --tf-base-work-dir)
            TF_BASE_WORK_DIR=$VALUE
            ;;
        *)
            ;;
    esac
    shift
done

# Load logger
. ./logger.sh
logger info:cyan "Start to destroy cluster: #bold:${CLUSTER_NAME}#end_bold in the cloud "

# Setup Variables for execution of terraform
export TF_WORK_DIR="${TF_BASE_WORK_DIR}/terraform_${CLUSTER_NAME}"
export CURRENT_DIR=$(pwd)

# Print Env variables
if [ "${DEBUG}" = "true" ]
then
    print_env_vars
fi

# Launch Terraform
cd ${TF_WORK_DIR}
terraform destroy -auto-approve
if [ -d ${TF_WORK_DIR}/dns_records ]
then
    cd ${TF_WORK_DIR}/dns_records
    terraform destroy -auto-approve
fi
cd ${CURRENT_DIR}

logger success "Finished Destroying Machines of cluster #bold:${CLUSTER_NAME}#end_bold on the Cloud"