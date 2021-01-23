FROM alpine:3.13.0 as base
ARG VERSION=4.0.0
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    git=2.30.0-r0 \
    npm=14.15.4-r0 && \
  npm install -g bower && \
  git clone -b ${VERSION} https://github.com/xwiki-labs/cryptpad.git /app
WORKDIR /app
RUN \
  mkdir blob block customize data datastore && \
  sed -i "s@//httpAddress: '::'@httpAddress: '0.0.0.0'@" /app/config/config.example.js && \
  npm i --production && \
  bower install --allow-root

FROM ghcr.io/linuxserver/baseimage-alpine:3.13
ARG BUILD_DATE
ARG VERSION=4.0.0
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
