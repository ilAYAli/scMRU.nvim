local display = require("mru.display")
local alter = require("mru.alter")
local scm = require("mru.scm")

local M = {}

local function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         return true
      end
   end
   return ok, err
end

local function isdir(path)
   return exists(path.."/")
end

local function init()
    vim.g["mru_db_path"] = nil

    -- prefer $XDG_DATA_HOME/nvim
    local dir = os.getenv("XDG_DATA_HOME")
    if dir ~= nil then
        dir = dir .. "/nvim"
    else
        dir = os.getenv("HOME") .. "/.local/share/nvim"
    end

    -- fallback to ~/.cache
    if not isdir(dir) then
        dir = os.getenv("HOME") .. "/.cache"
    end

    if not isdir(dir) then
        error("error, unable to resolve database directory")
        return
    end

    vim.g["mru_db_path"] = dir .. "/scmru.sqlite3"
    alter.init_db()
end

M.init = init
M.add = alter.add
M.del = alter.del
M.display = display.display
M.get_project_root = scm.get_project_root

return M
