#!/bin/bash

# shellcheck disable=SC2086

#
#   This script is executed from within the container.
#
set -e

##########
CCARMV6=/opt/rpi-tools/arm-bcm2708/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc
CCARMV7=arm-linux-gnueabihf-gcc
CCARMV7_MUSL=/tmp/arm-linux-musleabihf-cross/bin/arm-linux-musleabihf-gcc
CCARM64=aarch64-linux-gnu-gcc
CCARM64_MUSL=/tmp/aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc
CCX64=/tmp/x86_64-centos6-linux-gnu/bin/x86_64-centos6-linux-gnu-gcc
CCX64_MUSL=/tmp/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc

function build_backend_linux_amd64() {
  if [ ! -d "distr" ]; then
    mkdir distr
  fi
  #  CC=${CCX64} go run build.go build
  CC=${CCX64_MUSL} go run build.go -libc musl build
}

function build_backend() {
  if [ ! -d "distr" ]; then
    mkdir distr
  fi

  #  go run build.go -goarch armv6 -cc ${CCARMV6} build
  #  go run build.go -goarch armv7 -cc ${CCARMV7} build
  #  go run build.go -goarch arm64 -cc ${CCARM64} build
  go run build.go -goarch armv7 -libc musl -cc ${CCARMV7_MUSL} build
  go run build.go -goarch arm64 -libc musl -cc ${CCARM64_MUSL} build
  build_backend_linux_amd64
}

function build_frontend() {
  if [ ! -d "distr" ]; then
    mkdir distr
  fi
  yarn install --pure-lockfile --no-progress
  echo "Building frontend"
  yarn --progress -p --mode=production build
  echo "FRONTEND: finished"
}

function package_linux_amd64() {
  echo "Packaging Linux AMD64"
  go run build.go -goos linux -pkg-arch amd64 package-only
  go run build.go -goos linux -pkg-arch amd64 -libc musl -skipRpm -skipDeb package-only
  go run build.go latest
  echo "PACKAGE LINUX AMD64: finished"
}

function package_all() {
  echo "Packaging ALL"
  cp -r bin distr/
  cp -r public distr/
  echo "PACKAGE ALL: finished"
}

build_start=$(date +%s%N)

build_backend
build_frontend
package_all

build_total=$((($(date +%s%N) - build_start) / 1000000000))
echo "Build took: $build_total s"
