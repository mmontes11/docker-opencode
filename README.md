# docker-ai-workspace

Docker image equipped with AI tools to be used as a [Pod of my homelab](https://github.com/mmontes11/k8s-ai/tree/main/infrastructure/workspace)

## Features

- **CUDA 13.1**: Latest NVIDIA CUDA toolkit with Blackwell support
- **AI Models**: Configured with multiple LLM providers via Ollama and Llama.cpp
- **MCP Integration**: GitHub, Grafana, Kubernetes, and PhotoPrism MCP servers
- **Development Tools**: Go, Node.js, Python, and essential CLI utilities

## Model Configuration

### Primary Models
- **qwen35-35b-ctx256k**: 256K context window for long-form analysis
- **gpt-oss:20b-ctx128k**: 128K context for balanced performance
- **qwen3-coder:30b**: Specialized for code generation and review

### Providers
- **Ollama**: `http://ollama.ai.svc.cluster.local:11434/v1`
- **Llama.cpp**: `http://llama-qwen35-35b-ctx256k.ai.svc.cluster.local:8080/v1`

## MCP Servers

| Server | Purpose |
|--------|---------|
| GitHub | Repository management and PR operations |
| Grafana | Monitoring and observability |
| Kubernetes | Cluster management and debugging |
| PhotoPrism mmontes | Personal photo library |
| PhotoPrism xiaowen | Shared photo library |

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
