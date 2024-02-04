require("variables")

os.execute("rm -rf " .. installPrefix)
os.execute("rm -rf " .. nvimSetupPath)
os.execute("rm -rf " .. nvimConfigPath)
os.execute("rm -rf " .. localSharePath)
os.execute("sed -i 's|. " .. nvimSetupPath .. "||g' " .. bashrcPath)