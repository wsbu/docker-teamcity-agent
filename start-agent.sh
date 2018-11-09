#!/bin/bash

# Make Docker usable
dockerOnHostGid=$(stat -c '%g' /var/run/docker.sock)
dockerInContainerGid=$(getent group docker | cut -d: -f3)
if [[ "${dockerOnHostGid}" != "${dockerInContainerGid}" ]] ; then
    groupadd -g ${dockerOnHostGid} dockerOnHost
    usermod -a -G dockerOnHost captain
fi

# Make sure the agent home, log, work, and temp directories are accessible
if [[ "${uid}" != "1000" || "${gid}" != "1000" ]] ; then
    echo "Agent must be run as UID 1000 with GID 1000!"
    exit 1
fi

conf_dir="${TC_AGENT_HOME}/conf"
if [[ ! -f "${conf_dir}/buildAgent.properties" ]] ; then
    echo "First-time startup detected. Copying from default configuration file."
    cp "${conf_dir}/buildAgent.dist.properties" "${conf_dir}/buildAgent.properties"
fi

if [[ ! -e "/var/run/docker.sock" ]] ; then
    echo "Missing Docker socket! Did you forget to mount /var/run/docker.sock?"
    exit 2
fi

chown "${uid}:${gid}" "${TC_AGENT_HOME}/logs"
chown "${uid}:${gid}" "${HOME}/.conan/data"

mkdir -p "${TC_AGENT_HOME}/temp"

if (( $# == 0 )); then
    set -e
	"/start.sh" "${TC_AGENT_HOME}/bin/agent.sh" "start"
    "/watch-agent.py" "${TC_AGENT_HOME}/logs/teamcity-agent.log" "${TC_AGENT_HOME}/bin/agent.sh"
else
    set -e
	"/start.sh"
fi
