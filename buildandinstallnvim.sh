#!/usr/bin/bash

profile_path="$HOME/.profile"
nvim_bin_path="$HOME/neovim/bin"
nvim_profile_file="$HOME/.nvimprofile"

echo -n "export PATH=$PATH:$HOME/neovim/bin" > "$HOME/nvimsetup.sh"
echo -n ". $HOME/nvimsetup.sh" >> $HOME/.bashrc
chmod a+rwx "$HOME/nvimsetup.sh"
export PATH=$PATH:$HOME/neovim/bin
#sh $HOME/nvimsetup.sh
# echo "PATH=\$PATH:$HOME/neovim/bin" >> $HOME/.bashrc

#git clone https://github.com/neovim/neovim
#cd neovim
#rm -r build/  # clear the CMake cache
#make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
#make install

rm -f "$HOME/.nvimprofile"
touch "$HOME/.nvimprofile"
echo -n "PATH=$PATH:$nvim_bin_path" >> "$HOME/.nvimprofile"
#source "$HOME/.nvimprofile"



#if [ ! -e "$profile_path"]; then
#    touch "$profile_path"
#fi

