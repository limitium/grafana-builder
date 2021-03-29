#!/bin/bash

TAG=limitium/grafana-builder
VERSION=latest

if [ -z "$1" ] || [ -z "$2" ]
then
   echo "Image name or path to grafana is missing"
   echo "Builder usage:"
   echo "build.sh reponame/grafana:latest /path/to/grafana"
   exit
fi

GRAFANA_DIR=$2

IFS=':'
read -ra imageParts <<< "$1"

if [ ${#imageParts[@]} -ne 2 ]
then
  echo "Wrong format of image name"
  echo "Use: repo/image:version"
fi

GRAFANA_IMAGE="${imageParts[0]}"
GRAFANA_VERSION="${imageParts[1]}"

clean_up() {
  docker rm -f grafana-builder
  rm -rf ./images/*
}

run_builder() {
  docker run --rm -d \
    --privileged \
    -w "/go/src/grafana" \
    -v "${GRAFANA_DIR}":/go/src/grafana \
    -v "${PWD}/images":/tmp/images \
    --name grafana-builder \
    ${TAG}:${VERSION} \
    bash -c "/tmp/bootstrap.sh; tail -f /dev/null"
}

start_docker() {
  docker exec grafana-builder bash /tmp/start_docker.sh  || exit 1
}

build_binaries() {
  docker exec grafana-builder bash /tmp/build_binaries.sh
}

build_images() {
  docker exec grafana-builder bash -c "/tmp/build_images.sh ${GRAFANA_IMAGE} ${GRAFANA_VERSION}"
}

load_images() {
  ls -1 images/*.tar | xargs --no-run-if-empty -L 1 docker load -i
}

docker_create_manifest() {
  docker manifest create \
    your-username/multiarch-example:manifest-latest \
    --amend your-username/multiarch-example:manifest-amd64 \
    --amend your-username/multiarch-example:manifest-arm32v7 \
    --amend your-username/multiarch-example:manifest-arm64v8

  docker manifest push your-username/multiarch-example:manifest-lates
}

docker_push() {
  arch=$1
  repo_arch="-${arch}-linux"
  tag="${_docker_repo}${repo_arch}:${_grafana_version}"

  docker push tag
}

clean_up
run_builder
start_docker
build_binaries
build_images
load_images
