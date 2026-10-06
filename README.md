# docker-opencode

Docker image equipped with AI tools, such as opencode, to be used as a [Pod of my homelab](https://github.com/mmontes11/k8s-ai/tree/main/apps/opencode)

## Features

- **CUDA 13.1**: Latest NVIDIA CUDA toolkit with Blackwell support
- **AI Models**: Configured with multiple LLM providers via Ollama and Llama.cpp
- **MCP Integration**: GitHub, Grafana, Kubernetes, and PhotoPrism MCP servers
- **Development Tools**: Go, Node.js, Python, essential CLI utilities, and [k8s-tooling](https://github.com/mmontes11/k8s-tooling)
- **Mermaid Diagrams**: Turnkey `mermaid-render` (mmdc) for rendering mermaid diagrams to SVG/PNG

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

## Mermaid diagrams

The image ships with [`mermaid-cli`](https://mermaid.js.org/intro/getting-started.html) (`mmdc`) and its headless Chromium runtime (Chromium shared libraries + the Puppeteer Chrome binary) so diagrams can be rendered without any extra setup. A default `--no-sandbox` Puppeteer config is baked in (required to run headless Chromium as a non-root user in a container).

Render a diagram with the turnkey wrapper (any extra flag is passed through to `mmdc`):

```bash
mermaid-render diagram.mmd                 # -> diagram.svg
mermaid-render -i diagram.mmd -o out.png   # PNG output
mermaid-render -i diagram.mmd -o out.svg -b transparent -s 2
```

## License

See [LICENSE](LICENSE) file for details.
