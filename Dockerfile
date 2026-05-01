# Base Image: CUDA 13.1 Devel for Blackwell support
FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

# Build Arguments for version control
ARG UV_VERSION=0.11.11
ARG GOLANG_VERSION=1.26.1
ARG OPENCODE_VERSION=1.14.24
ARG K8S_TOOLING_VERSION=0.19.0

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

# Install Docker client
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin docker-buildx-plugin && \
    rm -rf /var/lib/apt/lists/*

# Create User and configure sudo
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

# Home directories
RUN mkdir -p /home/mmontes/code /home/mmontes/scripts /home/mmontes/.config/opencode/skills 

# Install Go
RUN mkdir -p ~/usr/local && \
    wget -q https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C ~/usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Install k8s-tooling
RUN curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/v${K8S_TOOLING_VERSION}/kubernetes.sh | sudo bash -s -

# Install Node
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    npm install -g @modelcontextprotocol/server-filesystem

# Install Astral UV
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION}
COPY --chown=1111:1111 scripts/ /home/mmontes/scripts/
RUN chmod +x /home/mmontes/scripts/*.sh && \
    /bin/bash /home/mmontes/scripts/skills.sh

# Create the Persistence Template for initContainer sync
USER root
RUN mkdir -p /opt/template && \
    cp -rp /home/mmontes/. /opt/template/ && \
    chown -R 1111:1111 /opt/template

# Return to user and finalize runtime metadata
USER mmontes
WORKDIR /home/mmontes

EXPOSE 4096

ENTRYPOINT ["opencode", "web", "--port", "4096", "--hostname", "0.0.0.0", "--cors", "opencode.mmontes-internal.duckdns.org"]