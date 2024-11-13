if exists('g:dirvish_relative_path') && g:dirvish_relative_path == 1
	echoerr 'dirvish_git: g:dirvish_relative_path = 1 is not supported'
	echo 'Please set g:dirvish_relative_path = 0'
	finish
endif
if !luaeval('VimDirvishGitSet')
	lua require('dirvish_git').setup()
endif
