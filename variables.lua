-- Home directory
home = assert(os.getenv("HOME"), "HOME environment variable is not set")

-- Neovim installation
installPrefix = home .. "/neovim"
pathExtension = installPrefix .. "/bin"
nvimSetupPath = home .. "/nvimsetup.sh"

-- Neovim configuration
nvimConfigPath = home .. "/.config/nvim"
nvimInitFile = "init.lua"
localSharePath = home .. "/.local/share/nvim"

-- Bash configuration
bashrcPath = home .. "/.bashrc"

-- Font installation
fontsPathOrigin = "./fonts"
fontsPathDest = home .. "/.local/share/fonts"

-- Local package installation
localInstallPath = home .. "/.local"
ldLibPath = localInstallPath .. "/lib"
localPkgConfigPath = localInstallPath .. "/lib/pkgconfig"

-- Source directories
libEventPath = "./libevent-*"
ncursesPath = "./ncurses-*"
tmuxPath = "./tmux-*"

-- Tmux configuration
tmuxConfigFilePath = "./.tmux.conf"
tmuxInstalledConfigFilePath = home .. "/.tmux.conf"

-- Installation manifests
manifestPath = localInstallPath .. "/share/install-manifests"