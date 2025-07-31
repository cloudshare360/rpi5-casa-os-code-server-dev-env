#!/bin/bash
set -e

echo "🚀 Starting fu#!/bin/bash
set -e

echo "🚀 Starting full-stack development environment setup..."

# Update packages first
sudo apt-get update

# ========== GIT ==========
echo "📥 Installing Git..."
sudo apt-get install -y git
git config --global user.name "Developer" || true
git config --global user.email "dev@example.com" || true

# ========== PYTHON & PIP ==========
echo "📥 Installing Python, pip, and virtualenv..."
sudo apt-get install -y python3 python3-pip python3-venv build-essential

# Install virtualenv via pip3 (avoid the sudo warning for this use case)
pip3 install --user virtualenv

echo "✅ Python, pip, and virtualenv installed"
echo "export PATH=\$PATH:/home/coder/.local/bin" >> ~/.bashrc

# ========== SSL CERTS ==========
echo "🔒 Generating SSL certificates..."
if [[ ! -f /home/coder/certs/server.crt ]]; then
  echo "⚠️ Generating self-signed certificate..."
  openssl req -x509 -nodes -newkey rsa:2048 
    -keyout /home/coder/certs/server.key 
    -out /home/coder/certs/server.crt 
    -days 365 
    -subj "/C=US/ST=Dev/L=Dev/O=DevEnv/CN=localhost"
fi

sudo cp /home/coder/certs/*.crt /etc/ssl/certs/
sudo cp /home/coder/certs/*.key /etc/ssl/private/
sudo chmod 644 /etc/ssl/certs/*.crt
sudo chmod 600 /etc/ssl/private/*.key

# ========== CODE-SERVER CONFIG ==========
echo "🖥️ Configuring code-server..."
mkdir -p ~/.config/code-server
if [[ ! -f ~/.config/code-server/config.yaml ]]; then
  cp /home/coder/setup/code-server-config.yaml ~/.config/code-server/config.yaml
fi

export PASSWORD="${CODE_SERVER_PASSWORD:-password}"
sed -i "s/your-secure-password-here/$PASSWORD/g" ~/.config/code-server/config.yaml

# ========== NGINX SETUP ==========
echo "🌐 Setting up nginx..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /home/coder/sites/nginx.conf /etc/nginx/sites-enabled/nginx.conf

# ========== START SERVICES ==========
echo "🔁 Starting nginx..."
sudo nginx -t && sudo nginx -s reload || sudo nginx

echo "🔁 Starting code-server..."
code-server --config ~/.config/code-server/config.yaml &

echo "✅ Basic development environment is ready!"
echo "👉 Access code-server: https://localhost:8443"
echo "📁 Workspace: /workspace"
echo "🔑 Password: $PASSWORD"
echo "📦 Basic tools: Python 3, pip, virtualenv, git"
echo ""
echo "🔧 Additional tools can be installed manually:"
echo "  - SDKMAN available at: ~/.sdkman"
echo "  - Node.js: Use 'nvm install --lts' inside container"
echo "  - Java: Use SDKMAN: 'sdk install java 8.0.392-open'"

tail -f /dev/nullment environment setup..."

# Update packages first
sudo apt-get update

# ========== GIT ==========
echo "📥 Installing Git..."
sudo apt-get install -y git
git config --global user.name "Developer"
git config --global user.email "dev@example.com"

# ========== PYTHON & PIP ==========
echo "📥 Installing Python, pip, and virtualenv..."
sudo apt-get install -y python3 python3-pip python3-venv build-essential

sudo pip3 install --upgrade pip
sudo pip3 install virtualenv

echo "✅ Python, pip, and virtualenv installed"
echo "export PATH=\$PATH:/home/coder/.local/bin" >> ~/.bashrc

# ========== NODE.JS via NVM ==========
echo "📥 Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo "export NVM_DIR=\"$HOME/.nvm\"" >> ~/.bashrc
echo "[[ -s \"\$NVM_DIR/nvm.sh\" ]] && \. \"\$NVM_DIR/nvm.sh\"" >> ~/.bashrc
echo "[[ -s \"\$NVM_DIR/bash_completion\" ]] && \. \"\$NVM_DIR/bash_completion\"" >> ~/.bashrc

# ========== SSL CERTS ==========
echo "� Generating SSL certificates..."
if [[ ! -f /home/coder/certs/server.crt ]]; then
  echo "⚠️ Generating self-signed certificate..."
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /home/coder/certs/server.key \
    -out /home/coder/certs/server.crt \
    -days 365 \
    -subj "/C=US/ST=Dev/L=Dev/O=DevEnv/CN=localhost"
fi

sudo cp /home/coder/certs/*.crt /etc/ssl/certs/
sudo cp /home/coder/certs/*.key /etc/ssl/private/
sudo chown root:ssl-cert /etc/ssl/certs/*.crt /etc/ssl/private/*.key
sudo chmod 644 /etc/ssl/certs/*.crt
sudo chmod 600 /etc/ssl/private/*.key

# ========== CODE-SERVER CONFIG ==========
echo "🖥️ Configuring code-server..."
mkdir -p ~/.config/code-server
if [[ ! -f ~/.config/code-server/config.yaml ]]; then
  cp /home/coder/setup/code-server-config.yaml ~/.config/code-server/config.yaml
fi

export PASSWORD="${CODE_SERVER_PASSWORD:-password}"
sed -i "s/your-secure-password-here/$PASSWORD/g" ~/.config/code-server/config.yaml

# ========== NGINX SETUP ==========
echo "🌐 Setting up nginx..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /home/coder/sites/nginx.conf /etc/nginx/sites-enabled/nginx.conf

# ========== START SERVICES ==========
echo "🔁 Starting nginx..."
sudo nginx -t && sudo nginx -s reload || sudo nginx

echo "🔁 Starting code-server..."
code-server --config ~/.config/code-server/config.yaml &

echo "✅ Basic development environment is ready!"
echo "👉 Access code-server: https://<host>:8443"
echo "📁 Workspace: /workspace"
echo "📦 Tools: Node.js (LTS), Python 3, pip, virtualenv, git, Docker"
echo "⚠️ Note: Java/Maven/Tomcat setup can be done manually inside the container"

# Initialize SDKMAN for later use
echo "🔧 Installing SDKMAN for Java development..."
export SDKMAN_DIR="/home/coder/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    echo "✅ SDKMAN available for Java installation"
else
    echo "❌ SDKMAN not properly installed during build"
fi

tail -f /dev/null
