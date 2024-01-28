#! /usr/bin/bash
git clone https://github.com/neovim/neovim
cd neovim
rm -r build/  # clear the CMake cache
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
sed -i 's|'"$HOME"'/neovim/bin||g' ~/.profile
echo "PATH=$PATH:$HOME/neovim/bin" >> ~/.profile
source ~/.profile