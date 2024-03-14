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

########## Logger for fine shell print ##########@
# Load this file into your script with . ./logger.sh
# Then use it instead of echo like this:
#
#       logger info "Beginning of my application"
#
# See more examples at the end of this file

LOG_PRINT_DATE=true
LOG_PRINT_COLORS=true
if [ "$(tput colors)" = 256 ]; then 
    LOG_TPUT_AVAILABLE=true
else 
    LOG_TPUT_AVAILABLE=false 
fi
LOG_TEST=$1

### Colors for the shell ####
bold=$(tput bold)
underline=$(tput smul)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)

# How to use it ?
#
# Argument 1: level among: debug, info, warn, error, success 
#              And optionally a specific color comprehensible by tput
#   Example:   To log an error (will be in red): red
#              To specify a specific color: info:white  
#                   possible colors: blue, white, cyan, magenta, red, green, yellow
#
# Argument 2: Text to print (where you can specify some part to be bold or underlined)
#
#   Example: Add a word to be in bold: "this word is #bold WordInBold #end_bold but not this one"
#            Add a word to be in underline: "this word is #underline WordUnderlined #end_underline but not this one"
#
function logger() {
    level_and_colors=$1
    unformatted_text=$2

    level_to_echo=$(echo $level_and_colors | cut -d ':' -f 1 | tr '[:lower:]' '[:upper:]')
    color_name=$(echo $level_and_colors | cut -d ':' -f 2 | tr '[:upper:]' '[:lower:]')
    
    check_color_from_level=true
    case $color_name in
        blue|white|cyan|magenta|red|green|yellow)
            check_color_from_level=false
        ;;
    esac

    if [ "${LOG_TPUT_AVAILABLE}" == "true" ] ; then

        if [ "$check_color_from_level" == "true" ] ; then
            case "$level_to_echo" in
                "INFO"|"DEBUG")
                    color_name="normal"
                ;;
                "WARN")
                    color_name="yellow"
                ;;
                "ERROR")
                    color_name="red"
                ;;
                "SUCCESS")
                    color_name="green"
                ;;
            esac
        fi

        color_to_echo=$normal   
        case "$color_name" in
            "red")
                color_to_echo=$red
            ;;
            "green")
                color_to_echo=$green
            ;;
            "yellow")
                color_to_echo=$yellow
            ;;
            "blue")
                color_to_echo=$blue
            ;;
            "magenta")
                color_to_echo=$magenta
            ;;
            "cyan")
                color_to_echo=$cyan
            ;;
            "white")
                color_to_echo=$white
            ;;
        esac

    fi

    date_to_echo=$(date +%d/%m/%Y-%T)

    text_with_bold=$(echo $unformatted_text | sed "s/\#bold\:/${bold}/g" | sed "s/\#end_bold/${normal}${color_to_echo}/g")
    text_with_underline=$(echo $text_with_bold | sed "s/\#underline\:/${underline}/g" | sed "s/\#end_underline/${normal}${color_to_echo}/g")

    if [ "${LOG_TPUT_AVAILABLE}" == "true" ] ; then
        echo "$color_to_echo $date_to_echo - $level_to_echo : $text_with_underline $normal"
    else 
        echo "$date_to_echo - $level_to_echo : $text_with_underline"
    fi

}

function print_env_vars() {
    filename=/tmp/env_vars_$(date +%d_%m_%Y-%H_%M_%S)
    touch $filename
    env | sort > $filename
    logger info "For debug purposes, Environment Variables have been outputed to $filename"
}

if [ "$LOG_TEST" = true ] ; then
    logger info "This is an info"
    logger info:blue " This is a blue Info"
    logger warn "this is a warning"
    logger error "This is an error"
    logger info:cyan " This is an info in cyan with #bold:bold:#end_bold"
    logger info:magenta " This is an info in magenta with #underline:underlined string#end_underline"
    logger error:white " This is an Error in white with #underline:underlined string#end_underline and #bold:bold#end_bold"
fi
   