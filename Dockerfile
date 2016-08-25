# **** reefminder docker image **** #
# 1) Build the Dockerfile
# 2) docker login
# 3) docker build -t telbot/reefminder .
# 4) docker images (get Image ID of latest)
# 5) docker tag <Image ID> telbot/reefminder:v0.2
# 6) docker push telbot/reefminder

FROM       ubuntu:latest
MAINTAINER David Bingham <david.r.bingham@gmail.com>

WORKDIR /data

# **** Install Common Tools **** #

RUN apt-get update
RUN apt-get -y install \
bzip2 unzip openssh-client git curl wget \
expect build-essential

# **** Install openjdk 8 **** #

RUN apt-get update && apt-get install -y openjdk-8-jdk

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# **** Install mongodb **** #

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN apt-get update && apt-get install -y mongodb-org
RUN mkdir -p /data/db

# **** Install node.js **** #

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.4.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

# **** Install Python **** #

RUN \
  apt-get update && \
  apt-get install -y python python-dev python-pip python-virtualenv && \
  rm -rf /var/lib/apt/lists/*

# **** Install Gradle **** #

RUN wget https://services.gradle.org/distributions/gradle-3.0-bin.zip
RUN unzip gradle-3.0-bin.zip
RUN mv gradle-3.0 /opt/
RUN rm gradle-3.0-bin.zip

# **** Finalize **** #

CMD ["bash","node"]