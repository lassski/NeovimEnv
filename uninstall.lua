require("variables")
local helpers = require("helpers")

-- Remove Neovim environment setup from .bashrc
local function removeLine(filePath, targetLine)
    local file = io.open(filePath, "r")

    if not file then
        return
    end

    local lines = {}

    for line in file:lines() do
        if line ~= targetLine then
            table.insert(lines, line)
        end
    end

    file:close()

    file = io.open(filePath, "w")

    if not file then
        error("Could not modify: " .. filePath)
    end

    file:write(table.concat(lines, "\n"), "\n")
    file:close()
end

-- Uninstall tmux and its dependencies
helpers.removeManifest("tmux", localInstallPath)
helpers.removeManifest("ncurses", localInstallPath)
helpers.removeManifest("libevent", localInstallPath)

-- Uninstall Neovim
helpers.removeManifest("neovim", installPrefix)

-- Remove Neovim configuration
-- Comment this out if you want to preserve your configuration
-- os.execute("rm -rf -- '" .. nvimConfigPath .. "'")

-- Remove Neovim environment setup
removeLine(bashrcPath, ". " .. nvimSetupPath)

os.remove(nvimSetupPath)

-- Remove tmux configuration
-- Comment this out if you want to preserve your configuration
-- os.remove(tmuxInstalledConfigFilePath)

print("****************** UNINSTALL COMPLETE ************************")
print("* Neovim, tmux, ncurses and libevent have been removed.      *")
print("***************************************************************")
