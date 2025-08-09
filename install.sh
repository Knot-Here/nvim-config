#!/bin/bash
# setup.sh

echo "🚀 Setting up Neovim environment..."

# Install dependencies
bash scripts/install-deps.sh

# Setup configuration
bash scripts/setup-config.sh

echo "✨ Neovim setup complete!"
