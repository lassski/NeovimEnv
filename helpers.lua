local M = {}

-- Safely quote shell arguments
local function shellQuote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

--- Check if a file or directory exists
function M.exists(path)
    local ok, err, code = os.rename(path, path)

    if not ok and code == 13 then
        return true
    end

    return ok, err
end

--- Check if a directory exists
function M.isdir(path)
    return M.exists(path .. "/")
end

--- Execute shell command and handle errors
function M.execute(command)
    local success, reason, code = os.execute(command)

    if success ~= true and success ~= 0 then
        error(
            "Command failed: " .. command ..
            "\nReason: " .. tostring(reason) ..
            "\nCode: " .. tostring(code)
        )
    end
end

--- Find directory matching wildcard pattern
function M.finddir(pattern)
    local command =
        "find . -maxdepth 1 -type d -name " ..
        shellQuote(pattern) ..
        " -print -quit"

    local handle = io.popen(command)

    if not handle then
        return nil
    end

    local result = handle:read("*l")
    handle:close()

    return result
end

--- Install package using DESTDIR and create manifest
function M.installStaged(name, prefix, buildCommand)
    local stage = os.tmpname()
    os.remove(stage)

    local manifestDir = manifestPath
    local manifestFile = manifestDir .. "/" .. name .. ".manifest"

    local stagedPrefix = stage .. prefix

    M.execute("mkdir -p " .. shellQuote(stage))
    M.execute("mkdir -p " .. shellQuote(manifestDir))

    -- Build and install into staging directory
    M.execute(
        buildCommand ..
        " && make install DESTDIR=" .. shellQuote(stage)
    )

    if not M.isdir(stagedPrefix) then
        print("Staging installation failed: " .. name)
        print("Stage directory: " .. stage)
        print("Expected directory: " .. stagedPrefix)

        print("Actual staging contents:")

        os.execute(
            "find " .. shellQuote(stage) ..
            " -maxdepth 7 -print"
        )

        error("Staging installation failed: " .. name)
    end

    -- Generate manifest
    local tempManifest = stage .. ".manifest"

    M.execute(
        "find " .. shellQuote(stagedPrefix) ..
        " \\( -type f -o -type l \\) -printf '%P\\n' | sort > " ..
        shellQuote(tempManifest)
    )

    -- Check for existing files
    local checkCommand =
        "while IFS= read -r file; do " ..
        "target=" .. shellQuote(prefix) .. "/\"$file\"; " ..
        "if [ -e \"$target\" ] || [ -L \"$target\" ]; then " ..
        "echo \"Existing file: $target\"; " ..
        "exit 1; " ..
        "fi; " ..
        "done < " .. shellQuote(tempManifest)

    local success = os.execute(checkCommand)

    if success ~= true and success ~= 0 then
        os.execute("rm -rf -- " .. shellQuote(stage))
        os.remove(tempManifest)

        error(
            "Installation would overwrite existing files: " .. name
        )
    end

    -- Save manifest before copying files
    M.execute(
        "mv " .. shellQuote(tempManifest) .. " " ..
        shellQuote(manifestFile)
    )

    -- Copy staged files to final destination
    M.execute(
        "mkdir -p " .. shellQuote(prefix) ..
        " && cp -a " .. shellQuote(stagedPrefix) .. "/. " ..
        shellQuote(prefix) .. "/"
    )

    -- Clean staging directory
    M.execute("rm -rf -- " .. shellQuote(stage))

    print("Successfully installed: " .. name)
end

--- Remove package using its manifest
function M.removeManifest(name, prefix)
    local manifestFile =
        manifestPath .. "/" .. name .. ".manifest"

    local file = io.open(manifestFile, "r")

    if not file then
        print("Manifest not found: " .. manifestFile)
        return
    end

    local root = prefix:gsub("/+$", "") .. "/"
    local failed = false

    for relativePath in file:lines() do
        local unsafe =
            relativePath == ".."
            or relativePath:sub(1, 3) == "../"
            or relativePath:find("/../", 1, true)
            or relativePath:sub(-3) == "/.."

        if relativePath ~= ""
            and relativePath:sub(1, 1) ~= "/"
            and not unsafe then

            local fullPath = root .. relativePath
            local success, err = os.remove(fullPath)

            if not success then
                -- Missing files are harmless
                if M.exists(fullPath) then
                    print("Failed to remove: " .. fullPath)
                    print(err)
                    failed = true
                end
            end
        else
            print("Skipping unsafe path: " .. relativePath)
            failed = true
        end
    end

    file:close()

    if not failed then
        os.remove(manifestFile)
        print("Successfully uninstalled: " .. name)
    else
        print("Uninstall incomplete: " .. name)
        print("Manifest retained for retry.")
    end
end

return M