# Base Image: CUDA 13.1 Devel for Blackwell support
FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

# Build Arguments for version control
ARG UV_VERSION=0.11.11
ARG GOLANG_VERSION=1.27.1
ARG OPENCODE_VERSION=1.18.35
ARG MULTICA_VERSION=0.6.1
ARG CLAUDE_VERSION=2.1.292
ARG K8S_TOOLING_VERSION=0.79.0
ARG MERMAID_CLI_VERSION=12.0.0

# Environment
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    SHELL=/bin/bash \
    EDITOR=vim \
    GOPATH=/home/mmontes/go \
    PATH="/home/mmontes/.opencode/bin:/home/mmontes/.local/bin:/home/mmontes/usr/local/go/bin:/home/mmontes/go/bin:/home/mmontes/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install System Essentials, including the shared libraries required to run
# headless Chromium (used by mermaid-cli / mmdc to render mermaid diagrams).
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git git-lfs gh openssh-client mariadb-client \
    vim tmux jq htop ripgrep build-essential \
    unzip wget ca-certificates sudo libmagic1 ffmpeg rsync lsof \
    python3-dev libffi-dev libssl-dev gettext-base \
    libnss3 libnspr4 libatk1.0-0t64 libatk-bridge2.0-0t64 libatspi2.0-0t64 \
    libcups2t64 libdbus-1-3 libavahi-client3 libavahi-common3 \
    libdrm2 libgbm1 libxkbcommon0 libasound2t64 \
    libpango-1.0-0 libpangocairo-1.0-0 libcairo2 \
    libx11-6 libxau6 libxdmcp6 libxcb1 libxcb-render0 libxcb-shm0 \
    libxcomposite1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 \
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
RUN curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/v${K8S_TOOLING_VERSION}/kubernetes.sh | sudo K9S_SKIN=modus-vivendi bash -s - && sudo chown -R mmontes:mmontes /home/mmontes/.local

# Install Node
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    npm install -g @modelcontextprotocol/server-filesystem \
    # Install mermaid-cli (mmdc) for rendering mermaid diagrams to SVG/PNG.
    # Puppeteer downloads its headless Chromium to ~/.cache/puppeteer during this
    # step; it is baked into the runtime template so rendering is turnkey.
    npm install -g "@mermaid-js/mermaid-cli@${MERMAID_CLI_VERSION}"

# Install Astral UV
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION}

# Install Multica CLI
RUN ARCH=$(dpkg --print-architecture | sed 's/aarch64/arm64/') && \
    curl -fsSL "https://github.com/multica-ai/multica/releases/download/v${MULTICA_VERSION}/multica-cli-${MULTICA_VERSION}-linux-${ARCH}.tar.gz" -o /tmp/multica.tar.gz && \
    tar -xzf /tmp/multica.tar.gz -C /tmp multica && \
    sudo mv /tmp/multica /usr/local/bin/multica && \
    rm /tmp/multica.tar.gz

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash -s ${CLAUDE_VERSION}

# Install skills
COPY --chown=1111:1111 scripts/ /home/mmontes/scripts/
RUN chmod +x /home/mmontes/scripts/*.sh && \
    /bin/bash /home/mmontes/scripts/skills.sh

# Install mermaid diagram rendering: bake the default no-sandbox puppeteer
# config and a turnkey `mermaid-render` wrapper onto PATH so agents can render
# a diagram with a single command (e.g. `mermaid-render diagram.mmd`).
RUN install -d /home/mmontes/.config/mermaid /home/mmontes/.local/bin && \
    cp /home/mmontes/scripts/mermaid/puppeteer.json /home/mmontes/.config/mermaid/ && \
    install -m 0755 /home/mmontes/scripts/mermaid/mermaid-render /home/mmontes/.local/bin/

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
