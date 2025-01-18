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
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# add repo to apt
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# run docker without sudo
sudo groupadd docker
sudo usermod -aG docker $USER
# logout and back in for groups to update
# test it all out
docker run hello-world

