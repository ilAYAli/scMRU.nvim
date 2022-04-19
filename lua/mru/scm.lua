local M = {}

local function get_parent(path)
    path = path:match("^(.*)/")
    if path == "" then
        path = "/"
    end
    return path
end

function M.get_project_root(filename)
    local cwd = vim.loop.cwd()

    if filename == nil then
        filename = vim.api.nvim_buf_get_name(0)
    end

    if filename ~= nil then
        local dir = get_parent(filename)
        if dir ~= nil then
            vim.api.nvim_set_current_dir(dir)
        end
    end

    local f = assert(io.popen("git rev-parse --show-toplevel 2>/dev/null"))
    local data = f:read("*a")
    f:close()

    vim.api.nvim_set_current_dir(cwd)
    local root = data:gsub("%s+", "")
    if root == nil or root == '' then
        root = "__global__"
    end
    return root
end

return M
