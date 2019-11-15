FROM wsbu/toolchain-native:v0.3.8

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        expect \
        unzip \
        openjdk-8-jre-headless \
        git-core \
        vim \
        valgrind

RUN usermod -a -G docker captain

# Because we're running this after setting $HOME, we need to run with `sudo -H`
RUN sudo -H pip3 install \
    boto3 \
    xmltodict \
    paramiko \
    conan_package_tools \
    teamcity-messages

RUN sudo wget --quiet -O /usr/local/bin/docker-compose \
        https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)  && \
    sudo chmod +x /usr/local/bin/docker-compose

COPY start-agent.sh "/start-agent.sh"
COPY watch-agent.py "/watch-agent.py"
RUN chmod +x "/start-agent.sh" && \
    chmod +x "/watch-agent.py"
ENTRYPOINT ["/start-agent.sh"]
