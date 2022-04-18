# scMRU - source control: Most Recently Used files.

* Telescope integrated per repo MRU

When working with multiple source repositories, it is often beneficial to have
one MRU per repository.
Just cd to the project root, and type `:Mru` or invoke the respective keybinding.

All files that do not belong to a repository will be added to a global MRU, so
typing `:Mru` outside a repository brings up the shared MRU.


MRU repo #1                |  MRU repo #2
:-------------------------:|:-------------------------:
![](https://github.com/ilAYAli/scMRU/blob/main/media/this_repo_mru.png)  |  ![](https://github.com/ilAYAli/scMRU/blob/main/media/nvim_conf_mru.png)

![](https://github.com/ilAYAli/scMRU/blob/main/media/global_mru.png)


### Installation
    git clone https://github.com/stepelu/lua-ljsqlite3.git lua/mru/deps/
    git clone https://github.com/stepelu/lua-xsys.git lua/mru/deps/

    sudo apt install sqlite3 libsqlite3-dev


### Usage
* **Mru**        display relevant MRU
* **MruAdd**     explicity add filename to MRU
* **MruDel**     explicity delete filename from MRU
* **MruRoot**    print current repository root


### Keymap example
    vim.api.nvim_set_keymap('n', '<F1>',    "<Cmd>Mru<CR>", opts)

### Todo
 * configurability (optionally disable devicons, colors, ...)
