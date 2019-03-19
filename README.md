# Docker base image
A base Alpine image .

[![](https://images.microbadger.com/badges/image/edofede/baseimage.svg)](https://microbadger.com/images/edofede/baseimage "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/edofede/baseimage.svg)](https://microbadger.com/images/edofede/baseimage "Get your own version badge on microbadger.com")
![](https://img.shields.io/github/last-commit/EdoFede/BaseImage-Docker.svg)
![](https://img.shields.io/github/license/EdoFede/BaseImage-Docker.svg)  
![](https://img.shields.io/docker/pulls/edofede/baseimage.svg)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/3aa769f5cc2847d495ebf2bd11a770df)](https://www.codacy.com/app/EdoFede/BaseImage-Docker?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=EdoFede/BaseImage-Docker&amp;utm_campaign=Badge_Grade)
![](https://img.shields.io/badge/If%20you%20can%20read%20this-you%20don't%20need%20glasses-green.svg)

## Introduction
This Docker image is based on Alpine linux and is intended to be used ad a base image to run services inside a container.
On top of Alpine, [runit](http://smarden.org/runit/) is used as init scheme and service supervisor and [syslog-ng](https://www.syslog-ng.com/products/open-source-log-management/) is used to collect logs and redirect it to Docker logs (via stderr and stdout).

## How to use
### Use as base image
The image is available on the Docker hub and can be used as base image to build your own project.

```Dockerfile
FROM edofede/baseimage:<VERSION>
```

### Container creation
You can simply create and start a Docker container from the [image on the Docker hub](https://hub.docker.com/r/edofede/baseimage) by running:

```bash
docker create --name BaseImage edofede/baseimage:latest
docker start BaseImage
```
Then you can launch bash or other commands inside:

```bash
docker exec -ti BaseImage bash
```

If, instead, you want to run the image one-shot, without starting services, use:

```bash
docker run -ti --rm edofede/baseimage:latest bash
```

### Entrypoint
The entrypoint script (``` /entrypoint.sh ```) accepts arguments. These are launched on the container, **instead** of starting runit and related services.

## Setup
### Run one-shot script at boot
To run one or more scripts at container boot, insert (or symlink) it inside ``` /etc/runit/1.d/ ``` folder.
All scripts/programs inside this folder will be launched before services starts. If one fails, the container enters in shutdown mode.

### Add new service
To add a new service, create a new folder inside ``` /etc/sv/ ``` and add the "run" script inside.

Example (``` /etc/sv/syslog-ng/run ```):

```bash
#!/usr/bin/env sh
set -eu
exec 2>&1

/usr/sbin/syslog-ng --foreground
```
Configure all services to run in foreground mode, so runit can handle it correctly.

Then link the service folder inside ``` /etc/service ``` directory.
Example:

```bash
ln -sf /etc/sv/syslog-ng /etc/service/
```

For additional information or advanced configuration, please read the [runit guide](http://smarden.org/runit/).

### Set timezone
The image comes with tzdata already installed (and timzone setted to Europe/Rome).
To set a new timezone, launch a bash command and follow [this guide](https://wiki.alpinelinux.org/wiki/Setting_the_timezone) (skip the first command).

