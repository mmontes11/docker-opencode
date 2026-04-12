# docker-opencode

Docker image equipped with AI tools, such as opencode, to be used as a [Pod of my homelab](https://github.com/mmontes11/k8s-ai/tree/main/apps/opencode)

## Features

- **CUDA 13.1**: Latest NVIDIA CUDA toolkit with Blackwell support
- **AI Models**: Configured with multiple LLM providers via Ollama and Llama.cpp
- **MCP Integration**: GitHub, Grafana, Kubernetes, and PhotoPrism MCP servers
- **Development Tools**: Go, Node.js, Python, and essential CLI utilities

## Installation

```bash
docker pull mmontes11/opencode:1.3.13
```

## Running

```bash
docker run -d \
  --name opencode \
  -p 4096:4096 \
  mmontes11/opencode:1.3.13
```

Access the web interface at `http://localhost:4096`.

## Skills

Installed skills include:
- GitHub CLI
- Git commit
- GitHub issues
- GitOps knowledge (Flux CD)
- OpenAPI to application code
- Security best practices
- SQL optimization and code review
- Architectural decision records

## License

See [LICENSE](LICENSE) file for details.
