
---

# ✅ **Dev Environment for Raspberry Pi - Casa-OS - Docker based OS and Code-Server - How use  Raspberry Pi Effectively over browser for remote vscode Development**

> This document extends the original specification to include **Node.js, npm, Python, pip, and virtualenv**, ensuring full-stack development support (Java, JavaScript/TypeScript, Python).

---

## **1. Overview**
This document outlines the requirements for a Docker Compose-based development environment using an Ubuntu base image. The container must support **full-stack development** (Java, Node.js, Python), secure HTTPS access via `code-server`, and seamless integration with the host system.

---

## **2. Base Image**
- **Image**: `ubuntu:22.04` (LTS version for stability)

---

## **3. System Tools Installation**
Install the following:
- `curl`, `wget`, `zip`, `unzip`
- Network utilities: `net-tools`, `iputils-ping`, `dnsutils`
- `openssl`, `gnupg2`, `procps`, `sudo`

> **Purpose**: Enable connectivity, diagnostics, and secure package management.

---

## **4. Web Server Setup**
- Install and configure `nginx`
- Serve static content on port `80`
- Act as reverse proxy for `code-server`

---

## **5. SSL/TLS Certificate Management**
- Generate self-signed certificate using OpenSSL
- Store in `/etc/ssl/certs/` and `/etc/ssl/private/`
- Support Let's Encrypt in production

> **Purpose**: Enable secure HTTPS access.

---

## **6. Code-Server (Browser-Based VS Code)**
- Install latest stable `code-server`
- Run on internal port `8080`, bound to `0.0.0.0`
- Use password-based authentication
- Persist settings and extensions via volume

---

## **7. HTTPS Proxy for Code-Server**
- Use `nginx` as reverse proxy
- Terminate SSL at port `8443`
- Forward to `http://127.0.0.1:8080`
- Redirect HTTP (port 80) → HTTPS

---

## **8. SDKMAN! Installation**
- Install `SDKMAN!`
- Initialize in shell profile (`.bashrc`)
- Add to `PATH`

> **Purpose**: Manage Java, Maven, Gradle, etc.

---

## **9. Java Development Setup**
- Install **Java 8 (LTS)** via SDKMAN
- Set as default
- Configure:
  - `JAVA_HOME`: `/home/coder/.sdkman/candidates/java/current`
  - Add to `PATH`
  - `CLASSPATH` (if required)

---

## **10. Apache Maven Setup**
- Install **Maven** via SDKMAN
- Set in `PATH`
- Verify with `mvn --version`

---

## **11. Apache Tomcat Setup**
- Install latest stable Tomcat (e.g., 10.x)
- Install to `/opt/tomcat`
- Set:
  - `CATALINA_HOME=/opt/tomcat`
  - Add `bin/` to `PATH`
  - Include in `CLASSPATH` if needed

---

## **12. Git Setup**
- Install `git`
- Add to `PATH`
- Optional: Set global user/email

---

## **13. Node.js, npm, and NVM**
- Install **NVM (Node Version Manager)**
- Use NVM to install **Node.js LTS (e.g., 20.x)**
- Set default Node version
- Ensure `node`, `npm`, `npx` available in `PATH`

> **Purpose**: Full JavaScript/TypeScript development support.

---

## **14. Python, pip, and virtualenv**
- Install **Python 3**, `pip`, `python3-venv`, `virtualenv`
- Ensure `python`, `python3`, `pip`, `pip3`, `virtualenv` in `PATH`
- Recommend using `venv` or `virtualenv` for project isolation

> **Purpose**: Enable Python backend, scripting, and data science workflows.

---

## **15. Host System Integration**
- Mount host project directory to `/workspace`
- Mount Docker socket for Docker-in-container support
- Allow full shell access (`/bin/bash`)

---

## **16. Docker & DevContainer Support**
- Mount Docker socket: `/var/run/docker.sock`
- Install Docker CLI and `docker-compose` inside container
- Support GitHub Dev Containers

---

## **17. Ports to Expose**
| Port | Service                     |
|------|------------------------------|
| 8443 | HTTPS → `code-server`       |
| 8080 | Tomcat                      |
| 80   | HTTP (nginx redirect → 8443)|

---

## **18. Final Notes**
- All tools must be available in default shell (`PATH`)
- Use non-root user (`coder`) with sudo rights
- Initialize SDKMAN, NVM, and environment variables at login
- Prefer persistent configs and clean startup scripts

---

✅ **Next Step**: Implementation with updated tools.

---

# ✅ **Updated Implementation**

> Includes: **Node.js (NVM), npm, Python, pip, virtualenv**

---

## **1. Updated `setup.sh` Script**

Replace the old `setup.sh` with this updated version:

```bash
#!/bin/bash
set -e

echo "🚀 Starting full-stack development environment setup..."

# Source SDKMAN
export SDKMAN_DIR="/home/coder/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ========== JAVA & MAVEN ==========
if ! sdk list java | grep -q "8\\.0"; then
  sdk install java 8.0.392-open
fi
sdk default java 8.0.392-open

export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc

if ! sdk list maven | grep -q "3.9"; then
  sdk install maven
fi
sdk default maven
echo "export PATH=\$SDKMAN_DIR/candidates/maven/current/bin:\$PATH" >> ~/.bashrc

# ========== TOMCAT ==========
TOMCAT_VERSION="10.1.18"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-10/tomcat-10.1.18/bin/apache-tomcat-10.1.18.tar.gz"

cd /home/coder
wget -q $TOMCAT_URL -O tomcat.tar.gz
sudo mkdir -p /opt/tomcat
sudo tar -xzf tomcat.tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R coder:coder /opt/tomcat

export CATALINA_HOME="/opt/tomcat"
echo "export CATALINA_HOME=/opt/tomcat" >> ~/.bashrc
echo "export PATH=\$CATALINA_HOME/bin:\$PATH" >> ~/.bashrc

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

# ========== PYTHON & PIP ==========
echo "📥 Installing Python, pip, and virtualenv..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv build-essential

sudo pip3 install --upgrade pip
sudo pip3 install virtualenv

echo "✅ Python, pip, and virtualenv installed"
echo "export PATH=\$PATH:/home/coder/.local/bin" >> ~/.bashrc

# ========== GIT ==========
sudo apt-get install -y git
git config --global user.name "Developer"
git config --global user.email "dev@example.com"

# ========== NGINX ==========
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /home/coder/sites/nginx.conf /etc/nginx/sites-enabled/nginx.conf

# ========== SSL CERTS ==========
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
mkdir -p ~/.config/code-server
if [[ ! -f ~/.config/code-server/config.yaml ]]; then
  cp /home/coder/setup/code-server-config.yaml ~/.config/code-server/config.yaml
fi

export PASSWORD="${CODE_SERVER_PASSWORD:-password}"
sed -i "s/your-secure-password-here/$PASSWORD/g" ~/.config/code-server/config.yaml

# ========== START SERVICES ==========
echo "🔁 Starting nginx..."
sudo nginx -t && sudo nginx -s reload || sudo nginx

echo "🔁 Starting Tomcat..."
$CATALINA_HOME/bin/startup.sh

echo "🔁 Starting code-server..."
code-server --config ~/.config/code-server/config.yaml &

echo "✅ Full-stack development environment is ready!"
echo "👉 Access code-server: https://<host>:8443"
echo "📁 Workspace: /workspace"
echo "📦 Tools: Java 8, Maven, Tomcat, Node.js (LTS), Python 3, pip, virtualenv, git, Docker"

tail -f /dev/null
```

---

## **2. No Changes to `Dockerfile`**
The base `Dockerfile` remains unchanged — it already installs `curl`, `sudo`, and prepares the environment for the extended setup.

> ✅ Only `setup.sh` is updated.

---

## **3. No Changes to `nginx.conf`, `code-server-config.yaml`**
These remain the same. Only logic in `setup.sh` has expanded.

---

## **4. Optional: `.devcontainer.json` (For GitHub Dev Containers)**

If you want to use this with **VS Code Remote - Containers**, add:

### `.devcontainer/devcontainer.json`
```json
{
  "name": "Full-Stack Dev Env",
  "dockerComposeFile": "docker-compose.yml",
  "service": "dev-container",
  "workspaceFolder": "/workspace",
  "remoteUser": "coder",
  "postAttachCommand": "echo 'Environment ready! Open https://localhost:8443'",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-node-azure-pack",
        "ms-python.python",
        "vscjava.vscode-java-pack",
        "brpaz.wsdl-web-service-preview"
      ]
    }
  }
}
```

---

## ✅ Verification Commands (Inside Container)

Once running, verify:

```bash
java -version        # Java 8
mvn --version        # Maven
node --version       # Node.js LTS
npm --version
python3 --version
pip3 --version
virtualenv --version
git --version
docker --version
```

---

## ✅ Summary of Added Tools

| Tool          | Manager     | Available In PATH | Configured |
|---------------|-------------|-------------------|-----------|
| Node.js       | NVM         | ✅                | ✅         |
| npm / npx     | NVM         | ✅                | ✅         |
| Python 3      | system/pip  | ✅                | ✅         |
| pip           | system      | ✅                | ✅         |
| virtualenv    | pip         | ✅                | ✅         |

> All tools are available in the shell and accessible from `code-server` terminal.

---

## 📦 Final Project Structure

```
dev-env/
├── docker-compose.yml
├── .env                      # Optional: CODE_SERVER_PASSWORD
├── setup/
│   ├── setup.sh              # Updated with Node/Python
│   ├── nginx.conf
│   ├── code-server-config.yaml
│   └── Dockerfile
├── workspace/                # Host projects
└── .devcontainer/            # Optional
    └── devcontainer.json
```

---

## ✅ Ready to Use?

### Run:
```bash
docker-compose up --build
```

Access:
- 🔗 **code-server**: `https://localhost:8443`
- 📁 Open `/workspace` in VS Code
- 💻 Use terminal for `java`, `mvn`, `node`, `python`, `docker`, etc.

---

## 🔜 Next Enhancements (Optional)

Let me know if you'd like:
- [ ] Pre-installed VS Code extensions
- [ ] Support for Yarn / pnpm
- [ ] Jupyter Notebook integration
- [ ] Pre-configured virtual environments
- [ ] MongoDB/PostgreSQL
- [ ] Auto-import sample projects

---

Would you like me to **package this as a downloadable ZIP** or generate a **GitHub repository template**? I can prepare it for one-click deployment.
