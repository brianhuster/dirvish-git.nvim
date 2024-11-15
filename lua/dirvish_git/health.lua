local M = {}

local bool = require('dirvish_git.utils').bool

M.min_vim = '8.2.1054'
M.min_nvim = '0.5.0'

M.compatible = function()
	local compatible = false
	if bool(vim.fn.has('nvim-' .. M.min_nvim)) then
		compatible = true
	end
	if bool(vim.fn.has("patch-" .. M.min_vim)) and bool(vim.fn.has("lua")) then
		compatible = true
	end
	return compatible
end

M.check = function()
	local health = vim.health
	if not bool(vim.fn.has('nvim')) then
		print("`:checkhealth` is only supported in Neovim")
		return
	end
	health.start('Check requirements')
	local vimver = string.format('%s.%s.%s', vim.version().major, vim.version().minor, vim.version().patch)
	if not M.compatible() then
		health.error("Neovim version is too old", ("Update to Neovim 0.9 or later"):format(M.min_nvim))
	else
		health.ok(("Neovim %s is compatible with with autosave.nvim"):format(vimver))
	end

	health.start('Check configuration')
	health.info(vim.inspect(require('dirvish_git').config))
end

return M
