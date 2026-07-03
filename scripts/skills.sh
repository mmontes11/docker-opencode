#!/bin/bash

set -euo pipefail

echo "Installing mmontes skills..."

npx skills add "https://github.com/mmontes11/skills" -g -a opencode -a claude-code -y || true

# Format: "RepoURL|SkillName"
SKILLS=(
  "https://github.com/fluxcd/agent-skills|gitops-cluster-debug"
  "https://github.com/fluxcd/agent-skills|gitops-knowledge"
  "https://github.com/github/awesome-copilot|git-commit"
  "https://github.com/github/awesome-copilot|create-architectural-decision-record"
  "https://github.com/github/awesome-copilot|create-github-action-workflow-specification"
  "https://github.com/github/awesome-copilot|create-github-issues-feature-from-implementation-plan"
  "https://github.com/github/awesome-copilot|create-github-pull-request-from-specification"
  "https://github.com/github/awesome-copilot|create-readme"
  "https://github.com/github/awesome-copilot|gh-cli"
  "https://github.com/github/awesome-copilot|github-issues"
  "https://github.com/github/awesome-copilot|go-mcp-server-generator"
  "https://github.com/github/awesome-copilot|openapi-to-application-code"
  "https://github.com/github/awesome-copilot|prd"
  "https://github.com/github/awesome-copilot|refactor"
  "https://github.com/github/awesome-copilot|sql-code-review"
  "https://github.com/github/awesome-copilot|sql-optimization"
  "https://github.com/github/awesome-copilot|web-coder"
  "https://github.com/openai/skills|security-best-practices"
  "https://github.com/openai/skills|security-ownership-map"
  "https://github.com/openai/skills|security-threat-model"
  "https://github.com/vercel-labs/skills|find-skills"
)

# Optional: Clean up existing unwanted skills first
# npx skills remove --all -g -y

for entry in "${SKILLS[@]}"; do
  IFS="|" read -r repo skill_name <<< "$entry"
  echo "Installing skill '${skill_name}' from ${repo}..."
  
  npx skills add "$repo" --skill "$skill_name" -g -a opencode -a claude-code -y || true
  echo "Done!"
done

npx skills list -g || true