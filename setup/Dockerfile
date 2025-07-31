FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Create coder user with sudo privileges
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    zip \
    unzip \
    net-tools \
    iputils-ping \
    dnsutils \
    openssl \
    gnupg2 \
    procps \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Create coder user
RUN useradd -m -s /bin/bash coder && \
    echo "coder:coder" | chpasswd && \
    usermod -aG sudo coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    usermod -aG docker coder && \
    rm get-docker.sh

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install SDKMAN
USER coder
WORKDIR /home/coder

RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source ~/.sdkman/bin/sdkman-init.sh"

# Create necessary directories
RUN mkdir -p /home/coder/setup /home/coder/certs /home/coder/sites

# Copy setup files
COPY --chown=coder:coder setup.sh /home/coder/setup/
COPY --chown=coder:coder minimal-setup.sh /home/coder/setup/
COPY --chown=coder:coder nginx.conf /home/coder/sites/
COPY --chown=coder:coder code-server-config.yaml /home/coder/setup/

# Make setup script executable
RUN chmod +x /home/coder/setup/setup.sh /home/coder/setup/minimal-setup.sh

# Expose ports
EXPOSE 80 8080 8443

# Set working directory
WORKDIR /workspace

# Start the setup script
CMD ["/home/coder/setup/setup.sh"]
