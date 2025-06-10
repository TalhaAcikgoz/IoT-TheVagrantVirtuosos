#!/bin/bash
set -e

echo "==> Paket listeleri güncelleniyor..."
# sudo apt-get update -y

echo "==> Gerekli paketler kuruluyor..."
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  unzip \
  software-properties-common \
  apt-transport-https

################################################################################
# Docker kurulumu
################################################################################
if ! command -v docker >/dev/null 2>&1; then
  echo "==> Docker kurulumu başlıyor..."

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "==> Docker servisi başlatılıyor..."
  sudo systemctl enable docker
  sudo systemctl start docker
else
  echo "==> Docker zaten yüklü."
fi

docker pull argoproj/argocd
docker pull ghcr.io/dexidp/dex

################################################################################
# kubectl kurulumu
################################################################################
if ! command -v kubectl >/dev/null 2>&1; then
  echo "==> kubectl indiriliyor..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "==> kubectl zaten kurulu."
fi

################################################################################
# k3d kurulumu
################################################################################
if ! command -v k3d >/dev/null 2>&1; then
  echo "==> k3d kuruluyor..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
  echo "==> k3d zaten kurulu."
fi

################################################################################
# ArgoCD CLI kurulumu
################################################################################
if ! command -v argocd >/dev/null 2>&1; then
  echo "==> Argo CD CLI indiriliyor..."
  ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
  chmod +x argocd
  sudo mv argocd /usr/local/bin/
else
  echo "==> argocd zaten kurulu."
fi

################################################################################
# K3d cluster oluşturma
################################################################################
CLUSTER_NAME="p3-cluster"
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
  echo "==> $CLUSTER_NAME zaten var, siliniyor..."
  k3d cluster delete "$CLUSTER_NAME"
fi

echo "==> $CLUSTER_NAME oluşturuluyor..."
k3d cluster create "$CLUSTER_NAME" \
  --servers 1 \
  --agents 0 \
  --api-port 6550 \
  --port '8082:80@loadbalancer' \
  --k3s-arg "--disable=traefik@server:0" \
  --wait

echo "==> kubeconfig ayarlanıyor..."
mkdir -p "$HOME/.kube"
k3d kubeconfig get "$CLUSTER_NAME" > "$HOME/.kube/config"
export KUBECONFIG="$HOME/.kube/config"

echo "==> Node durumu:"
kubectl get nodes

echo "Kurulum tamamlandı. Debian ortamında k3d + ArgoCD hazır."

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml