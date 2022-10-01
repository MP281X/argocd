FROM summerwind/actions-runner:latest
RUN sudo apt update -y && sudo apt upgrade -y \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - \
    && sudo apt-get install -y nodejs