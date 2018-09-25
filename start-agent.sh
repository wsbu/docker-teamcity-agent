#!/bin/bash

# Make sure the agent home, log, work, and temp directories are accessible
if [ "${uid}" != "1000" -o "${gid}" != "1000" ] ; then
    echo "Agent must be run as UID 1000 with GID 1000!"
    exit 3
fi

conf_dir="${TC_AGENT_HOME}/conf"
if [ ! -f "${conf_dir}/buildAgent.properties" ] ; then
    echo "First-time startup detected. Copying from default configuration file."
    cp "${conf_dir}/buildAgent.dist.properties" "${conf_dir}/buildAgent.properties"
fi

chown "${uid}:${gid}" "${TC_AGENT_HOME}/work"
chown "${uid}:${gid}" "${TC_AGENT_HOME}/logs"
chown "${uid}:${gid}" "${HOME}/.conan/data"

mkdir -p "${TC_AGENT_HOME}/temp"

rm -rf "/var/run/docker.pid"
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
