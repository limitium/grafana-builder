# grafana-builder
Multiarch grafana builder

## RUN
Grab a repo and run this build script
```shell
./build.sh limitium/grafana:latest /home/limi/projects/grafana/
```

After script finish, new images be available in local docker
```shell
docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED              SIZE
limitium/grafana-arm64v8-linux   latest              3c676a691024        42 seconds ago       166MB
limitium/grafana-arm32v7-linux   latest              2dbdb706f089        About a minute ago   155MB
limitium/grafana-amd64-linux     latest              f6efc297dfcf        About a minute ago   172MB
```

By default amd64,arm64v8,arm32v7 images are created

## Ideas behind this repo
The main builder is based on an official grafana builder https://github.com/grafana/grafana/tree/master/scripts/build/ci-build
Following things were added:
* qemu multiarch emulator
* full functional docker

Grafana docker images almost the same as official one  https://github.com/grafana/grafana/blob/master/packaging/docker/Dockerfile


### TODO:
* add params to control build phases (skip compile binaries)
* add set archs as build parameter
* create manifest with all archs
* push images to repo