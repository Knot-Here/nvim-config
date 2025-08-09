#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Setting up Neovim configuration..."

# Backup existing config if it exists
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "Backing up existing nvim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Remove existing symlink if it exists
if [ -L "$HOME/.config/nvim" ]; then
    rm "$HOME/.config/nvim"
fi

# Create symlink
ln -s "$PWD/nvim" "$HOME/.config/nvim"

echo -e "${GREEN}Neovim configuration installed successfully!${NC}"
echo "You may need to install plugins when you first open Neovim."
