<h1 align="center">scMRU - source control: Most Recently Used files</h1>

<h3 align="center">Telescope integrated per repo MRU/MFU</h3>
<br/><br/>

When working with multiple source repositories, it is often beneficial to have
one file cache per repository.

Just cd to the project root, and type `:Mru` or invoke the respective keybinding.
Similarly, typing `:Mfu` brings up the most frequently used files.

All files that do not belong to a repository will be associated with a global cache,
so typing `:Mru` outside a repository brings up the global MRU.


MRU repo #1                |  MRU repo #2
:-------------------------:|:-------------------------:
![](https://github.com/ilAYAli/scMRU/blob/main/media/this_repo_mru.png)  |  ![](https://github.com/ilAYAli/scMRU/blob/main/media/nvim_conf_mru.png)

<h5 align="center">Global MRU</h5>
<p align="center">
  <img src="https://github.com/ilAYAli/scMRU/blob/main/media/global_mru.png" />
</p>



### Requirements
    nvim >= 0.5 ?


### Installation
    git clone https://github.com/stepelu/lua-ljsqlite3.git lua/mru/deps/
    git clone https://github.com/stepelu/lua-xsys.git lua/mru/deps/

    sudo apt install sqlite3 libsqlite3-dev


### Usage
* **Mru**        display most recently used files for repo
* **Mfu**        display most frequently used files for repo
* **MruAdd**     explicity add a file from the database
* **MruDel**     explicity remove a filename from database
* **MruRoot**    print current repository root

It is possible to invoke the lua functions directly and supply optional parameters.
To e.g display the global MRU from within a git repo:

    lua require("mru").dump({root="__global__"})


### Keymap example
    vim.api.nvim_set_keymap('n', '<F1>',    "<Cmd>Mru<CR>", opts)
    vim.api.nvim_set_keymap('n', '<F2>',    "<Cmd>Mfu<CR>", opts)

### Todo
 * Support other SCM's (svn, mercurial, ...)
 * Improve configurability
 * Windows support
