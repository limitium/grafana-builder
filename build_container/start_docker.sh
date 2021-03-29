#!/bin/sh
set -e

docker_start() {
  tries=0
  until [ "$tries" -ge 3 ]; do
    echo "Try to start docker"
    service docker start

    until service docker status || true | grep -q "Docker is running"; do
      sleep 1
    done

    if [ ! -f /var/run/docker.sock ]; then
      echo "Docker started"
      return 0
    fi

    echo "Docker sock wasn't found. Retry."
    service docker stop

    tries=$((tries + 1))
    sleep 3
  done

  echo "Unable to run docker"
  exit 1
}

#Setup docker and qemu
docker_setup() {
  export DOCKER_CLI_EXPERIMENTAL=enabled

  docker_start

  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes || (echo "DID failed, try to rerun builder" && exit 1)
}

docker_setup