FROM ghcr.io/linuxserver/baseimage-alpine:3.15 as base
ARG VERSION
ARG CHECKSUM
WORKDIR /tmp
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    wget=1.21.2-r2 \
    git=2.34.1-r0 \
    npm=8.1.3-r0 && \
  echo "**** download cryptpad ****" && \
  wget -q -O "${VERSION}.tar.gz" "https://github.com/xwiki-labs/cryptpad/archive/${VERSION}.tar.gz" && \
  echo "${CHECKSUM}  ${VERSION}.tar.gz" | sha256sum -c && \
  # mkdir /app && \
  tar -xvf ${VERSION}.tar.gz --strip-components=1 -C /app
WORKDIR /app
RUN \
  echo "**** build cryptpad ****" && \
  npm install -g bower && \
  mkdir blob block customize data datastore && \
  sed -i "s@//httpAddress: '::'@httpAddress: '0.0.0.0'@" /app/config/config.example.js && \
  sed -i "s@installMethod: 'unspecified'@installMethod: 'nicholaswilde/docker-cryptpad'@" /app/config/config.example.js && \
  npm i --production && \
  bower install --allow-root && \
  npm install cryptpad-sql-store

FROM ghcr.io/linuxserver/baseimage-alpine:3.15
ARG BUILD_DATE
ARG VERSION
WORKDIR /
# hadolint ignore=DL3048
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nicholaswilde"
RUN \
  echo "**** install packages ****" && \
    apk add --no-cache \
      nodejs=16.14.0-r0 && \
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
