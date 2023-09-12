local sqlite = require"sqlite"
local scm = require("mru.scm")
local util = require("mru.util")

local M = {}

function M.setup(opts)
    opts = opts or {}
    if vim.g.mru_db_path == nil then
        return
    end

    local db = sqlite:open(vim.g.mru_db_path, {})
    db:eval("CREATE TABLE IF NOT EXISTS mru_list(root TEXT, file TEXT PRIMARY KEY, ts INTEGER, freq INTEGER);")
end

-- lua require("mru").add('foo.lua')
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

    local db = sqlite:open(vim.g.mru_db_path, {})

    local ts = 0
    do
        local tab = db:eval("SELECT file, IFNULL(MAX(ts), 0) FROM mru_list")
        -- todo: refactor
        if tab ~= nil then
            for ret,t in pairs(tab) do
              for k, v in pairs(t) do
                if type(v) == 'number' then
                  ts = v
                end
              end
            end
            local p = tab[1].file
            if p ~= db_file then
                ts = ts + 1
            end
        end
    end

    local freq = 0
    do
        local s = "SELECT freq FROM mru_list WHERE root == \""
                            .. db_root .. "\" AND file == \""
                            .. db_file .."\";"
        local t = db:eval(s)
        -- increase frequency counter:
        if type(t) == 'table' then
            freq = t[1].freq;
        end
        freq = freq + 1
    end

    db:eval("INSERT OR REPLACE INTO mru_list VALUES ('"
               .. db_root .. "', '"
               .. db_file .. "', '"
               .. ts      .. "', '"
               .. freq    .. "');")
end

function M.del(path)
    if vim.g.mru_db_path == nil then
        return
    end

    if path == nil then
        path = vim.api.nvim_buf_get_name(0)
    end

    local rel_path = util.shrink_path(path)
    local db = sqlite:open(vim.g.mru_db_path, {})
    db:eval("DELETE from mru_list WHERE file LIKE '%" .. rel_path .. "%';")
end

return M
