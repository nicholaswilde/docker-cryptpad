FROM alpine:3.12.3 as base
ARG TARGETARCH
ARG BUILDPLATFORM
ARG VERSION=3.25.1
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    git=2.26.2-r0 \
    npm=12.20.1-r0 && \
  npm install -g bower && \
  git clone -b ${VERSION} https://github.com/xwiki-labs/cryptpad.git /app
WORKDIR /app
RUN \
  mkdir blob block customize data datastore && \
  sed -i "s@//httpAddress: '::'@httpAddress: '0.0.0.0'@" /app/config/config.example.js && \
  npm i --production && \
  bower install --allow-root
COPY entrypoint.sh /app/entrypoint.sh

FROM ghcr.io/linuxserver/baseimage-alpine:3.12-version-8692b0a0
ARG TZ=Americal/Los_Angeles
ENV TZ=$(TZ)
RUN \
  echo "**** install packages ****" && \
    apk add --no-cache \
      tzdata=2020f-r0 \
      nodejs=12.20.1-r0 && \
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
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "server.js"]
