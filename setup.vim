if g:loaded_vim_dirvish_git
	finish
endif
let g:loaded_vim_dirvish_git = 1

lua require('dirvish_git').setup()
