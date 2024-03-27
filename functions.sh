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

# Print a spin
# 
# Usage:
#   spin
#   ....
#   end_spin
sp="/-\|"
sc=0
spin() {
    printf "\b${sp:sc++:1}"
    ((sc==${#sp})) && sc=0
}
end_spin() {
   printf "\r%s\n" "$@"
}

# Print a progress bar like that :
#   Progress : [########################################] 100%
# 
# Usage:
#   progress_bar <progress> <max_progress>
function progress_bar {
    if [ $1 -le $2 ]; then
        let _progress=(${1}*100/${2}*100)/100
    else
        let _one=($2 - 1)
        let _progress=(${_one}*100/${2}*100)/100
    fi
    let _done=(${_progress}*4)/10
    let _left=40-$_done

    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
                   
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}

# Launch a playbook with retries, timeouts and prints its progress, and check if it succeeds or not
#
# Usage:
#   launch_playbook <playbook_name> "Success Message" "Error Message" <Expected_time_to_complete (Set it to 0, to print a spin instead of a progress bar)> <Timeout> <Number of retries> <true or false if it ahs to be launched remotely>
# 
function launch_playbook() {
    local playbook=$1
    local success_message=$2
    local error_message=$3
    local expected_time=$4
    local command_timeout=$5
    local retry=$6
    local remote_launch=$7

    local launch_tried=0
    local launch_failed=true
    local launch_timeout=false

    while [ $launch_tried -le $retry ] ; do
        if [ $launch_tried -gt 0 ]; then
            logger info "Launching a retry because installation failed, retry is : #bold:$launch_tried out of $FREE_IPA_TRIES#end_bold possible tries" 
        fi

        if [ "${DEBUG}" = "true" ]
        then
            if [ "$remote_launch" = "true" ] ; then
                logger debug " Command launched on remote node: ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml ${playbook}.yml ${ANSIBLE_PYTHON_3_PARAMS} "
            else 
                logger debug " Command launched: ansible-playbook -i ${HOSTS_FILE} playbooks/${playbook}/main.yml --extra-vars \"@/tmp/${playbook}_extra_vars.yml\" ${ANSIBLE_PYTHON_3_PARAMS} "
            fi
        fi

        if [ "$remote_launch" = "true" ] ; then
            log_file="${LOG_DIR}/deployment.log"
            logger info " Follow progression in: #underline:$log_file "
            ssh ${NODE_USER}@${NODE_0} "cd ~/deployment/ansible-repo/ ; ansible-playbook -i hosts --extra-vars @environment/extra_vars.yml ${playbook}.yml ${ANSIBLE_PYTHON_3_PARAMS}" >> $log_file 2>&1 &
        else
            log_file="${LOG_DIR}/${playbook}.log"
            cp playbooks/${playbook}/extra_vars.yml /tmp/${playbook}_extra_vars.yml
            envsubst < /tmp/${playbook}_extra_vars.yml > /tmp/${playbook}_extra_vars.yml.tmp && mv /tmp/${playbook}_extra_vars.yml.tmp /tmp/${playbook}_extra_vars.yml
            logger info " Follow progression in: #underline:$log_file "
            ansible-playbook -i ${HOSTS_FILE} playbooks/${playbook}/main.yml --extra-vars "@/tmp/${playbook}_extra_vars.yml" ${ANSIBLE_PYTHON_3_PARAMS} > $log_file 2>&1 &
        fi

        local pid=$!
        local start=$SECONDS

        if [ "${DEBUG}" = "true" ]
        then
            logger debug "pid is: $pid"
        fi
        
        local duration=$(( SECONDS - start ))
        while [ $duration -lt $command_timeout ] ; do
            if [ $(ps -p $pid | wc -l) -eq 1 ] ; then
                break
            fi
            if [ $expected_time -gt 0 ] ; then
                progress_bar $duration $expected_time 
            else 
                spin
            fi
            sleep 0.5
            duration=$(( SECONDS - start ))
        done
        if [ $expected_time -gt 0 ] ; then
            end_spin
        fi
        if [ $duration -gt $command_timeout ] ; then
            launch_timeout=true
        fi

        OUTPUT=$(tail -${ANSIBLE_LINES_NUMBER} $log_file | grep -A${ANSIBLE_LINES_NUMBER} RECAP | grep -v "failed=0" | wc -l | xargs)
        if [ "${OUTPUT}" == "2" ] && [ $launch_timeout = "false" ]
        then
          logger success "$success_message"
          logger info ""
          launch_failed=false
          break
        else
          logger warn " $error_message " 
          if [ "${DEBUG}" = "true" ]
          then
            logger debug "Will kill process with pid: $pid"
          fi  
          kill -9 $pid 2>&1 > /dev/null        
        fi
        launch_tried=$((launch_tried + 1))
        # Not elegant but only workaround as of now for postgresql on RHEL 8
        if [ "$launch_timeout" = true ] && [ "$playbook" = "create_infrastructure" ] ; then
            ssh ${NODE_USER}@${NODE_0} "systemctl enable postresql-14"
        fi
    done
    if [ "${launch_failed}" == "true" ]
    then
        logger error "$error_message"
        logger error " See details in file: #underline:$log_file "
        exit 1 
    fi
    
}