local M = {}

local bool = require('dirvish-git.utils').bool
local utils = require('dirvish-git.utils')

local plugin_path = utils.get_plugin_path()

local sep = utils.sep

local packspecpath = plugin_path .. sep .. 'pkg.json'
local spec = vim.json.decode(utils.read(packspecpath, { type = 'file' }))
M.min_nvim = spec.engines.nvim:sub(2)
M.min_vim = spec.engines.vim:sub(2)

M.compatible = function()
	local compatible = false
	if bool(vim.fn.has('nvim-' .. M.min_nvim)) then
		compatible = true
	end
	if bool(vim.fn.has('patch-' .. M.min_vim)) and bool(vim.fn.has('lua')) then
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
	info('Git icons')
	info(vim.inspect(vim.g.dirvish_git_icons))
end

return M
