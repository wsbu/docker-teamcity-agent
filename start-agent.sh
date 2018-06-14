#!/bin/bash

conf_dir="${TC_AGENT_HOME}/conf"
if [ ! -d "${conf_dir}" ] ; then
    echo "Could not find ${conf_dir}. Did you mount a volume with the configuration directory?"
    exit 1
else
    if [ ! -f "${conf_dir}/buildAgent.properties" ] ; then
        echo "First-time startup detected. Copying from default configuration file."
        cp "${conf_dir}/buildAgent.dist.properties" "${conf_dir}/buildAgent.properties"
    fi
fi

work_dir="${TC_AGENT_HOME}/work"
if [ ! -d "${work_dir}" ] ; then
    echo "Agent's work directory does not exist. Did you mount a volume for the work directory?"
    exit 2
fi

set -e
service docker start
set +e

if (( $# == 0 )); then
    set -e
	"/start.sh" "${TC_AGENT_HOME}/bin/agent.sh" "start"
    "/watch-agent.py" "${TC_AGENT_HOME}/logs/teamcity-agent.log" "${TC_AGENT_HOME}/bin/agent.sh"
else
    set -e
	"/start.sh"
fi
