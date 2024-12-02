let compatible = luaeval("require'dirvish-git.health'.compatible()")
let min_nvim = luaeval("require'dirvish-git.health'.min_nvim")
let min_vim = luaeval("require'dirvish-git.health'.min_vim")
if !compatible
	echoerr printf("dirvish-git.nvim requires Vim >= %s with +lua or Neovim >= %s", min_vim, min_nvim)
	finish
endif

if !luaeval('VimDirvishGitSet')
	lua require('dirvish-git').setup()
endif
function! s:dirvish_git_init() abort
	if !luaeval('VimDirvishGitSet')
		lua require('dirvish-git').setup()
	endif
	lua require('dirvish-git').init()
endfunction

autocmd FileType dirvish call s:dirvish_git_init()

