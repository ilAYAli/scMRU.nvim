local display = require("mru.display")
local alter = require("mru.alter")
local scm = require("mru.scm")
local util = require("mru.util")

local M = {}

local function setup(opts)
    opts = opts or {}
    vim.g["mru_db_path"] = nil

    -- prefer $XDG_DATA_HOME/nvim
    local dir = os.getenv("XDG_DATA_HOME")
    if dir ~= nil then
        dir = dir .. "/nvim"
    else
        dir = os.getenv("HOME") .. "/.local/share/nvim"
    end

    -- fallback to ~/.cache
    if not util.isdir(dir) then
        dir = os.getenv("HOME") .. "/.cache"
    end

    if not util.isdir(dir) then
        error("error, unable to resolve database directory")
        return
    end

    vim.g["mru_db_path"] = dir .. "/scmru.sqlite3"
    alter.setup()
end

M.setup = setup
M.add = alter.add
M.del = alter.del
M.display_cache = display.display_cache
M.display_repos = display.display_repos
M.get_canonical_repo_root = scm.get_canonical_repo_root

return M
