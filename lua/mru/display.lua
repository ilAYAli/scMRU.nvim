local sqlite = require("ljsqlite3")
local scm = require("mru.scm")

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

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

local function expand_path(path)
    local home = os.getenv("HOME")
    if starts_with(path, "~") then
        return home .. path:sub(2)
    end
    return path
end


local function file_exists(name)
     local f = io.open(name, "r")
     return f ~= nil and io.close(f)
end

function M.display_cache(opts)
    if vim.g.mru_db_path == nil then
        return
    end

    opts = opts or { }

    local proj_root = scm.get_repo_root()
    if opts.root ~= nil then
        proj_root = expand_path(opts.root)
    end

    local conn = sqlite.open(vim.g.mru_db_path)

    local ret = nil
    if opts.algorithm == "mfu" then
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

    local title = "scMRU"
    if opts.algorithm == "mfu" then
        title = "scMFU"
    end
    pickers.new(opts, {
        prompt_title = "[" .. title ..": " .. shrink_path(proj_root) .. " ]",
        finder = finders.new_table {
            results = t,
            entry_maker = make_entry.gen_from_file(opts)
        },
        sorter = sorters.get_generic_fuzzy_sorter({}),
        previewer = conf.file_previewer(opts),
        shorten_path = true,
    }):find()
end


local repos = function(opts, t)
    local title = "Repositories"
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "[" .. title .."]",
        finder = finders.new_table {
            results = t,
            entry_maker = make_entry.gen_from_file(opts)
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- todo: only remove current telescope opts
                opts = {}
                vim.api.nvim_set_current_dir(selection[1])
                opts.root = expand_path(selection[1])
                M.display_cache(opts)
            end)
        return true
        end,
    }):find()
end

function M.display_repos(opts)
    if vim.g.mru_db_path == nil then
        return
    end

    opts = opts or { }

    local conn = sqlite.open(vim.g.mru_db_path)
    local ret = conn:exec("SELECT DISTINCT root FROM mru_list ORDER BY root;")
    conn:close()

    if ret == nil or ret == "" then
        return
    end

    local t = {}
    for _, item in ipairs(ret[1]) do
        table.insert(t, shrink_path(item))
    end

    repos(require("telescope.themes").get_dropdown{}, t)
end


return M
