#!/bin/bash

# Install JetBrainsMono Nerd Font (or specify another)
FONT="${1:-JetBrainsMono}"

# Download and install
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT.zip"
unzip -q "$FONT.zip"
rm "$FONT.zip"
fc-cache -fv

echo "Installed $FONT Nerd Font"
