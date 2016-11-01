FROM ubuntu:xenial
MAINTAINER Austin Burdine <acburdine@gmail.com>

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        apt-utils \
        ca-certificates \
        build-essential \
        libssl-dev \
        curl \
        wget \
        vim \
        git;

# Add Ghost user
RUN useradd --home /home/ghost -m -U -s /bin/bash ghost;

# Run everything after this as the ghost user
USER ghost

# Latest Node Argon LTS release
ENV NODE_VERSION 4.6.1
ENV NVM_DIR /home/ghost/.nvm
ENV GHOST_URL http://localhost:2368/

ADD ./vendor/ /home/ghost/vendor/

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && npm install -g ghost-cli \
    && echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" # This loads nvm" >> ~/.profile \
    && mkdir /home/ghost/app && cd /home/ghost/app \
    && ghost install --dir $HOME/app --no-setup \
    && ghost config --url $GHOST_URL --db mysql --dbhost mysql --dbuser root --dbpass ghost_docker --dbname ghost;
    
WORKDIR /home/ghost/app/
EXPOSE 2368
CMD . ~/.profile && ghost start > /var/log/ghost/ghost.log