local util = require("mru.util")

local M = {}

local function get_parent(path)
    path = path:match("^(.*)/")
    if path == "" then
        path = "/"
    end
    return path
end

function M.get_canonical_repo_root(path)
    local cwd = vim.loop.cwd()

    if path == nil or path == "" then
        path = vim.api.nvim_buf_get_name(0)
        if path == nil or path == "" then
            return cwd
        end
    end

    local dir = path
    if not util.isdir(path) then
        dir = get_parent(path)
    end
    if dir ~= nil then
        vim.api.nvim_set_current_dir(dir)
    end

    local f = assert(io.popen("git rev-parse --show-toplevel 2>/dev/null"))
    local data = f:read("*a")
    f:close()

    vim.api.nvim_set_current_dir(cwd)
    local root = data:gsub("%s+", "")
    if root == nil or root == '' then
        return nil
    end
    return root
end

return M
