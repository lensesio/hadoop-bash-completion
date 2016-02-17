#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Provides tab completion for the main hadoop script.
#
# On debian-based systems, place in /etc/bash_completion.d/ and either restart
# Bash or source the script manually (. /etc/bash_completion.d/hadoop.sh).

_complete_path() {
    STERM="$1"
    $2 fs -ls -d "${STERM}*" 2>/dev/null | grep -vE "^Found.*items" | sed -r -e 's/^(d.*)/\1\//' -e 's/.*[0-9:]{5,5} //'
}

_hadoop() {
    local script cur prev temp

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    script=${COMP_WORDS[0]}

    # Bash lets you tab complete things even if the script doesn't
    # exist (or isn't executable). Check to make sure it is, as we
    # need to execute it to get options/info
    case $COMP_CWORD in
        1)
            # Completing the first argument (the command).
            temp=`$script | grep -n "^\s*or"`;
            temp=`$script | head -n $((${temp%%:*} - 1)) | awk '/^ / {print $1}' | sort | uniq`;
            COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
            return 0;;

        2)
            # Completing the second arg (first arg to the command)
            # The output of commands isn't hugely consistent, so certain
            # names are hardcoded and parsed differently. Some aren't
            # handled at all (mostly ones without args).
            case ${COMP_WORDS[1]} in
                dfs | dfsadmin | fs | job | pipes | mradmin)
                    # One option per line, enclosed in square brackets
                    temp=`$script ${COMP_WORDS[1]} 2>&1 | awk '/^[ \t]*\[/ {gsub(/[\[\]]/, ""); print $1}'`;
                    COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
                    return 0;;

                jar)
                    # Any (jar) file

                    COMPREPLY=(`compgen -A file -- ${cur}`);
                    return 0;;

                namenode | jobtracker)
                    # All options specified in the Usage line from "haooop namenode --help"
                    # enclosed in [] and separated with |
                    temp=`$script ${COMP_WORDS[1]} --help 2>&1 | grep -i "Usage:" | cut -d '[' -f 2- | awk '{gsub(/[\[\] \t\|]/, " "); print}'`;
                    COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
                    return 0;;

                datanode)
                    # All options specified in the Usage line from "hadoop datanode --help"
                    # note that the options are provided on a separate new line
                    temp=`$script ${COMP_WORDS[1]} --help 2>&1 | awk '/Usage:/ {getline; gsub(/[\[\]]/, ""); print}'`;
                    COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
                    return 0;;

                fsck)
                    temp=`$script ${COMP_WORDS[1]} 2>&1 | grep -i "Usage:" | cut -d '>' -f 2 | awk '{gsub(/[\[\]\|]/, ""); print}'`;
                    COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
                    return 0;;

                balancer)
                    temp=`$script ${COMP_WORDS[1]} --help 2>&1 | awk '/Usage:/ {getline; gsub(/[\[\]]/, ""); gsub(/<.*/, ""); print}'`;
                    COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
                    return 0;;

                fetchdt)
        temp=`$script ${COMP_WORDS[1]} 2>&1 | awk '/\s*-{2}/ {print $1}'`;
        COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
        return 0;;

                pipes | job | queue)
                    temp=`$script ${COMP_WORDS[1]} 2>&1 | awk '/\s*\[-/ {gsub(/\[/, ""); print $1}'`;
                    COMPREPLY=(`compgen -W "${temp}" -- ${cur}`);
                    return 0;;

                *)
                    # Other commands - no idea
                    return 1;;
            esac;;

        *)
            # Completing the third, fourth, etc arg.
            # We complete it only for commands that take HDFS paths
            # as their arguments.
            case ${COMP_WORDS[1]} in
                dfs | dfsadmin | fs | job | pipes | mradmin)
                    # One option per line, enclosed in square brackets
                    temp=`_complete_path "${cur}" "${script}"`;
                    COMPREPLY=(`compgen -o filenames -W "${temp}" -- ${cur}`);
                    compopt -o nospace -o filenames
                    return 0;;

                *)
                    return 1;;
            esac;;

    esac;
}

complete -F _hadoop hadoop
