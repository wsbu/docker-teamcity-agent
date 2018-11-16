#!/bin/bash

# Verify required environment variables
if [[ -z ${uid+x} ]] ; then
    echo "uid environment variable is not set!"
    exit 1
fi
if [[ -z ${gid+x} ]] ; then
    echo "gid environment variable is not set!"
    exit 2
fi
if [[ -z ${TC_AGENT_HOME+x} ]] ; then
    echo "TC_AGENT_HOME environment variable is not set!"
    exit 3
fi

# Make Docker usable
dockerOnHostGid=$(stat -c '%g' /var/run/docker.sock)
dockerInContainerGid=$(getent group docker | cut -d: -f3)
if [[ "${dockerOnHostGid}" != "${dockerInContainerGid}" ]] ; then
    groupadd -g ${dockerOnHostGid} dockerOnHost
    usermod -a -G dockerOnHost captain
fi

# Download & install the TeamCity agent if it isn't already installed
if [[ ! -e "${TC_AGENT_HOME}/bin/start.sh" ]]; then
    wget --quiet -O /tmp/buildAgent.zip https://ci.redlion.net/update/buildAgent.zip
    pushd "${TC_AGENT_HOME}"
    sudo --user "#${uid}" --group "#${gid}" unzip -n /tmp/buildAgent.zip
    popd
    rm /tmp/buildAgent.zip
fi

conf_dir="${TC_AGENT_HOME}/conf"
if [[ ! -f "${conf_dir}/buildAgent.properties" ]] ; then
    echo "First-time startup detected. Copying from default configuration file."
    cp "${conf_dir}/buildAgent.dist.properties" "${conf_dir}/buildAgent.properties"
    chown ${uid}:${gid} "${conf_dir}/buildAgent.properties"
fi

if [[ ! -e "/var/run/docker.sock" ]] ; then
    echo "Missing Docker socket! Did you forget to mount /var/run/docker.sock?"
    exit 4
fi

chown "${uid}:${gid}" "${HOME}/.conan/data"

# New Conan fails miserably if the JSON file is completely empty
registry_size=$(stat --printf="%s" ${HOME}/.conan/registry.json)
if [[ "0" == "${registry_size}" ]] ; then
    echo -n '{"remotes": [], "references": {}, "package_references": {}}' >> "${HOME}/.conan/registry.json"
fi

# Ensure Conan is using the correct remotes (RL-specific remotes will be added by CI server)
# Invoking all this via /start.sh is necessary so that we don't run as root
remotes=$("/start.sh" conan remote list --raw | cut -d' ' -f2)
if [[ ! "${remotes}" =~ .*'https://conan.bintray.com'.* ]] ; then
    "/start.sh" conan remote add conan-center 'https://conan.bintray.com'
fi
if [[ ! "${remotes}" =~ .*'https://api.bintray.com/conan/conan-community/conan'.* ]] ; then
    "/start.sh" conan remote add bintray-community 'https://api.bintray.com/conan/conan-community/conan'
fi

if (( $# == 0 )); then
    set -e
	"/start.sh" "${TC_AGENT_HOME}/bin/agent.sh" "start"
    "/watch-agent.py" "${TC_AGENT_HOME}/logs/teamcity-agent.log" "${TC_AGENT_HOME}/bin/agent.sh"
else
    set -e
	"/start.sh"
fi
