#!/bin/bash
set -e

echo "🚀 Starting minimal development environment for Codespaces..."

# Basic setup
sudo apt-get update -qq
sudo apt-get install -y git python3 python3-pip python3-venv build-essential

# Create SSL certificates (simplified)
mkdir -p /home/coder/certs
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout /home/coder/certs/server.key \
  -out /home/coder/certs/server.crt \
  -days 365 \
  -subj "/C=US/ST=Dev/L=Dev/O=DevEnv/CN=localhost"

sudo cp /home/coder/certs/*.crt /etc/ssl/certs/
sudo cp /home/coder/certs/*.key /etc/ssl/private/
sudo chmod 644 /etc/ssl/certs/*.crt
sudo chmod 600 /etc/ssl/private/*.key

# Setup code-server config
mkdir -p ~/.config/code-server
cp /home/coder/setup/code-server-config.yaml ~/.config/code-server/config.yaml
export PASSWORD="${CODE_SERVER_PASSWORD:-password}"
sed -i "s/your-secure-password-here/$PASSWORD/g" ~/.config/code-server/config.yaml

# Setup nginx
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /home/coder/sites/nginx.conf /etc/nginx/sites-enabled/nginx.conf
sudo nginx -t && sudo service nginx start

# Start code-server
echo "🔁 Starting code-server..."
code-server --config ~/.config/code-server/config.yaml &

echo "✅ Development environment ready!"
echo "🌐 Access: https://localhost:8443"
echo "🔑 Password: $PASSWORD"

# Keep container alive
tail -f /dev/null
