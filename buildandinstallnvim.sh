#! /usr/bin/bash

profile_path="$HOME/.profile"
nvim_bin_path="$HOME/neovim/bin"

git clone https://github.com/neovim/neovim
cd neovim
rm -r build/  # clear the CMake cache
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
if [ ! -e "$profile_path"]; then
    touch "$profile_path"
    echo "Created .profile-file."
else
    echo ".profile-file found."
fi
sed -i 's|'"$HOME"'/neovim/bin||g' ~/.profile
echo "PATH=$PATH:$nvim_bin_path" >> ~/.profile
source ~/.profile

if ! grep -q "$nvim_bin_path"
