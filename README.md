# Introduction
[dirvish-git.nvim](https://github.com/brianhuster/vim-dirvish-git.lua) is a plugin for Neovim that provides Gitsigns integration for the builtin [vim-dirvish](https://github.com/justinmk/vim-dirvish) by Justin M. Keyes. Inspired by [vim-dirvish-git](https://github.com/kristijanhusak/vim-dirvish-git) by Kristijan Husak.

# Installation
This plugin requires :

- Editor: This plugin can be used in either Vim or Neovim.
    - Vim 9.0.0185+ with `+lua` and `+textprop`
    - Neovim 0.7.0+
- [vim-dirvish](https://github.com/justinmk/vim-dirvish)

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
vim.g.dirvish_git_icons = {
    modified = '🖋️',
    staged = '✅',
    renamed = '➜',
    unmerged = '❌',
    ignored = '🙈',
    untracked = '❓',
    file = '📄',
    directory = '📁',
}
```

## Vim script

```vim
g:dirvish_git_icons = {
    \ 'modified': '🖋️',
    \ 'staged': '✅',
    \ 'renamed': '➜',
    \ 'unmerged': '❌',
    \ 'ignored': '🙈',
    \ 'untracked': '❓',
    \ 'file': '📄',
    \ 'directory': '📁',
    \ }
```

# Contributing

If you have any suggestions, bug reports, or contributions, please feel free to open an issue or a pull request.
