FROM wsbu/toolchain-native:v0.3.0

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        unzip \
        openjdk-8-jre \
        git-core \
        vim \
        python3-pip \
        valgrind

RUN usermod -a -G docker captain

# Because we're running this after setting $HOME, we need to run with `sudo -H`
RUN sudo -H pip3 install \
    boto3 \
    xmltodict \
    paramiko \
    conan==1.11.2 \
    conan_package_tools

RUN sudo wget --quiet -O /usr/local/bin/docker-compose \
        https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)  && \
    sudo chmod +x /usr/local/bin/docker-compose

COPY start-agent.sh "/start-agent.sh"
COPY watch-agent.py "/watch-agent.py"
RUN chmod +x "/start-agent.sh" && \
    chmod +x "/watch-agent.py"
ENTRYPOINT ["/start-agent.sh"]
