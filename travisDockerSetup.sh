#!/bin/bash

# sudo service docker stop
# sudo apt-get remove -y docker docker-engine docker.io containerd runc
# sudo curl -fsSL https://get.docker.com |sh

sudo mkdir -p /etc/docker
echo '{ "experimental": true }' | sudo tee /etc/docker/daemon.json
sudo service docker restart
cat /etc/docker/daemon.json
echo '####### Docker version #######'
docker version
