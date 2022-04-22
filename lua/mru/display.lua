local sqlite = require("ljsqlite3")
local scm = require("mru.scm")
local alter = require("mru.alter")
local util = require("mru.util")

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

function M.display_cache(opts)
    if vim.g.mru_db_path == nil then
        return
    end

    opts = opts or { }

    local proj_root = scm.get_repo_root()
    if opts.root ~= nil then
        proj_root = util.expand_path(opts.root)
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
        if item ~= vim.api.nvim_buf_get_name(0) and util.exists(item) then
            table.insert(t, item)
        end
    end

    local title = "scMRU"
    if opts.algorithm == "mfu" then
        title = "scMFU"
    end
    pickers.new(opts, {
        prompt_title = "[" .. title ..": " .. util.shrink_path(proj_root) .. " ]",
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
                local path = util.expand_path(selection[1])
                print("path:", path)
                if util.isdir(path) then
                    vim.api.nvim_set_current_dir(path)
                    -- todo: only remove current telescope opts
                    opts = {}
                    opts.root = util.expand_path(path)
                    M.display_cache(opts)
                else
                    alter.del(path)
                end
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
        table.insert(t, util.shrink_path(item))
    end

    repos(require("telescope.themes").get_dropdown{}, t)
end


return M
