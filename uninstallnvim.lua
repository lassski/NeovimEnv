require("variables")

os.remove(installPrefix)
os.remove(nvimSetupPath)
os.execute("sed -i 's|. " .. nvimSetupPath .. "||g' " .. bashrcPath)