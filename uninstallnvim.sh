#! /usr/bin/bash
rm -rf $HOME/neovim
rm -f "$HOME/nvimsetup.sh"
sed -i 's|. '"$HOME"'/nvimsetup.sh||g' ~/.bashrc
