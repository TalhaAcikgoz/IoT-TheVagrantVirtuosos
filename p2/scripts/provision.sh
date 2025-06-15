#!/bin/bash

set -e
set -x
# set -e: stops when an error occures
# set -x: print the all lines

echo "[+] Updating system"
apt-get update -y
apt-get install -y curl docker.io

echo "[+] Installing K3s"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san 192.168.56.110 --bind-address 192.168.56.110 --node-ip 192.168.56.110 --docker" sh -
sleep 10

echo "[+] Creating configmaps"
kubectl create configmap app1-html --from-file=/vagrant/src/app1/app1.html
kubectl create configmap app2-html --from-file=/vagrant/src/app2/app2.html
kubectl create configmap app3-html --from-file=/vagrant/src/app3/app3.html
sleep 10
# echo "[+] Adding kubectl to PATH"
# export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# echo "[+] Waiting for K3s to be ready..."
# sleep 10

echo "[+] Creating Kubernetes resources"
kubectl apply -f /vagrant/confs/deploy.yaml
