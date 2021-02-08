FROM grafana/build-container:1.3.1

LABEL maintainer="Bloomy.space team https://t.me/bloomy_space_chat"

RUN DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -yq install apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" && \
    apt-get -y update && \
    apt-get -y install docker-ce && \
    mkdir /etc/docker && \
    echo "{\"storage-driver\": \"vfs\"}" >  /etc/docker/daemon.json

RUN apt-get -y install qemu binfmt-support qemu-user-static

COPY ./build_binaries.sh /tmp/build_binaries.sh
COPY build_images.sh /tmp/build_images.sh
COPY ./grafana_container/Dockerfile /tmp/Dockerfile
