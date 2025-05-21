#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y curl

curl -sfL https://get.k3s.io | sh -

TOKEN_PATH="/vagrant/token"

sudo cat /var/lib/rancher/k3s/server/node-token > "$TOKEN_PATH"

chmod 777 "$TOKEN_PATH"