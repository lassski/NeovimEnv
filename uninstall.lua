require("variables")

-- Quote shell arguments safely
local function shellQuote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Remove files and directories
local function remove(path)
    if not path or path == "" then
        return
    end

    local command = "rm -rf -- " .. shellQuote(path)
    local success, reason, code = os.execute(command)

    if success ~= true and success ~= 0 then
        print("Failed to remove: " .. path)
        print(reason, code)
    end
end

-- Remove directories matching a wildcard pattern
local function removePattern(pattern)
    if not pattern or pattern == "" then
        return
    end

    local parent, name = pattern:match("^(.*)/([^/]*)$")

    if not name then
        parent = "."
        name = pattern
    end

    local command = "find "
        .. shellQuote(parent)
        .. " -mindepth 1 -maxdepth 1"
        .. " -type d"
        .. " -name "
        .. shellQuote(name)
        .. " -exec rm -rf -- {} +"

    local success, reason, code = os.execute(command)

    if success ~= true and success ~= 0 then
        print("Failed to remove directories matching: " .. pattern)
        print(reason, code)
    end
end

-- Remove a complete source line from a file
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
        print("Could not modify: " .. filePath)
        return
    end

    file:write(table.concat(lines, "\n"), "\n")
    file:close()
end

-- Uninstall Neovim
remove(installPrefix)
remove("./neovim") -- Git clone
remove(nvimSetupPath)
remove(nvimConfigPath)
remove(localSharePath)

removeLine(bashrcPath, ". " .. nvimSetupPath)

-- Uninstall fonts
-- remove(fontsPathDest)

-- Uninstall libevent
removePattern(libEventPath)

-- Uninstall ncurses
removePattern(ncursesPath)

-- Uninstall tmux
removePattern(tmuxPath)
remove(tmuxInstalledConfigFilePath)
