let compatible = luaeval("require'dirvish-git.health'.compatible()")
let min_nvim = luaeval("require'dirvish-git.health'.min_nvim")
if !compatible
	echoerr printf("autosave.vim requires Neovim >= %s", min_vim, min_nvim)
	finish
endif

if !luaeval('VimDirvishGitSet')
	lua require('dirvish-git').setup()
endif

autocmd FileType dirvish,netrw lua require('dirvish-git').init()

