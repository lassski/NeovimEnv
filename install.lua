require("variables")
local helpers = require("helpers")

-- Check if needed paths exist
local paths = {
    libEventPath,
    ncursesPath,
    tmuxPath
}

for i, path in ipairs(paths) do
    local foundPath = helpers.finddir(path:match("[^/]+$"))

    if not foundPath then
        error("Hakemistoa ei löydy: " .. path)
    end

    paths[i] = foundPath
    print("Found source directory: " .. foundPath)
end

libEventPath = paths[1]
ncursesPath = paths[2]
tmuxPath = paths[3]

-- TMUX and prerequisites
local command =
    "cd " .. libEventPath ..
    " && ./configure --prefix=" .. localInstallPath ..
    " --enable-shared" ..
    " && make"

helpers.installStaged(
    "libevent",
    localInstallPath,
    command
)

command =
    "cd " .. ncursesPath ..
    " && ./configure --prefix=" .. localInstallPath ..
    " --with-shared --with-termlib --enable-pc-files --without-cxx-binding" ..
    " --with-pkg-config-libdir=" .. localPkgConfigPath ..
    " && make"

helpers.installStaged(
    "ncurses",
    localInstallPath,
    command
)

command =
    "cd " .. tmuxPath ..
    " && PKG_CONFIG_PATH=" .. localPkgConfigPath ..
    " ./configure --prefix=" .. localInstallPath ..
    " && make"

helpers.installStaged(
    "tmux",
    localInstallPath,
    command
)

-- Fonts
command = "mkdir -p "
	.. fontsPathDest
	.. " && "
	.. "cp "
	.. fontsPathOrigin
	.. "/*.ttf "
	.. fontsPathDest
	.. " && "
	.. "fc-cache"

helpers.execute(command)

-- Määritellään muuttujia polkujen ja git-repon kanssa
local repoURL = "https://github.com/neovim/neovim"
local cloneDirectory = "./neovim-src"

local cloneExists = helpers.isdir(cloneDirectory)
if not cloneExists then
	helpers.execute("git clone " .. repoURL .. " " .. cloneDirectory)
else
	print("neovim git clone exists so we don't have download it.")
end

command =
    "cd " .. cloneDirectory ..
    " && make CMAKE_BUILD_TYPE=RelWithDebInfo" ..
    ' CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=' ..
    installPrefix .. '"' 

helpers.installStaged(
    "neovim",
    installPrefix,
    command
)

-- Luodaan nvimsetup.sh ja kirjoitetaan sinne PATHin päivityskomento
local nvimSetupFile = io.open(nvimSetupPath, "w") -- "w" avaa tiedoston kirjoitusta varten, olettaen sen luomista
if nvimSetupFile then
	nvimSetupFile:write(
    "export PATH=$PATH:" .. pathExtension .. "\n"
    .. "export LD_LIBRARY_PATH="
    .. ldLibPath
    .. ":$LD_LIBRARY_PATH\n")
	nvimSetupFile:close()
else
	print("Tiedoston luonti epäonnistui: " .. nvimSetupPath)
end

local lineToAdd = ". " .. nvimSetupPath

-- Create .bashrc if it doesn't exist
local file = io.open(bashrcPath, "a")

if not file then
    error("Could not create or open: " .. bashrcPath)
end

file:close()

-- Read .bashrc contents
local contents = {}

file = io.open(bashrcPath, "r")

if not file then
    error("Could not read: " .. bashrcPath)
end

for line in file:lines() do
    table.insert(contents, line)
end

file:close()

-- Check if setup line already exists
local lineToAdd = ". " .. nvimSetupPath
local lineExists = false

for _, line in ipairs(contents) do
    if line == lineToAdd then
        lineExists = true
        break
    end
end

-- Add setup line if missing
if not lineExists then
    file = io.open(bashrcPath, "a")

    if not file then
        error("Could not modify: " .. bashrcPath)
    end

    file:write("\n" .. lineToAdd .. "\n")
    file:close()
end

-- Tarkistetaan, sisältääkö sisältö jo kyseisen rivin
local lineExists = false
for _, line in ipairs(contents) do
	if line == lineToAdd then
		lineExists = true
		break
	end
end

-- Jos riviä ei ole, lisätään se loppuun
if not lineExists then
	local file = io.open(bashrcPath, "a") -- Avataan tiedosto lisäystä varten
	if file then
		file:write("\n" .. lineToAdd) -- Huomaa, että lisäämme rivinvaihdon ennen rivin lisäystä
		file:close()
	else
		print("Tiedoston avaaminen epäonnistui: " .. bashrcPath)
	end
end

-- copy init.lua file to where neovim finds it
-- command =   "rm -rf " .. nvimConfigPath .. " && " ..
--            "mkdir " .. nvimConfigPath .. " && " ..
--            "cp " .. nvimInitFile .. " " .. nvimConfigPath
command = "rm -rf " .. nvimConfigPath .. " && " .. "cp -r " .. "starter/. " .. nvimConfigPath
helpers.execute(command)

command = "cp " .. tmuxConfigFilePath .. " " .. home
helpers.execute(command)

-- Muutetaan nvimsetup.sh-tiedoston käyttöoikeuksia
helpers.execute("chmod 644 " .. nvimSetupPath)

-- Install rust
--helpers.execute("curl https://sh.rustup.rs -sSf | sh")

-- Päivittämään PATH ympäristömuuttujan nykyisessä Lua-prosessissa,
-- mutta tämä muutos ei ole pysyvä yli suorituskertojen
-- os.setenv ei ole suoraan käytettävissä Luassa, joten voi olla tarpeen käyttää ulkopuolisia kirjastoja tai pure Lua -ratkaisuja
print("****************** NEOVIM INSTALLED ***************************")
print('* Run ". ~/.bashrc" to get nvim-command to work right away. *')
print("***************************************************************")
