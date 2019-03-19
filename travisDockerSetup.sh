#!/bin/bash

# sudo service docker stop
# sudo apt-get remove -y docker docker-engine docker.io containerd runc
# sudo curl -fsSL https://get.docker.com |sh

mkdir -p $HOME/.docker
echo '{ "experimental": "enabled" }' > $HOME/.docker/config.json
# sudo service docker restart
echo '####### Docker version #######'
docker version
