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
if [ -d "${work_dir}" ] ; then
    chown "${uid}:${gid}" "${work_dir}"
else
    echo "Agent's work directory (${work_dir}) does not exist. Did you mount a volume for the work directory?"
    exit 2
fi

logs_dir="${TC_AGENT_HOME}/logs"
if [ -d "${logs_dir}" ] ; then
    chown "${uid}:${gid}" "${logs_dir}"
else
    echo "Agent's logs directory (${logs_dir}) does not exist. Did you mount a volume for the logs directory?"
    exit 3
fi

conan_cache="/home/captain/.conan/data"
if [ -d "${conan_cache}" ] ; then
    chown "${uid}:${gid}" "${conan_cache}"
else
    echo "Conan cache directory (${conan_cache}) does not exist. Did you mount a volume for the Conan cache?"
    exit 4
fi

mkdir -p "${TC_AGENT_HOME}/temp"
# Make sure the agent home, log, work, and temp directories are accessible
if [ "${uid}" != "1000" -o "${gid}" != "1000" ] ; then
    echo "Agent must be run as UID 1000 with GID 1000!"
    exit 3
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
