#!/bin/bash

sudo service docker stop
sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo curl -fsSL https://get.docker.com |sh

sudo mkdir -p /etc/docker
sudo touch /etc/docker/daemon.json
echo '{"experimental": true}' |sudo tee /etc/docker/daemon.json
sudo service docker restart
