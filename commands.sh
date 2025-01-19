#! /bin/bash

# this script contains the commands I ran on debian while reading my k8s in
# action book.

# some initial setup
# add user to sudoers group
su root
adduser matt sudo
# exit root
# logout and back in for groups to update
# had to remove /media/cdrom from apt sources
# https://askubuntu.com/questions/236288/apt-get-asks-me-to-insert-cd-why
sudo vi /etc/apt/sources.list
# brother, vim is the way. repent of emacs.
export VISUAL=vim
export EDITOR="$VISUAL"
# make github ssh key
ssh-keygen -t ed25519 -C "mtthwmths@gmail.com"
# check ssh-agent is running
eval "$(ssh-agent -s)"
# add private key to ssh-agent
ssh-add ~/.ssh/id_ed25519
# add public key to github
cat ~/.ssh/id_ed25519.pub
# copy paste the key to github/account/keys
# setup git global user info
git config --global user.name "Matt M"
git config --global user.email "mtthwmths@gmail.com"
# setup git global merge strategy
git config --global pull.rebase false
# grab obsidian '.deb' file (get latest path from obsidian downloads page)
cd ~/Downloads/
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.7/obsidian_1.7.7_amd64.deb
sudo apt install ./obsidian_1.7.7_amd64.deb
# get tinyhorseywings and mm-vault1 from github.
# use tinyhorseywings to create bash aliases and vimrc. add bashrc stuff to existing bashrc.
# add mm-vault1 to obsidian
# add mm-vault1 path to bashrc functions for obsidianpull and obsidianbackup

# docker setup
# add docker gpg key
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o \
  /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# add repo to apt
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian $(. /etc/os-release && \
  echo "$VERSION_CODENAME") stable" | sudo tee \
  /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# run docker without sudo
sudo groupadd docker
sudo usermod -aG docker $USER
# logout and back in for groups to update
# use systemd to start docker on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
# you may need to use systemctl status or journalctl -xeu to troubleshoot
# setup the daemon.json file to use json-file logging driver to log rotation so
# that files do not exceed 10m in size and 3 files in total.
# there are other logging drivers (like fluentd)
sudo cat <<EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# test it all out
docker run hello-world

# make the basic app.js file from c2.1.2
# make a Dockerfile for the app.js
# cd to the directory with those 2 files
docker build -t kubia-c2-1-2 .
# it's in images now
docker images
# run a container with it
docker run --name kubia-container -p 8080:8080 -d kubia-c2-1-2
# see the container running
docker ps
# inspect it and then run an interactive shell on the container
docker inspect kubia-container
docker exec -it kubia-container bash
# exit that shell
# ps aux will show the commands running on the container run on the host
ps aux | grep app.js
# stop the container
docker stop kubia-container
# it's still there, just stopped.
docker ps -a
docker rm kubia-container
# push it to docker hub. you'll have to login
docker login
docker tag kubia-c2-1-2 mtthwmths/kubia-c2-1-2
docker push mtthwmths/kubia-c2-1-2

# kubernetes through minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
minikube start
# get kubectl
# public signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
# add the kubernetes apt repo
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
# autocompletion for kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
# enjoy minikube
kubectl cluster-info
# you can run `minikube ssh` to log into the minikube vm

# so let's run app.js on minikube
# make a replication controller(rc) yaml for the mtthwmths/kubia-c2-1-2 image
# tell kubectl to apply that to your cluster
k apply -f kubia-rc.yaml
# expose that rc using a loadbalancer
k expose rc kubia-rc --type=LoadBalancer --name kubia-http
# minikube doesn't do external ips, but you can call a minikube function for that
minikube service kubia-http
# neato
# you can make more with k scale
k scale rc kubia-http --replicas=3
# check it out on the dashboard
minikube dashboard

