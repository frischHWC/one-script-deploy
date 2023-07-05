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

export CLUSTER_NAME=

export NODE_USER="root"
export NODE_KEY=""
export NODE_PASSWORD=""

export DEBUG="true"
export LOG_DIR="/tmp/unpause_cluster_logs/"$(date +%m-%d-%Y-%H-%M-%S)

export CM_HOST=""
export CM_PORT="7183"
export CM_USER="admin"
export CM_PASSWORD="admin"

function usage()
{
    echo "This script aims to unpause provided machines and restart well cluster"
    echo ""
    echo "Usage is the following : "
    echo ""
    echo "./unpause_machines.sh"
    echo "  -h --help"
    echo "  --cluster-name=$CLUSTER_NAME Required as it will be the name of the cluster in cloudcat (Default) "
    echo ""
    echo "  --node-user=$NODE_USER : The user to connect to each node (Default) $NODE_USER "
    echo "  --node-key=$NODE_KEY : The key to connect to all nodes (Default) $NODE_KEY "
    echo "  --node-password=$NODE_PASSWORD : The password to connect to all nodes (Default) $NODE_PASSWORD "
    echo ""
    echo "  --cm-host=$CM_HOST (Required) To specify the CM Host(Default) "
    echo "  --cm-port=$CM_PORT (Optional) To specify the CM Port (Default) ${CM_PORT} "
    echo "  --cm-user=$CM_USER (Optional) To specify a user to log into CM (Default) ${CM_USER} "
    echo "  --cm-password=$CM_PASSWORD (Optional) Password associated with user to log into CM (Default) ${CM_PASSWORD} "
    echo ""
    echo "  --debug=$DEBUG (Optional) Set debug mode or not (Default) ${DEBUG} "
    echo "  --log-dir=$LOG_DIR (Optional) To use a non default log dir (Default) ${LOG_DIR} "
    echo ""
    echo " <API_KEY> : Required to access Cloudcat APIs (Default)"
    echo ""
}

export API_KEY=$(echo $@ | sed 's/--[^ ]*//g')
API_KEY=$(echo $API_KEY | sed 's/ *$//g')

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
        --node-user)
            NODE_USER=$VALUE
            ;;
        --node-key)
            NODE_KEY=$VALUE
            ;;
        --node-password)
            NODE_PASSWORD=$VALUE
            ;;
        --cm-host)
            CM_HOST=$VALUE
            ;;
        --cm-port)
            CM_PORT=$VALUE
            ;;
        --cm-user)
            CM_USER=$VALUE
            ;;
        --cm-password)
            CM_PASSWORD=$VALUE
            ;;   
        --debug)
            DEBUG=$VALUE
            ;;
        --log-dir)
            LOG_DIR=$VALUE
            ;;
        *)
            ;;
    esac
    shift
done

# Print Env variables
if [ "${DEBUG}" = "true" ]
then
    echo ""
    echo "****************************** ENV VARIABLES ******************************"
    env | sort 
    echo "***************************************************************************"
    echo ""
fi

# To ensure log dirs exists 
mkdir -p ${LOG_DIR}/

export ANSIBLE_LINES_NUMBER=4
export HOSTS_FILE=$(mktemp)

echo "############ Setup of files to interact with cluster  ############"

echo "
[cloudera_manager]
${CM_HOST}
" >> ${HOSTS_FILE}

echo "
[main]
${CM_HOST}
" >> ${HOSTS_FILE}

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

echo "############ Check and Heal cluster ############"
if [ "${DEBUG}" = "true" ]
then
    echo " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/restart_paused_cluster/main.yml --extra-vars \"@/tmp/restart_paused_cluster_extra_vars.yml\" "
fi
cp playbooks/restart_paused_cluster/extra_vars.yml /tmp/restart_paused_cluster_extra_vars.yml
envsubst < /tmp/restart_paused_cluster_extra_vars.yml > /tmp/restart_paused_cluster_extra_vars.yml.tmp && mv /tmp/restart_paused_cluster_extra_vars.yml.tmp /tmp/restart_paused_cluster_extra_vars.yml
echo " Follow progression in: ${LOG_DIR}/restart_paused_cluster.log "
ansible-playbook -i ${HOSTS_FILE} playbooks/restart_paused_cluster/main.yml --extra-vars "@/tmp/restart_paused_cluster_extra_vars.yml" > ${LOG_DIR}/restart_paused_cluster.log 2>&1
OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} ${LOG_DIR}/restart_paused_cluster.log | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
if [ "${OUTPUT}" == "2" ]
then
  echo " SUCCESS: Checked and Healed cluster "
else
  echo " FAILURE: Could not check and heal cluster " 
  echo " See details in file: ${LOG_DIR}/restart_paused_cluster.log "
  exit 1
fi

echo "############ Finished to unpause cluster ############"