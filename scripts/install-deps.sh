#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

APT_FILE="scripts/apt.txt"

echo -e "${YELLOW}Installing Neovim dependencies...${NC}"

# Check if file exists
if [[ ! -f "$APT_FILE" ]]; then
    echo -e "${RED}Error: $APT_FILE not found${NC}"
    exit 1
fi

# Update package list first
echo "Updating package list..."
sudo apt update

# Read and process packages
missing_packages=()
while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    package=$(echo "$package" | xargs)
    
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
        echo "Package $package is not installed"
        missing_packages+=("$package")
    else
        echo "✓ $package is already installed"
    fi
done < "$APT_FILE"

if [[ ${#missing_packages[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Installing missing packages: ${missing_packages[*]}${NC}"
    sudo apt install -y "${missing_packages[@]}"
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
else
    echo -e "${GREEN}All dependencies are already installed!${NC}"
fi
