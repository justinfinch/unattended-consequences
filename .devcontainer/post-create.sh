#!/bin/bash
set -e

# Fix ownership on the claude-memory volume mount (created as root by Docker)
sudo chown -R vscode:vscode /home/vscode/.claude

# Install Claude Code (native installer)
curl -fsSL https://claude.ai/install.sh | bash

# Install Railway CLI (use npm as fallback if the shell installer fails)
if ! curl -fsSL https://railway.com/install.sh | bash; then
  echo "Railway shell installer failed, trying npm..."
  npm install -g @railway/cli
fi

# Ensure project scripts are executable
chmod +x loop.sh yolo.sh
