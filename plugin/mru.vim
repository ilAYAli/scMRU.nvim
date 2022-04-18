if exists('g:mru_loaded')
    finish
endif
let g:mru_loaded = 1
let g:mru_db_path = expand('<sfile>:p:h:h')

let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/mru/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

lua require("mru").init()

command! -nargs=0 Mru lua require("mru").dump()
command! -nargs=* MruAdd lua require("mru").add(<q-args>)
command! -nargs=* MruDel lua require("mru").del(<q-args>)
command! -nargs=* MruRoot lua print(require("mru").get_project_root())

augroup mru_autocmd
    autocmd!
    autocmd BufEnter * MruAdd
augroup END
