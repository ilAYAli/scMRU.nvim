<h1 align="center">scMRU - source control: Most Recently Used files</h1>

<h3 align="center">Telescope integrated per repo MRU/MFU</h3>
<br/><br/>

scMRU automatically creates a Telescope integrated list of recently used files per git repository.
<br>
It also creates a single list for all non-tracked files to allow you to easily access all files in your file system.

The list of files can be access according to Most Recently Used (MRU) or Most Frequently Used (MFU).
<br/>

### Demo video

https://youtu.be/Q6VgtRD93pQ


### Demo images

:MruRepos                   |  MRU for untracked files
:-------------------------:|:-------------------------:
![](https://github.com/ilAYAli/scMRU.nvim/assets/1106732/120b9bb3-a8cf-483e-a467-b4a2cde83425)  |  ![](https://github.com/ilAYAli/scMRU.nvim/assets/1106732/0d5413b1-54f4-4db6-803c-5bbbdda573b6)


### Requirements
- [neovim >= 0.6](https://github.com/neovim/neovim)(required)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)


### Installation

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua

  {
    'ilAYAli/scMRU.nvim',
    dependencies = 'kkharji/sqlite.lua',
  },
```


#### Linux:

`sudo apt install sqlite3`


#### MacOS:

`brew install sqlite3`


#### Windows:
Download eg a precompiled version of sqlite3 from here: https://www.sqlite.org/download.html,
and set sqlite_clib_path according to the installation path with either:

lua:
```lua
vim.g.sqlite_clib_path = path/to/sqlite.dll
```

or vimscript:

```vimscript
let g:sqlite_clib_path = path/to/sqlite3.dll
```

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
This will e.g display the global MFU, Most Frequently Used files:

```lua
lua require("mru").display_cache({root="__global__",algorithm="mfu"})
```


### Keymap example
```lua
vim.keymap.set('n', '<F1>', function() require("mru").display_cache({}) end)
vim.keymap.set('n', '<F2>', function() require("mru").display_repose({}) end)
vim.keymap.set('n', '<F3>', function() require("mru").display_cache({algorithm="mfu"}) end)
```
