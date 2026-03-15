# Base Image: CUDA 13.1 Devel for Blackwell support
FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

# Build Arguments
ARG UV_VERSION=0.10.10
ARG GOLANG_VERSION=1.26.1
ARG OPENCODE_VERSION=1.2.26
ARG USERNAME=mmontes
ARG USER_UID=1111
ARG USER_GID=$USER_UID

# Environment Setup
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    GOPATH=/home/${USERNAME}/go \
    PATH=/home/${USERNAME}/.local/bin:/home/${USERNAME}/.opencode/bin:/home/${USERNAME}/usr/local/go/bin:/home/${USERNAME}/go/bin:/home/${USERNAME}/.cargo/bin:/home/${USERNAME}/.npm-global/bin:$PATH \    
    OLLAMA_HOST="http://ollama:11434" 

# System Essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git git-lfs vim tmux jq htop ripgrep build-essential \
    unzip wget ca-certificates sudo libmagic1 rsync \
    python3-dev libffi-dev libssl-dev gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Create User 'mmontes'
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Node.js 22.x Runtime
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# --- Switch to mmontes for Home-based installations ---
USER $USERNAME
WORKDIR /home/${USERNAME}

# Create the dedicated code directory
RUN mkdir -p /home/${USERNAME}/code

# Install Isolated Go
RUN mkdir -p ~/usr/local && \
    wget -q https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C ~/usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Setup Node/NPM User Space & MCP
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    npm install -g @modelcontextprotocol/server-filesystem

# Install uv
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh

# Install OpenCode AI
RUN curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION}

# --- Copy Configuration Template ---
COPY --chown=${USER_UID}:${USER_GID} opencode.json /home/${USERNAME}/opencode.json

# --- Finalize template for Persistence Strategy ---
USER root

# Create the template to preserve the tools for the InitContainer sync
RUN mkdir -p /opt/template && \
    cp -rp /home/${USERNAME}/. /opt/template/ && \
    chown -R ${USER_UID}:${USER_GID} /opt/template

# Final Context
USER $USERNAME
EXPOSE 4096

# Entrypoint serves the workspace via OpenCode
ENTRYPOINT ["opencode", "serve", "--port", "4096", "--host", "0.0.0.0", "--workspace", "/home/mmontes"]