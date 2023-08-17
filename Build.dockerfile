FROM ubuntu:22.04

ARG NODE_VERSION=16
ARG NPM_VERSION=9.6

RUN apt-get update && apt-get install -y curl \
    && curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" \
     | bash - \
    && apt-get install -y nodejs \
    && npm install -g "npm@${NPM_VERSION}"

RUN apt-get update && apt-get install -y \
    build-essential

COPY vendor/open-lens /src
WORKDIR /src
RUN npm install

ADD build.sh /src/build.sh
ENTRYPOINT ["/src/build.sh"]
