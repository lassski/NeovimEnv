#! /usr/bin/bash

profile_path="$HOME/.bashrc"
nvim_bin_path="$HOME/neovim/bin"
nvim_profile_file="$HOME/.nvimprofile"

#git clone https://github.com/neovim/neovim
#cd neovim
#rm -r build/  # clear the CMake cache
#make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
#make install

rm -f "$HOME/.nvimprofile"
touch "$HOME/.nvimprofile"
echo "PATH=$PATH:$nvim_bin_path" >> "$HOME/.nvimprofile"
#source "$HOME/.nvimprofile"

if [ ! -e "$profile_path"]; then
    touch "$profile_path"
fi

#sed -i 's|'"$HOME"'/neovim/bin||g' ~/.profile
echo "source \"$HOME/.nvimprofile\"" >> ~/.bashrc
source ~/.bashrc

# if ! grep -q "$nvim_bin_path"
