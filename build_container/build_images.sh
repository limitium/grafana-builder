#!/bin/sh
set -e

GRAFANA_IMAGE=$1
GRAFANA_VERSION=$2

echo "Building ${GRAFANA_IMAGE}:${GRAFANA_VERSION}"

#Setup docker and qemu
docker_setup() {
  export DOCKER_CLI_EXPERIMENTAL=enabled
  service docker start
  until service docker status | grep -q "Docker is running"; do
    sleep 1
  done

  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
}

# Build grafana image for a specific arch
docker_build() {
  arch=$1
  binary_dir=$2

  repo_arch="-${arch}-linux"
  tag="${GRAFANA_IMAGE}${repo_arch}:${GRAFANA_VERSION}"

  docker build \
    --build-arg ARCH="${arch}" \
    --build-arg BINARY_DIR="${binary_dir}" \
    --tag "${tag}" \
    --no-cache=true \
    -f "/tmp/Dockerfile" \
    .

  docker save -o /tmp/images/"${arch}".tar "${tag}"
}
docker_setup

docker_build "amd64" "linux-amd64-musl"
docker_build "arm32v7" "linux-armv7-musl"
docker_build "arm64v8" "linux-arm64-musl"
