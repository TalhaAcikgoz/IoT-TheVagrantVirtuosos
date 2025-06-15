#!/bin/bash

set -e
set -x
# set -e: stops when an error occures
# set -x: print the all lines

echo "[+] Kurulum yapiliyor."
sudo apt-get update -y
sudo apt-get install -y curl
sleep 10

TOKEN_FILE="/vagrant/token"
SERVER_IP="192.168.56.110"
sleep 10

echo "[+] Token aliniyor."
while [ ! -f "$TOKEN_FILE" ]; do
    sleep 3
done
sleep 10

TOKEN=$(cat "$TOKEN_FILE")
sleep 10

echo "[+] K3s kuruluyor."
curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" sh -s - agent --node-ip=192.168.56.111
# The parameters after -s are the parameters of the command which is taken with curl
sleep 10
