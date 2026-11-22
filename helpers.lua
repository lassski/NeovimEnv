local M = {}

--- Check if a file or directory exists in this path
function M.exists(file)
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
function M.isdir(path)
   -- "/" works on both Unix and Windows
   return M.exists(path.."/")
end

function M.execute(command)
   local success, reason, code = os.execute(command)

   if success ~= true and success ~= 0 then
       error("Command failed: " .. command ..
           "\nReason: " .. tostring(reason) ..
           "\nCode: " .. tostring(code))
   end
end

function M.finddir(pattern)
    local command = "find . -maxdepth 1 -type d -name '"
        .. pattern
        .. "' -print -quit"

    local handle = io.popen(command)
    if not handle then
        return nil
    end

    local result = handle:read("*l")
    handle:close()

    return result
end

return M