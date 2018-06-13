#!/bin/bash

conf_dir="${TC_AGENT_HOME}/conf"
if [ ! -d "${conf_dir}" ] ; then
    echo "Could not find ${conf_dir}. Did you mount a volume with the configuration directory?"
    exit 1
fi

work_dir="${TC_AGENT_HOME}/work"
if [ ! -d "${work_dir}" ] ; then
    echo "Agent's work directory does not exist. Did you mount a volume for the work directory?"
    exit 2
fi

docker_socket="/var/run/docker.sock"
if [ ! -S "${docker_socket}" ] ; then
    echo "Could not find ${docker_socket}. Did you mount the docker socket from the host?"
    exit 3
fi

if (( $# == 0 )); then
    set -e
	"/start.sh" "${TC_AGENT_HOME}/bin/agent.sh" "start"
    "/watch-agent.py" "${TC_AGENT_HOME}/logs/teamcity-agent.log" "${TC_AGENT_HOME}/bin/agent.sh"
else
    set -e
	"/start.sh"
fi
