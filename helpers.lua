--- Check if a file or directory exists in this path
function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          -- Permission denied, but it exists
          return true
       end
    end
    return ok, err
 end
 
 --- Check if a directory exists in this path
 function isdir(path)
    -- "/" works on both Unix and Windows
    return exists(path.."/")
 end

 local function execute(command)
    local success, reason, code = os.execute(command)

    if success ~= true and success ~= 0 then
        error("Command failed: " .. command ..
            "\nReason: " .. tostring(reason) ..
            "\nCode: " .. tostring(code))
    end
end