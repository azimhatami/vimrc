# vimrc

# Step 1: Clone your repository and navigate into it
# Replace YOUR_USERNAME and YOUR_REPO_NAME with your own details
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git ~/.dotfiles/vim
cd ~/.dotfiles/vim

# Step 2: Run the prerequisite installer script
chmod +x install_prereqs.sh
./install_prereqs.sh

# Step 3: Link the vimrc to your home directory
# This backs up your existing vimrc, if any
mv -f ~/.vimrc ~/.vimrc.bak 2>/dev/null || true
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc

echo "✅ Setup complete. Now open Vim and run the commands from the next step."


## In vim commands

" Step 1: Install all plugins
:PlugInstall

" Step 2: Install language server extensions for code completion
:CocInstall coc-pyright coc-tsserver coc-json coc-sh coc-docker coc-yaml coc-clangd
