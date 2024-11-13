#  Introduction
[vim-dirvish-git.lua](https://github.com/brianhuster/vim-dirvish-git.lua) is a plugin for Vim 8+ and Neovim that provides Gitsigns integration for [vim-dirvish](https://github.com/justinmk/vim-dirvish) by Justin M. Keyes. Inspired by [vim-dirvish-git](https://github.com/kristijanhusak/vim-dirvish-git) by Kristijan Husak.

> Note: This plugin is still in development. Use at your own risk.

# Installation
This plugin requires :
- A Vim 8.2.1054+ with `+lua` feature or Neovim 0.5.0+.
- Dependencies: [vim-dirvish](https://github.com/justinmk/vim-dirvish)

Use your favorite plugin manager. Below are some examples : 

* [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'justinmk/vim-dirvish'
Plug 'brianhuster/vim-dirvish-git.lua'
```

* [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "brianhuster/vim-dirvish-git.lua",
    dependencies = {
        "justinmk/vim-dirvish",
    }
}
```

# Configuration

Note: you can remove any of the icons by setting them to a space.

## Lua

This only works in Neovim

```lua
require('dirvish_git').setup({
    git_icons = {
        modified = '🖋️',
        staged = '✅',
        untracked = '❔',
        renamed = '➜',
        unmerged = '❌',
        ignored = '🙈',
        unknown = '❓',
        file = '📄',
        directory = '📁',
	},
})
```

## Vim9 script

```vim
var dirvish_git_lua_config = {
    git_icons: {
        modified: '🖋️',
        staged: '✅',
        untracked: '❔',
        renamed: '➜',
        unmerged: '❌',
        ignored: '🙈',
        unknown: '❓',
        file: '📄',
        directory: '📁',
    }
}
luaeval('require("dirvish_git").setup(_A)', dirvish_git_lua_config)
```

## Legacy Vim script

```vim
let l:dirvish_git_lua_config = {
    \ 'git_icons': {
    \     'modified': '🖋️',
    \     'staged': '✅',
    \     'untracked': '❔',
    \     'renamed': '➜',
    \     'unmerged': '❌',
    \     'ignored': '🙈',
    \     'unknown': '❓',
    \     'file': '📄',
    \     'directory': '📁',
    \ }
\ }
call luaeval('require("dirvish_git").setup(_A)', l:dirvish_git_lua_config)
```

# Contributing

If you have any suggestions, bug reports, or contributions, please feel free to open an issue or a pull request.
