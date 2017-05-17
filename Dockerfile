FROM cloudron/base:0.10.0
MAINTAINER Shane Perry <sperry@devfoundry.org>

ENV SYNCTHING_VERSION 0.14.28

RUN apt-get update \
  && apt-get upgrade -y --no-install-recommends \
  && apt-get install curl ca-certificates -y --no-install-recommends \
  && apt-get autoremove -y \
  && apt-get clean

# grab gosu for easy step-down from root
RUN gpg --keyserver pgp.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -L "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

# get syncthing
WORKDIR /app/code
RUN useradd --no-create-home -g users syncthing
RUN curl -L -o syncthing.tar.gz https://github.com/syncthing/syncthing/releases/download/v$SYNCTHING_VERSION/syncthing-linux-amd64-v$SYNCTHING_VERSION.tar.gz \
  && tar -xzvf syncthing.tar.gz \
  && rm -f syncthing.tar.gz \
  && mv syncthing-linux-amd64-v* syncthing \
  && rm -rf syncthing/etc \
  && rm -rf syncthing/*.pdf \
  && mkdir -p /app/config \
  && mkdir -p /app/data \
  && mkdir -p /app/code

VOLUME ["/apd/data", "/app/config"]

ADD /app/code/start.sh /app/code/start.sh
RUN chmod 770 /app/code/start.sh

ENV UID=1027
# make cloudron exec sane 
WORKDIR /app/data 
