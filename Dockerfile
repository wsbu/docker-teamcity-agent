FROM wsbu/toolchain-native:v0.1.4

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        unzip \
        openjdk-8-jre
RUN systemctl disable docker

ENV TC_AGENT_HOME="/opt/buildAgent"
RUN wget --quiet -O /tmp/buildAgent.zip https://ci.redlion.net/update/buildAgent.zip && \
    mkdir /opt/buildAgent && \
    pushd /opt/buildAgent && \
    unzip /tmp/buildAgent.zip && \
    popd && \
    rm /tmp/buildAgent.zip && \
    rm -r "${TC_AGENT_HOME}/conf"

COPY start-agent.sh "/start-agent.sh"
COPY watch-agent.py "/watch-agent.py"
RUN chmod +x "/start-agent.sh" && \
    chmod +x "/watch-agent.py"
ENTRYPOINT ["/start-agent.sh"]
