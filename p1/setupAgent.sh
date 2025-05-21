sudo apt-get update -y
sudo apt-get install -y curl

TOKEN_FILE="/vagrant/token"
SERVER_IP="192.168.56.10"

while [ ! -f "$TOKEN_FILE" ]; do
    sleep 2
done

TOKEN=$(cat "$TOKEN_FILE")

curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" sh -