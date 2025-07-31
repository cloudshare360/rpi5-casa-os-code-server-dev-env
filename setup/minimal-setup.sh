#!/bin/bash
set -e

echo "🚀 Starting minimal development environment setup..."

# Update packages
sudo apt-get update

# Install basic tools
echo "📥 Installing basic development tools..."
sudo apt-get install -y git python3 python3-pip python3-venv build-essential

# Generate SSL certificates
echo "🔒 Generating SSL certificates..."
mkdir -p /home/coder/certs
if [[ ! -f /home/coder/certs/server.crt ]]; then
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /home/coder/certs/server.key \
    -out /home/coder/certs/server.crt \
    -days 365 \
    -subj "/C=US/ST=Dev/L=Dev/O=DevEnv/CN=localhost"
fi

sudo cp /home/coder/certs/*.crt /etc/ssl/certs/
sudo cp /home/coder/certs/*.key /etc/ssl/private/
sudo chmod 644 /etc/ssl/certs/*.crt
sudo chmod 600 /etc/ssl/private/*.key

# Setup nginx
echo "🌐 Configuring nginx..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /home/coder/sites/nginx.conf /etc/nginx/sites-enabled/nginx.conf
sudo nginx -t && sudo systemctl restart nginx

# Setup code-server
echo "🖥️ Configuring code-server..."
mkdir -p ~/.config/code-server
cp /home/coder/setup/code-server-config.yaml ~/.config/code-server/config.yaml
export PASSWORD="${CODE_SERVER_PASSWORD:-password}"
sed -i "s/your-secure-password-here/$PASSWORD/g" ~/.config/code-server/config.yaml

# Start code-server
echo "🔁 Starting code-server..."
code-server --config ~/.config/code-server/config.yaml &

echo "✅ Basic development environment is ready!"
echo "👉 Access code-server: https://localhost:8443"
echo "📁 Workspace: /workspace"
echo "🔑 Password: $PASSWORD"

# Keep container running
tail -f /dev/null
