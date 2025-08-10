# Remove the incorrect symlink
rm ~/.config/nvim

# Create the correct symlink
ln -s ~/Desktop/nvim-config/nvim ~/.config/nvim

# Verify it's correct now
ls -la ~/.config/nvim
