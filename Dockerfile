FROM alpine:3.13.5 as base
ARG VERSION
ARG CHECKSUM
WORKDIR /tmp
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    wget=1.21.1-r1 \
    git=2.30.2-r0 \
    npm=14.16.1-r1 && \
  echo "**** download cryptpad ****" && \
  wget -q -O "${VERSION}.tar.gz" "https://github.com/xwiki-labs/cryptpad/archive/${VERSION}.tar.gz" && \
  echo "${CHECKSUM}  ${VERSION}.tar.gz" | sha256sum -c && \
  mkdir /app && \
  tar -xvf ${VERSION}.tar.gz --strip-components=1 -C /app
WORKDIR /app
RUN \
  echo "**** build cryptpad ****" && \
  npm install -g bower && \
  mkdir blob block customize data datastore && \
  sed -i "s@//httpAddress: '::'@httpAddress: '0.0.0.0'@" /app/config/config.example.js && \
  npm i --production && \
  bower install --allow-root && \
  npm install cryptpad-sql-store

FROM ghcr.io/linuxserver/baseimage-alpine:3.13
ARG BUILD_DATE
ARG VERSION
WORKDIR /
# hadolint ignore=DL3048
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nicholaswilde"
RUN \
  echo "**** install packages ****" && \
    apk add --no-cache \
      nodejs=14.16.1-r1 && \
  echo "**** cleanup ****" && \
    rm -rf /tmp/* /var/cache/apk/*
COPY --from=base --chown=abc:abc /app /
COPY root/ .
WORKDIR /
VOLUME \
  /blob \
  /block \
  /customize \
  /data \
  /datastore \
  /config
EXPOSE \
  3000 \
  3001
