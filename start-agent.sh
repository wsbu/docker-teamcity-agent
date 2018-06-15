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

mkdir -p "${TC_AGENT_HOME}/temp"
# Make sure the agent home, log, work, and temp directories are accessible
if [ "${uid}" -a "${gid}" ] ; then
    chown "${uid}:${gid}" "${TC_AGENT_HOME}"
    chown "${uid}:${gid}" "${work_dir}"
    chown "${uid}:${gid}" "${TC_AGENT_HOME}/logs"
    chown "${uid}:${gid}" "${TC_AGENT_HOME}/temp"
fi

# Make sure some other directories are all properly owned (recursively)
for d in bin contrib launcher lib plugins ; do
    chown "${uid}:${gid}" "${TC_AGENT_HOME}/${d}" --recursive
done

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
