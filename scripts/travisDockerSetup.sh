#!/bin/bash

echo ""
echo -e "\033[0;34m# OLD Docker engine config file \033[0m"
sudo ls -la /etc/docker/daemon.json
sudo cat /etc/docker/daemon.json




echo "sudo ls -la /etc/systemd"
sudo ls -la /etc/systemd
echo "sudo ls -la /etc/systemd/system"
sudo ls -la /etc/systemd/system
echo "sudo ls -la /etc/systemd/system/docker.service.d"
sudo ls -la /etc/systemd/system/docker.service.d
echo "sudo cat /etc/systemd/system/docker.service.d/docker.conf"
sudo cat /etc/systemd/system/docker.service.d/docker.conf


echo "find /etc/systemd -name *docker*"
find /etc/systemd -name *docker*










echo ""
echo -e "\033[0;34m# Enabling Docker engine experimental mode \033[0m"
echo '{"registry-mirrors": ["https://mirror.gcr.io"], "mtu": 1460, "experimental":"enabled"}' | sudo tee /etc/docker/daemon.json
sudo chown travis:travis /etc/docker/daemon.json

# echo ""
# echo -e "\033[0;34m# Restarting Docker service \033[0m"
# sudo systemctl restart docker

echo ""
echo -e "\033[0;34m# Checking Docker restart logs \033[0m"
echo -e "\033[0;32msystemctl status docker.service\033[0m"
sudo systemctl status docker.service

echo ""
echo -e "\033[0;34m# NEW Docker engine config file \033[0m"
sudo ls -la /etc/docker/daemon.json
sudo cat /etc/docker/daemon.json


echo ""
echo -e "\033[0;34m# Enabling Docker client experimental mode \033[0m"
mkdir -p $HOME/.docker
echo '{"experimental":"enabled"}' | sudo tee $HOME/.docker/config.json

echo ""
echo -e "\033[0;34m# Checking docker version \033[0m"
docker version

echo ""
echo -e "\033[0;34m# Checking running containers \033[0m"
docker ps -a


# echo ""
# echo -e "\033[0;34m######### Pulling and starting local registry #########\033[0m"
# docker pull registry:2
# docker run -d -p 5000:5000 --restart always --name registry registry:2
