#!/bin/bash

# clean-install.sh - Complete Neovim cleanup script
# This script removes ALL Neovim installations and configurations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧹 Neovim Complete Clean Install Script${NC}"
echo "This will remove ALL Neovim installations and configurations!"
echo ""
echo "What will be removed:"
echo "  • Snap Neovim installation"
echo "  • APT Neovim installation"
echo "  • All Neovim configuration files (~/.config/nvim)"
echo "  • All Neovim data files (~/.local/share/nvim)"
echo "  • All Neovim state files (~/.local/state/nvim)"
echo "  • All Neovim cache files (~/.cache/nvim)"
echo "  • Bash command cache for nvim"
echo ""

# Confirmation prompt
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 1
fi

echo -e "${RED}Starting cleanup...${NC}"

# Remove snap installation
echo "Removing snap Neovim installation..."
if snap list nvim &>/dev/null; then
    sudo snap remove nvim
    echo -e "${GREEN}✓ Snap nvim removed${NC}"
else
    echo "✓ No snap nvim installation found"
fi

# Remove apt installation
echo "Removing APT Neovim installation..."
if dpkg -l | grep -q neovim; then
    sudo apt remove --purge neovim -y
    sudo apt autoremove -y
    echo -e "${GREEN}✓ APT neovim removed${NC}"
else
    echo "✓ No APT neovim installation found"
fi

# Remove configuration files
echo "Removing Neovim configuration files..."
if [ -d "$HOME/.config/nvim" ]; then
    if [ -L "$HOME/.config/nvim" ]; then
        rm "$HOME/.config/nvim"
        echo -e "${GREEN}✓ Removed symlink ~/.config/nvim${NC}"
    else
        rm -rf "$HOME/.config/nvim"
        echo -e "${GREEN}✓ Removed directory ~/.config/nvim${NC}"
    fi
else
    echo "✓ No ~/.config/nvim found"
fi

# Remove data files
echo "Removing Neovim data files..."
if [ -d "$HOME/.local/share/nvim" ]; then
    rm -rf "$HOME/.local/share/nvim"
    echo -e "${GREEN}✓ Removed ~/.local/share/nvim${NC}"
else
    echo "✓ No ~/.local/share/nvim found"
fi

# Remove state files
echo "Removing Neovim state files..."
if [ -d "$HOME/.local/state/nvim" ]; then
    rm -rf "$HOME/.local/state/nvim"
    echo -e "${GREEN}✓ Removed ~/.local/state/nvim${NC}"
else
    echo "✓ No ~/.local/state/nvim found"
fi

# Remove cache files
echo "Removing Neovim cache files..."
if [ -d "$HOME/.cache/nvim" ]; then
    rm -rf "$HOME/.cache/nvim"
    echo -e "${GREEN}✓ Removed ~/.cache/nvim${NC}"
else
    echo "✓ No ~/.cache/nvim found"
fi

# Remove snap-specific data if it exists
echo "Removing snap-specific data..."
if [ -d "$HOME/snap/nvim" ]; then
    rm -rf "$HOME/snap/nvim"
    echo -e "${GREEN}✓ Removed ~/snap/nvim${NC}"
else
    echo "✓ No ~/snap/nvim found"
fi

# Clear bash command cache
echo "Clearing bash command cache..."
hash -d nvim 2>/dev/null || true
hash -r
echo -e "${GREEN}✓ Bash cache cleared${NC}"

# Check for any remaining nvim binaries
echo ""
echo "Checking for any remaining nvim installations..."
if command -v nvim &>/dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: nvim command still found at: $(which nvim)${NC}"
    echo "You may need to restart your terminal or check for other installations."
else
    echo -e "${GREEN}✓ No nvim command found - cleanup complete${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Neovim cleanup completed!${NC}"
echo ""
echo "Next steps to reinstall:"
echo "1. Restart your terminal"
echo "2. Install Neovim:"
echo "   • For snap: sudo snap install nvim --classic"
echo "   • For apt:  sudo apt install neovim"
echo "3. Run your install.sh script to restore configuration"
echo ""
echo -e "${YELLOW}Note: You may need to restart your terminal for PATH changes to take effect.${NC}"
