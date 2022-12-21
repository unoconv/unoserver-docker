# Unoserver Docker Image

Docker image for unoserver

## The environment

This Docker image uses Alpine Linux as base image and provides:

- [LibreOffice](https://www.libreoffice.org/)

- [unoserver](https://github.com/unoconv/unoserver)

- Fonts (alpine packages)
  - font-noto
  - font-noto-cjk
  - font-noto-extra
  - terminus-font
  - ttf-font-awesome
  - ttf-dejavu
  - ttf-freefont
  - ttf-hack
  - ttf-inconsolata
  - ttf-liberation
  - ttf-mononoki 
  - ttf-opensans  

## How to use it

Just run:

    docker run -it -v <your directory>:/data/ ghcr.io/unoconv/unoserver-docker

or to convert directly:

    docker run -it -v <your directory>:/data/ ghcr.io/unoconv/unoserver-docker unoconvert /data/document.docx /data/document.pdf

Docker maps your directory with /data directory in the container.

You might need to add the option `:z` or `:Z` like `<your directory>:/data/:z` or `<your directory>:/data/:Z` if you are using SELinux. See [Docker docs](https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label) or [Podman docs](https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume-v-source-volume-host-dir-container-dir-options).

After you start the container, you can use [unoconvert](https://github.com/unoconv/unoserver#unoconvert) command to convert documents using LibreOffice.


## How to contribute / do it yourself?

### Requirements

You need the following tools:

- A bash compliant command line

- Docker installed and in your path

### How to build

        docker build .
