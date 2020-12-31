FROM alpine:3.12.1 as base
ARG TARGETARCH
ARG BUILDPLATFORM
ARG VERSION=3.25.0
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    git=2.26.2-r0 \
    npm=12.18.4-r0 && \
  npm install -g bower && \
  git clone -b ${VERSION} https://github.com/xwiki-labs/cryptpad.git /app
WORKDIR /app
RUN \
  mkdir blob block customize data datastore && \
  sed -i "s@//httpAddress: '::'@httpAddress: '0.0.0.0'@" /app/config/config.example.js && \
  npm i --production && \
  bower install --allow-root
COPY entrypoint.sh /app/entrypoint.sh

FROM alpine:3.12.1
ARG TARGETARCH
ARG BUILDPLATFORM
ARG PUID=1000
ARG PGID=1000
ARG TZ=America/Los_Angeles
ENV TZ ${TZ}
RUN \
  echo "**** install packages ****" && \
    apk add --no-cache \
      tzdata=2020c-r1 \
      nodejs=12.18.4-r0 && \
  echo "**** cleanup ****" && \
    rm -rf /tmp/* /var/cache/apk/* && \
  echo "**** add user ****" && \
    addgroup -S cryptpad --gid ${PGID} && \
    adduser -S cryptpad --uid ${PUID} -G cryptpad && \
  echo "**** change timezone ****" && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=base --chown=cryptpad:cryptpad /app /
USER cryptpad
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
