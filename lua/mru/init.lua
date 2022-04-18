local dump = require("mru.dump")
local modify = require("mru.modify")
local scm = require("mru.scm")

local M = {}

M.init = modify.init
M.add = modify.add
M.del = modify.del
M.dump = dump.dump
M.get_project_root = scm.get_project_root

return M
