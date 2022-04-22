local sqlite = require("ljsqlite3")
local scm = require("mru.scm")
local util = require("mru.util")

local M = {}

function M.setup(opts)
    opts = opts or {}
    if vim.g.mru_db_path == nil then
        return
    end

    local conn = sqlite.open(vim.g.mru_db_path)
    conn:exec("CREATE TABLE IF NOT EXISTS mru_list(root TEXT, file TEXT PRIMARY KEY, ts INTEGER, freq INTEGER);")
    conn:close()
end

function M.add(path)
    if vim.g.mru_db_path == nil
        then return
    end

    local abs_path = ""
    if path == nil or path == "" then
        abs_path = vim.api.nvim_buf_get_name(0)
    else
        abs_path = util.expand_path(path)
    end

    if not util.exists(abs_path) then
        return
    end

    local db_file = ""
    local db_root = scm.get_canonical_repo_root(abs_path)
    if db_root == nil then
        -- store canonical non-tracked file
        db_file = abs_path
        if not util.exists(db_file) then
            return
        end
        db_root = "__global__"
    else
        -- truncate canonical path according to canonical repo path
        db_file = util.shrink_path(abs_path, db_root)
        -- truncate db path
        db_root = util.shrink_path(db_root)
    end
    -- print("[+] add: root:", db_root, "path:", db_file)

    local conn = sqlite.open(vim.g.mru_db_path)

    local ts = 0
    do
        local t = conn:exec("SELECT file, IFNULL(MAX(ts), 0) FROM mru_list")
        if t ~= nil then
            local ts_tmp = tostring(t[2][1]):gsub("LL", "")
            ts = tonumber(ts_tmp)

            local p = t[1][1]
            if p ~= db_file then
                ts = ts + 1
            end
        end
    end

    local freq = 0
    do
        local t = conn:exec("SELECT freq FROM mru_list WHERE root == \""
                            .. db_root .. "\" AND file == \""
                            .. db_file .."\";")
        if t ~= nil then
            local tmp = tostring(t[1][1]):gsub("LL", "")
            freq = tonumber(tmp)
        end
        freq = freq + 1
    end

    conn:exec("INSERT OR REPLACE INTO mru_list VALUES ('"
               .. db_root .. "', '"
               .. db_file .. "', '"
               .. ts      .. "', '"
               .. freq    .. "');")
    conn:close()
end

function M.del(path)
    if vim.g.mru_db_path == nil then
        return
    end

    if path == nil then
        path = vim.api.nvim_buf_get_name(0)
    end

    local rel_path = util.shrink_path(path)
    local conn = sqlite.open(vim.g.mru_db_path)
    conn:exec("DELETE from mru_list WHERE file LIKE '%" .. rel_path .. "%';")
    conn:close()
end

return M
