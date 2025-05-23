#!/bin/bash

set -e
set -x
# set -e: hata olursa durur
# set -x: her satiri ekrana basar

echo "[+] Updating system"
apt-get update -y
apt-get install -y curl docker.io 

echo "[+] Restarting docker"
systemctl restart docker
sleep 10

echo "[+] Installing K3s"
curl -sfL https://get.k3s.io | sh -

echo "[+] Adding kubectl to PATH"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "[+] Waiting for K3s to be ready..."
sleep 10

echo "[+] Creating custom HTML Docker images"
cd /vagrant/src
docker build -t app1-img app1/
docker build -t app2-img app2/
docker build -t app3-img app3/

echo "[+] Creating Kubernetes resources"
kubectl apply -f /vagrant/confs/deploy.yaml
