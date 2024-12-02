if exists('loaded_dirvish_git') && loaded_dirvish_git
	finish
endif

let loaded_dirvish_git = v:true

let compatible = luaeval("require'dirvish-git.health'.compatible()")
let min_nvim = luaeval("require'dirvish-git.health'.min_nvim")
let min_vim = luaeval("require'dirvish-git.health'.min_vim")
if !compatible
	echoerr printf("dirvish-git.nvim requires Vim >= %s with +lua or Neovim >= %s", min_vim, min_nvim)
	finish
endif

let s:dirvish_git_default_icons = {
    \ 'modified': '🖋️',
    \ 'staged': '✅',
    \ 'untracked': '❓',
    \ 'renamed': '🔄',
    \ 'unmerged': '❌',
    \ 'ignored': '🙈',
    \ 'file': '📄',
    \ 'directory': '📂',
    \ }

if exists('g:dirvish_git_icons')
	let g:dirvish_git_icons = extend(s:dirvish_git_default_icons, g:dirvish_git_icons, 'force')
else
	let g:dirvish_git_icons = s:dirvish_git_default_icons
endif

autocmd FileType dirvish lua require('dirvish-git').init()
