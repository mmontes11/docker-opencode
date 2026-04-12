# Base Image: CUDA 13.1 Devel for Blackwell support
FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

# Build Arguments for version control
ARG UV_VERSION=0.11.11
ARG GOLANG_VERSION=1.26.1
ARG OPENCODE_VERSION=1.3.13

# Environment
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    SHELL=/bin/bash \
    EDITOR=vim \
    GOPATH=/home/mmontes/go \
    PATH="/home/mmontes/.opencode/bin:/home/mmontes/.local/bin:/home/mmontes/usr/local/go/bin:/home/mmontes/go/bin:/home/mmontes/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install System Essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git git-lfs gh openssh-client \
    vim tmux jq htop ripgrep build-essential \
    unzip wget ca-certificates sudo libmagic1 rsync \
    python3-dev libffi-dev libssl-dev gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Create User and configure Sudo
RUN groupadd --gid 1111 mmontes \
    && useradd --uid 1111 --gid 1111 -m -s /bin/bash mmontes \
    && echo "mmontes ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/mmontes \
    && chmod 0440 /etc/sudoers.d/mmontes

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Switch context for tool installation
USER mmontes
WORKDIR /home/mmontes

# Code directory
RUN mkdir /home/mmontes/code

# Install Go
RUN mkdir -p ~/usr/local && \
    wget -q https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C ~/usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Install Node
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    npm install -g @modelcontextprotocol/server-filesystem

# Install Astral UV
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION}
RUN mkdir -p /home/mmontes/.config/opencode/skills /home/mmontes/scripts
COPY --chown=1111:1111 scripts/ /home/mmontes/scripts/
RUN chmod +x /home/mmontes/scripts/*.sh && \
    /bin/bash /home/mmontes/scripts/skills.sh

EXPOSE 4096

# Absolute path for Entrypoint to bypass PATH resolution issues entirely
ENTRYPOINT ["opencode", "web", "--port", "4096", "--hostname", "0.0.0.0", "--cors", "opencode.mmontes-internal.duckdns.org"]