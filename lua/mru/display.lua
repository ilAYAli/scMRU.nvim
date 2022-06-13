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

    local db_root = ""
    if opts.root ~= nil then
        db_root = util.shrink_path(opts.root)
    else
        local tmp = scm.get_canonical_repo_root()
        if tmp == nil or tmp == "" then
            db_root = "__global__"
        else
            db_root = util.shrink_path(tmp)
        end
    end

    local conn = sqlite.open(vim.g.mru_db_path)

    local ret = nil
    if opts.algorithm == "mfu" then
        ret = conn:exec("SELECT * FROM mru_list WHERE root LIKE '" .. db_root .. "' ORDER BY freq DESC;")
    else
        ret = conn:exec("SELECT * FROM mru_list WHERE root LIKE '" .. db_root .. "' ORDER BY ts DESC;")
    end

    conn:close()
    if ret == nil or ret == "" then
        return
    end

    local files = {}
    for _, rel_path in ipairs(ret["file"]) do
        if not util.ends_with(vim.api.nvim_buf_get_name(0), rel_path) and util.exists(rel_path) then
            table.insert(files, rel_path)
        end
    end

    local title = "scMRU"
    if opts.algorithm == "mfu" then
        title = "scMFU"
    end
    pickers.new(opts, {
        prompt_title = "[" .. title ..": " .. db_root .. " ]",
        finder = finders.new_table {
            results = files,
            entry_maker = make_entry.gen_from_file(opts)
        },
        sorter = sorters.fuzzy_with_index_bias({}),
        previewer = conf.file_previewer(opts),
        --shorten_path = true,
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
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()[1]
                if selection ~= "__global__" then
                    vim.api.nvim_set_current_dir(selection)
                end
                -- todo: only remove current telescope opts
                opts = {}
                opts.root = selection
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
    for _, rel_dir in ipairs(ret["root"]) do
        local abs_path = util.expand_path(rel_dir)
        if abs_path == "__global__" or util.isdir(abs_path) then
            table.insert(t, rel_dir)
        else
            print("removing dead repo:", abs_path)
            alter.del(abs_path)
        end
    end

    repos(require("telescope.themes").get_dropdown{}, t)
end


return M
