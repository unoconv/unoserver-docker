FROM alpine:3.18.5

ARG BUILD_CONTEXT="build-context"
ARG UID=worker
ARG GID=worker

LABEL org.opencontainers.image.title="unoserver-docker"
LABEL org.opencontainers.image.description="Custom Docker Image that contains unoserver, LibreOffice and major set of fonts for file format conversions"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/unoconv/unoserver-docker/blob/master/README.md"
LABEL org.opencontainers.image.source="https://github.com/unoconv/unoserver-docker"
LABEL org.opencontainers.image.url="https://github.com/unoconv/unoserver-docker"

WORKDIR /

RUN addgroup -S ${GID} && adduser -S ${UID} -G ${GID}

RUN apk add --no-cache \
    bash curl \
    py3-pip \
    libreoffice \
    supervisor

# fonts - https://wiki.alpinelinux.org/wiki/Fonts
RUN apk add --no-cache \
    font-noto font-noto-cjk font-noto-extra \
    terminus-font \
    ttf-font-awesome \
    ttf-dejavu \
    ttf-freefont \
    ttf-hack \
    ttf-inconsolata \
    ttf-liberation \
    ttf-mononoki  \
    ttf-opensans   \
    fontconfig && \
    fc-cache -f

RUN rm $(which wget) && \
    rm -rf /var/cache/apk/* /tmp/*

# renovate: datasource=repology depName=temurin-17-jdk versioning=loose
ARG VERSION_ADOPTIUM_TEMURIN="17.0.7_p7-r0"

# install Eclipse Temurin JDK
RUN curl https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk -o /etc/apk/keys/adoptium.rsa.pub && \
    echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >> /etc/apk/repositories && \
    apk update && apk add temurin-17-jdk=${VERSION_ADOPTIUM_TEMURIN}

# https://github.com/unoconv/unoserver/
RUN pip install -U unoserver

# setup supervisor
COPY --chown=${UID}:${GID} ${BUILD_CONTEXT}/supervisor /
RUN chmod +x /config/entrypoint.sh && \
#    mkdir -p /var/log/supervisor && \
#    chown ${UID}:${GID} /var/log/supervisor && \
#    mkdir -p /var/run && \
    chown -R ${UID}:0 /run && \
    chmod -R g=u /run

USER ${UID}
WORKDIR /home/worker
ENV HOME="/home/worker"

VOLUME ["/data"]

ENTRYPOINT ["/config/entrypoint.sh"]