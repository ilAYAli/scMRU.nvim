local M = {}

-- should be called with canonical path
function M.exists(path)
    if path == nil or path == "" then
        return false
    end
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok, err
end

-- should be called with canonical path
function M.isdir(path)
    if path == nil or path == "" then
        return false
    end
    return M.exists(path.."/")
end

function M.starts_with(text, prefix)
    return text:find(prefix, 1, true) == 1
end

function M.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function M.shrink_path(path, prefix)
    if prefix ~= nil then
        if M.starts_with(path, prefix) then
            return path:sub(string.len(prefix) +2)
        end
        return path
    end

    prefix = os.getenv("HOME")
    if M.starts_with(path, prefix) then
        return "~" .. path:sub(string.len(prefix) +1)
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
