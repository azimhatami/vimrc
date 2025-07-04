#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions for Colored Output ---
info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

# --- Check for Package Manager ---
if ! command -v apt-get &> /dev/null; then
    echo "Error: This script is designed for Debian/Ubuntu-based systems using APT."
    echo "Please adapt the package installation commands for your distribution (e.g., dnf, pacman)."
    exit 1
fi

# --- 1. Install System Dependencies ---
info "Updating package list..."
sudo apt-get update

info "Installing system packages (git, curl, nodejs, npm, fzf, clangd, ripgrep)..."
sudo apt-get install -y git curl nodejs npm fzf clangd ripgrep

# --- 2. Install vim-plug (Vim Plugin Manager) ---
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_PATH="$HOME/.vim/autoload/plug.vim"

if [ -f "$VIM_PLUG_PATH" ]; then
    info "vim-plug is already installed."
else
    info "Installing vim-plug..."
    curl -fLo "$VIM_PLUG_PATH" --create-dirs "$VIM_PLUG_URL"
fi

# --- Final Instructions ---
success "All prerequisites have been installed!"
echo ""
info "Next steps:"
info "1. Place your vimrc file at ~/.vimrc"
info "2. Open Vim and run the command: :PlugInstall"
info "3. After plugins are installed, run this command in Vim to install CoC extensions:"
echo "   :CocInstall coc-pyright coc-tsserver coc-json coc-sh coc-docker coc-yaml coc-clangd"
