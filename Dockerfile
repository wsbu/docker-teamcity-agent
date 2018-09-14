FROM wsbu/toolchain-native:v0.2.6

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        unzip \
        openjdk-8-jre \
        git-core \
        vim \
        python3-pip
RUN usermod -a -G docker captain

# Because we're running this after setting $HOME, we need to run with `sudo -H`
RUN sudo -H pip3 install \
    boto3 \
    xmltodict \
    paramiko

ENV TC_AGENT_HOME="/opt/buildAgent"
RUN wget --quiet -O /tmp/buildAgent.zip https://ci.redlion.net/update/buildAgent.zip && \
    mkdir /opt/buildAgent && \
    pushd /opt/buildAgent && \
    unzip /tmp/buildAgent.zip && \
    popd && \
    rm /tmp/buildAgent.zip && \
    rm -r "${TC_AGENT_HOME}/conf" && \
    chown 1000:1000 "${TC_AGENT_HOME}" --recursive

RUN sudo wget --quiet -O /usr/local/bin/docker-compose \
        https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)  && \
    sudo chmod +x /usr/local/bin/docker-compose

COPY start-agent.sh "/start-agent.sh"
COPY watch-agent.py "/watch-agent.py"
RUN chmod +x "/start-agent.sh" && \
    chmod +x "/watch-agent.py"
ENTRYPOINT ["/start-agent.sh"]
