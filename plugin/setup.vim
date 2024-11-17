let compatible = luaeval("require'autosave.health'.compatible()")
let min_vim = luaeval("require'autosave.health'.min_vim")
let min_nvim = luaeval("require'autosave.health'.min_nvim")
if !compatible
	echoerr printf("autosave.vim requires Vim >= %s with +lua feature or Neovim >= %s", min_vim, min_nvim)
	finish
endif

if exists('g:dirvish_relative_path') && g:dirvish_relative_path == 1
	echoerr 'dirvish_git: g:dirvish_relative_path = 1 is not supported'
	echo 'Please set g:dirvish_relative_path = 0'
	finish
endif
if !luaeval('VimDirvishGitSet')
	lua require('dirvish-git').setup()
endif

autocmd FileType dirvish lua require("dirvish-git").init()

