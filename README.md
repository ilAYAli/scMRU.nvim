<h1 align="center">scMRU - source control: Most Recently Used files</h1>

<h3 align="center">Telescope integrated per repo MRU/MFU</h3>
<br/><br/>

When working with multiple source repositories, it is often beneficial to have
one file cache per repository.
<br/>

Files are automatically added to the database and associated with the current
repository.<br/>
Untracked files are stored in the global cache.


:MruRepos                   |  MRU for untracked files
:-------------------------:|:-------------------------:
![](https://github.com/ilAYAli/scMRU/blob/main/media/repos.png)  |  ![](https://github.com/ilAYAli/scMRU/blob/main/media/global_mru.png)
MRU for neovim git repo    |  MRU for my neovim dotfiles
![](https://github.com/ilAYAli/scMRU/blob/main/media/nvim_repo.png)  |  ![](https://github.com/ilAYAli/scMRU/blob/main/media/nvim_conf_mru.png)


### Requirements
- [neovim >= 0.6](https://github.com/neovim/neovim)(required)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)


### Installation

### [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'ilAYAli/scMRU.nvim'
```

    sudo apt install sqlite3 libsqlite3-dev




### Usage

`:MruRepos`       Display cached repositories and bring up the associated cache
<br/>
`:Mru`                Display *most recently used* files for the current repo (cwd)
<br/>
`:Mfu`                Display *most frequently* used files for the current repo (cwd)
<br/>
`:MruAdd`           Explicity add a file from the database
<br/>
`:MruDel`           Explicity remove a filename from database

</br>
It is also possible to invoke the lua functions directly and supply optional parameters.
</br>
This will e.g display the global MFU:

```lua
lua require("mru").display_cache({root="__global__",algorithm="mfu"})
```


### Keymap example
```lua
vim.api.nvim_set_keymap('n', '<F1>',    "<Cmd>MruRepos<CR>", opts)
vim.api.nvim_set_keymap('n', '<F2>',    "<Cmd>Mru<CR>", opts)
vim.api.nvim_set_keymap('n', '<F3>',    "<Cmd>Mfu<CR>", opts)
```

### Todo
 * Support other SCM's (svn, mercurial, ...)
 * Improve configurability
 * Windows support
