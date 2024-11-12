if exists(g:loaded_vim_dirvish_git) && g:loaded_vim_dirvish_git
	finish
endif
let g:loaded_vim_dirvish_git = v:true

lua require('dirvish_git').setup()
