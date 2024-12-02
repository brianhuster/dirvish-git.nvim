let compatible = luaeval("require'dirvish-git.health'.compatible()")
let min_nvim = luaeval("require'dirvish-git.health'.min_nvim")
let min_vim = luaeval("require'dirvish-git.health'.min_vim")
if !compatible
	echoerr printf("dirvish-git.nvim requires Vim >= %s with +lua or Neovim >= %s", min_vim, min_nvim)
	finish
endif

autocmd FileType dirvish lua require('dirvish-git').init()
