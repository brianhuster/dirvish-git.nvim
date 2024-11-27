# Introduction
[dirvish-git.nvim](https://github.com/brianhuster/vim-dirvish-git.lua) is a plugin for Vim 8+ and Neovim that provides Gitsigns integration for [vim-dirvish](https://github.com/justinmk/vim-dirvish) by Justin M. Keyes. Inspired by [vim-dirvish-git](https://github.com/kristijanhusak/vim-dirvish-git) by Kristijan Husak.

# Installation
This plugin requires :
- Neovim 0.5.0+.
- Dependencies: [vim-dirvish](https://github.com/justinmk/vim-dirvish)

Use your favorite plugin manager. Below are some examples : 

* [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'justinmk/vim-dirvish'
Plug 'brianhuster/dirvish-git.nvim'
```

* [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "brianhuster/dirvish-git.nvim",
    --- No need to specify dependencies as lazy.nvim supports loading dependencies information from pkg.json
}
```

## mini.deps
```lua
MiniDeps.add({
    source = 'brianhuster/dirvish-git.nvim',
    depends = {
        'justinmk/vim-dirvish',
    },
})
```

# Configuration

Note: you can remove any of the icons by setting them to a space.

## Lua

```lua
require('dirvish-git').setup({
    git_icons = {
        modified = '🖋️',
        staged = '✅',
        renamed = '➜',
        unmerged = '❌',
        ignored = '🙈',
        untracked = '❓',
        file = '📄',
        directory = '📁',
	},
})
```

## Legacy Vim script

```vim
let s:dirvish_git_lua_config = {
    \ 'git_icons': {
    \     'modified': '🖋️',
    \     'staged': '✅',
    \     'renamed': '➜',
    \     'unmerged': '❌',
    \     'ignored': '🙈',
    \     'untracked': '❓',
    \     'file': '📄',
    \     'directory': '📁',
    \ }
\ }
call luaeval('require("dirvish-git").setup(_A)', s:dirvish_git_lua_config)
```

# Contributing

If you have any suggestions, bug reports, or contributions, please feel free to open an issue or a pull request.
