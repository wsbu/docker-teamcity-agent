#!/bin/bash

conf_file="${TC_AGENT_HOME}/conf/buildAgent.properties"
if [ ! -f "${conf_file}" ] ; then
    echo "Could not find ${conf_file}. Did you mount a volume with the configuration directory?"
    exit 1
fi

work_dir="${TC_AGENT_HOME}/work"
if [ ! -d "${work_dir}" ] ; then
    echo "Agent's work directory does not exist. Did you mount a volume for the work directory?"
    exit 2
fi

docker_socket="/var/run/docker.sock"
if [ ! -f "${docker_socket}" ] ; then
    echo "Could not find ${docker_socket}. Did you mount the docker socket from the host?"
    exit 3
fi

if (( $# == 0 )); then
	"/start.sh" "${TC_AGENT_HOME}/bin/agent.sh"
    tail -F "${TC_AGENT_HOME}/logs/teamcity-agent.log"
else
    set -e
	"/start.sh"
fi
