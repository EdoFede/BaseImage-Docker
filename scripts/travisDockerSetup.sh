#!/bin/bash
# echo ""
# echo -e "\033[0;34m######### Enabling client experimental features #########\033[0m"
# mkdir -p $HOME/.docker
# echo '{ "experimental": "enabled" }' > $HOME/.docker/config.json

# echo ""
# echo -e "\033[0;34m######### Enabling server experimental features #########\033[0m"
# echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json
# sudo service docker restart

echo ""
echo -e "\033[0;34m######### Pulling and starting local registry #########\033[0m"
docker pull registry:2
docker run -d -p 5000:5000 --restart always --name registry registry:2

echo ""
docker ps -a

echo ""
echo -e "\033[0;34m######### Docker version #########\033[0m"
docker version
