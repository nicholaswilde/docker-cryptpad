FROM alpine:3.13.1 as base
ARG VERSION=4.1.0
ARG CHECKSUM=1b5ad7536532e504108bbdceb9c53c8ae116a7cd74185d9cbad0ee7929d423e2
WORKDIR /tmp
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    wget=1.21.1-r1 \
    git \
    npm=14.15.4-r0 && \
  wget -q -O "${VERSION}.tar.gz" "https://github.com/xwiki-labs/cryptpad/archive/${VERSION}.tar.gz" && \
  echo "${CHECKSUM}  ${VERSION}.tar.gz" | sha256sum -c && \
  mkdir /app && \
  tar -xvf ${VERSION}.tar.gz --strip-components=1 -C /app
WORKDIR /app
RUN \
  npm install -g bower && \
  mkdir blob block customize data datastore && \
  sed -i "s@//httpAddress: '::'@httpAddress: '0.0.0.0'@" /app/config/config.example.js && \
  npm i --production && \
  bower install --allow-root

FROM ghcr.io/linuxserver/baseimage-alpine:3.13
ARG BUILD_DATE
ARG VERSION=4.1.0
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nicholaswilde"
RUN \
  echo "**** install packages ****" && \
    apk add --no-cache \
      nodejs=14.15.4-r0 && \
  echo "**** cleanup ****" && \
    rm -rf /tmp/* /var/cache/apk/*
COPY --from=base --chown=abc:abc /app /
WORKDIR /
VOLUME \
  /blob \
  /block \
  /customize \
  /data \
  /datastore \
  /config
EXPOSE 3000 3001
CMD ["node", "server.js"]
