local sqlite = require("ljsqlite3")
local scm = require("mru.scm")

local M = {}

function M.init_db()
    if vim.g.mru_db_path == nil then
        return
    end

    local conn = sqlite.open(vim.g.mru_db_path)
    conn:exec("CREATE TABLE IF NOT EXISTS mru_list(path TEXT PRIMARY KEY, root TEXT, ts INTEGER, freq INTEGER);")
    conn:close()
end

local function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

function M.add(path)
    if vim.g.mru_db_path == nil
        then return
    end

    if path == nil or path == "" then
        path = vim.api.nvim_buf_get_name(0)
    end
    if not file_exists(path) then
        return
    end

    local conn = sqlite.open(vim.g.mru_db_path)

    local ts = 0
    do
        local t = conn:exec("SELECT path, IFNULL(MAX(ts), 0) FROM mru_list")
        if t ~= nil then
            local tmp = tostring(t[2][1]):gsub("LL", "")
            ts = tonumber(tmp)

            local p = t[1][1]
            if p ~= path then
                ts = ts + 1
            end
        end
    end

    local freq = 0
    do
        local t = conn:exec("SELECT freq FROM mru_list WHERE path LIKE '%" .. path .."';")
        if t ~= nil then
            local tmp = tostring(t[1][1]):gsub("LL", "")
            freq = tonumber(tmp)
        end
        freq = freq + 1
    end

    local proj_root = scm.get_repo_root(path)
    conn:exec("INSERT OR REPLACE INTO mru_list VALUES ('" .. path ..
               "', '" .. proj_root ..
               "', '" .. ts ..
               "', '" .. freq ..
               "');")
    conn:close()
end

function M.del(path)
    if vim.g.mru_db_path == nil then
        return
    end

    if path == nil then
        path = vim.api.nvim_buf_get_name(0)
    end
    local conn = sqlite.open(vim.g.mru_db_path)
    conn:exec("DELETE from mru_list WHERE path LIKE '%" .. path .. "';")
    conn:close()
end

return M
