local M = {}

local bool = require('dirvish-git.utils').bool

M.min_nvim = '0.5.0'

M.compatible = function()
	local compatible = false
	if bool(vim.fn.has('nvim-' .. M.min_nvim)) then
		compatible = true
	end
	return compatible
end

M.check = function()
	local health = vim.health
	local ok = health.ok or health.report_ok
	local error = health.error or health.report_error
	local info = health.info or health.report_info
	local start = health.start or health.report_start

	if not bool(vim.fn.has('nvim')) then
		print("`:checkhealth` is only supported in Neovim")
		return
	end
	start('Check requirements')
	local vimver = string.format('%s.%s.%s', vim.version().major, vim.version().minor, vim.version().patch)
	if not M.compatible() then
		error("Neovim version is too old", ("Update to Neovim 0.9 or later"):format(M.min_nvim))
	else
		ok(("Neovim %s is compatible with with autosave.nvim"):format(vimver))
	end

	start('Check configuration')
	info(vim.inspect(require('dirvish-git').config))
end

return M
