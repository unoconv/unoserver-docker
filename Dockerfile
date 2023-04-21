FROM alpine:3.17.3

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
ARG VERSION_ADOPTIUM_TEMURIN="17.0.5_p8-r0"

# install Eclipse Temurin JDK
RUN curl https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk -o /etc/apk/keys/adoptium.rsa.pub && \
    echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >> /etc/apk/repositories && \
    apk update && apk add temurin-17-jdk=${VERSION_ADOPTIUM_TEMURIN}

# https://github.com/unoconv/unoserver/
RUN pip install -U unoserver

# FIX: pyuno path not set  (https://gitlab.alpinelinux.org/alpine/aports/-/issues/13359)
# define path
ARG PATH_LO=/usr/lib/libreoffice/program
ARG PATH_SP=/usr/lib/python3.10/site-packages

RUN \
    # copy unohelper.py
    cp "$PATH_LO/unohelper.py" "$PATH_SP/"  && \
    # prefix path to uno.py
    echo -e "\
import sys, os \n\
sys.path.append('/usr/lib/libreoffice/program') \n\
os.putenv('URE_BOOTSTRAP', 'vnd.sun.star.pathname:/usr/lib/libreoffice/program/fundamentalrc')\
" > "$PATH_SP"/uno.py  && \
    # copy the original's content
    cat "$PATH_LO"/uno.py >> "$PATH_SP"/uno.py

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

ENTRYPOINT ["sh", "/config/entrypoint.sh"]