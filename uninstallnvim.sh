#! /usr/bin/bash
rm -rf $HOME/neovim
sed -i 's|'"$HOME"'/neovim/bin||g' ~/.profile
source ~/.profile