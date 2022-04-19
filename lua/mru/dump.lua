local sqlite = require("ljsqlite3")
local scm = require("mru.scm")

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values

local M = {}

local function starts_with(text, prefix)
    return text:find(prefix, 1, true) == 1
end

local function shrink_path(path)
    local home = os.getenv("HOME")
    if starts_with(path, home) then
        return "~" .. path:sub(string.len(home) +1)
    end
    return path
end

local function file_exists(name)
     local f = io.open(name, "r")
     return f ~= nil and io.close(f)
end

function M.dump(opt)
    local opts = opts or { }
    local proj_root = scm.get_project_root()
    local conn = sqlite.open(vim.g.mru_db_path .. "/mru.db")

    local ret = nil
    if opt.algorithm == "mfu" then
        ret = conn:exec("SELECT * FROM mru_list WHERE root LIKE '" .. proj_root .. "' ORDER BY freq DESC;")
    else
        ret = conn:exec("SELECT * FROM mru_list WHERE root LIKE '" .. proj_root .. "' ORDER BY ts DESC;")
    end

    conn:close()
    if ret == nil or ret == "" then
        return
    end

    local t = {}

    for _, item in ipairs(ret[1]) do
        if item ~= vim.api.nvim_buf_get_name(0) and file_exists(item) then
            table.insert(t, item)
        end
    end

    pickers.new(opts, {
        prompt_title = "[scMRU: " .. shrink_path(proj_root) .. " ]",
        finder = finders.new_table {
            results = t,
            entry_maker = make_entry.gen_from_file(opts)
        },
        sorter = sorters.get_generic_fuzzy_sorter({}),
        previewer = conf.file_previewer(opts),
        shorten_path = true,
    }):find()
end


return M
