#!/bin/bash

set -e
set -x
# set -e: hata olursa durur
# set -x: her satiri ekrana basar

echo "[+] Kurulum yapiliyor."
sudo apt-get update -y
sudo apt-get install -y curl
sleep 10

echo "[+] K3s kuruluyor."
curl -sfL https://get.k3s.io | sh -s - server --node-ip=192.168.56.110 --bind-address=192.168.56.110
sleep 10

TOKEN_PATH="/vagrant/token"

echo "[+] Token olusturuluyor."
sudo cat /var/lib/rancher/k3s/server/node-token > "$TOKEN_PATH"
sleep 10

chmod 777 "$TOKEN_PATH"
sleep 10
