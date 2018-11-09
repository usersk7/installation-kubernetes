#!/bin/bash

#swapoff before installing kubernetes
#Install docker
#Configuration of kubeadm kubectl and kubelet 


sudo apt-get update

echo "....................swapoff"

swapoff -a

echo "....................Installing sshpass "

sudo apt-get install -y sshpass   

echo "....................openssh server installation"
sudo apt-get install -y openssh-server

sudo apt-get update
echo "....................Docker installtion"

#sudo apt-get install -y docker.io
#apt-get install -y docker.io
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USER}



sudo apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sleep 30s

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

echo ".....................Installing kubeadm kubelet kubectl"

sudo apt-get install -y kubeadm=1.10.5-00 kubectl=1.10.5-00 kubelet=1.10.5-00

apt-mark hold kubelet kubeadm kubectl


echo ".......................Restart kubelet"

systemctl daemon-reload
systemctl restart kubelet

sudo apt-get update

echo ".......................Execute sucessfully"




