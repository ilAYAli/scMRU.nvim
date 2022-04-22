local M = {}

function M.exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         return true
      end
   end
   return ok, err
end

function M.isdir(path)
   return M.exists(path.."/")
end

function M.starts_with(text, prefix)
    return text:find(prefix, 1, true) == 1
end

function M.shrink_path(path)
    local home = os.getenv("HOME")
    if M.starts_with(path, home) then
        return "~" .. path:sub(string.len(home) +1)
    end
    return path
end

function M.expand_path(path)
    local home = os.getenv("HOME")
    if M.starts_with(path, "~") then
        return home .. path:sub(2)
    end
    return path
end

return M
