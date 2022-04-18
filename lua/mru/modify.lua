local sqlite = require("ljsqlite3")
local scm = require("mru.scm")

local M = {}

function M.init()
    local conn = sqlite.open(vim.g.mru_db_path .. "/mru.db")
    conn:exec("CREATE TABLE IF NOT EXISTS mru_list(path TEXT PRIMARY KEY, root TEXT, count INTEGER DEFAULT 0);")
    conn:close()
end

local function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

function M.add(path)
    if path == nil or path == "" then
        path = vim.api.nvim_buf_get_name(0)
    end
    if not file_exists(path) then
        return
    end

    local proj_root = scm.get_project_root(path)

    local conn = sqlite.open(vim.g.mru_db_path .. "/mru.db")
    local maxval = string.match(tostring(conn:exec("SELECT IFNULL(MAX(count), 0) FROM mru_list")[1][1]), "%d")
    conn:exec("INSERT OR REPLACE INTO mru_list VALUES ('" .. path .. "', '" .. proj_root .. "', '" .. maxval .. "');")
    conn:exec("UPDATE mru_list SET count = (SELECT IFNULL(MAX(count) +1, 0) FROM mru_list) WHERE path = '" ..path .. "';")
    conn:close()
end

function M.del(path)
    print("path:", path)
    if path == nil then
        path = vim.api.nvim_buf_get_name(0)
    end
    local conn = sqlite.open(vim.g.mru_db_path .. "/mru.db")
    conn:exec("DELETE from mru_list WHERE path LIKE '%" .. path .. "';")
    conn:close()
end

return M
