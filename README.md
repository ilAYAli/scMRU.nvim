<h1 align="center">scMRU - source control: Most Recently Used files</h1>

<h3 align="center">Telescope integrated per repo MRU/MFU</h3>
<br/><br/>
<br/><br/>

When working with multiple source repositories, it is often beneficial to have
one file cache per repository.

* Files are automatically added to the database and associated with the current
repository.<br/>
Untracked files are stored in the global cache.

Type `:MruRepos` to get a selection of repositories with an associated cache.

This brings up a list of cached files for the selected repository.

Type `:Mru` to get a list of the *most recently used* files for the current repository
(or global cache if cwd is not a tracked directory)

Type `:Mfu` to get a list of the *most frequently used* files.


:MruRepos                   |  MRU global cache
:-------------------------:|:-------------------------:
![](https://github.com/ilAYAli/scMRU/blob/main/media/repos.png)  |  ![](https://github.com/ilAYAli/scMRU/blob/main/media/global_mru.png)
MRU repo #1                |  MRU repo #2
![](https://github.com/ilAYAli/scMRU/blob/main/media/this_repo_mru.png)  |  ![](https://github.com/ilAYAli/scMRU/blob/main/media/nvim_conf_mru.png)


### Requirements
    nvim >= 0.6


### Installation
    git clone https://github.com/stepelu/lua-ljsqlite3.git lua/mru/deps/
    git clone https://github.com/stepelu/lua-xsys.git lua/mru/deps/

    sudo apt install sqlite3 libsqlite3-dev


### Usage
* **MruRepos**      display a selection of cached repositories
* **Mru**           display most recently used files for the current repo (cwd)
* **Mfu**           display most frequently used files for the current repo (cwd)
* **MruAdd**        explicity add a file from the database
* **MruDel**        explicity remove a filename from database

It is possible to invoke the lua functions directly and supply optional parameters.
To e.g display the global MRU from within a git repo:

    lua require("mru").display({root="__global__"})


### Keymap example
    vim.api.nvim_set_keymap('n', '<F1>',    "<Cmd>MruRepos<CR>", opts)
    vim.api.nvim_set_keymap('n', '<F2>',    "<Cmd>Mru<CR>", opts)
    vim.api.nvim_set_keymap('n', '<F3>',    "<Cmd>Mfu<CR>", opts)

### Todo
 * Support other SCM's (svn, mercurial, ...)
 * Improve configurability
 * Windows support
