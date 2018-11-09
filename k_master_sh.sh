#!/bin/bash

masterip=$1
slavepass=$2
slaveip=$3
registry_ip=$4
registry_port=$5
registry_user=$6
registry_pass=$7
registry_email=$8

kubeadm init --apiserver-advertise-address=$masterip --pod-network-cidr=192.168.0.0/16 | tee -a output.txt

#use when root user

#export KUBECONFIG=/etc/kubernetes/admin.conf

#use when user is not root
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "........................Network plugin "

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml


kubectl taint nodes --all node-role.kubernetes.io/master-

echo ".......................Joining node to cluster"

#output send to result file and that send to Knode folder

#Kubeadm init command output take into output.txt file and that convert to output.sh file and execute as shell

grep "kubeadm" ./output.txt | grep "join" | tee -a ./output.sh
chmod +x ./output.sh

echo "                                                         Running on slave machine"
sshpass -p $slavepass scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null output.sh  root@$slaveip:/root

sshpass -p $slavepass ssh -o StrictHostKeyChecking=no  root@$slaveip 'sh /root/output.sh'

echo "......................._remove file content otherwise it create ambiguity-"

>output.sh
>output.txt

sleep 30s

echo ".......................installing dashboard"

kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

#To access the dashboard with full administrative permission, create a YAML file named dashboard-admin.yaml

cat > /root/dashboard-admin.yml << EOF1
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system

EOF1

sleep 30s

kubectl create -f /root/dashboard-admin.yml

nohup kubectl proxy --address=$masterip -p 443 --accept-hosts='^*$' &


sleep 60s

echo "........................accessing dashboard use"

echo "http://$masterip:443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

sleep 60s

kubectl get nodes


