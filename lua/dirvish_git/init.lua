require('dirvish_git._vim')
local utils = require('dirvish_git.utils')
local bool = utils.bool

local M = {}
M.config = {}

---@class dict

---@type string
local sep = bool(vim.fn.exists('+shellslash')) and not bool(vim.o.shellslash) and '\\' or '/'

---@param current_dir string
local function get_git_root(current_dir)
	local root = utils.system(('git -C %s rev-parse --show-toplevel'):format(current_dir))
	return root and vim.trim(root) or nil
end

---@param dir string
local function is_git_repo(dir)
	return bool(vim.fn.isdirectory(dir .. sep .. '.git'))
end

---@param us string
---@param them string
local function translate_git_status(us, them)
	if us == '?' and them == '?' then
		return 'untracked'
	elseif us == ' ' and them == 'M' then
		return 'modified'
	elseif us:match('[MAC]') then
		return 'staged'
	elseif us == 'R' then
		return 'renamed'
	elseif us == 'U' or them == 'U' or (us == 'A' and them == 'A') or (us == 'D' and them == 'D') then
		return 'unmerged'
	elseif us == '!' then
		return 'ignored'
	else
		return 'unknown'
	end
end

---@param path string
local function get_git_status(path)
	local current_dir = vim.fn.expand('%')
	if not vim.b.git_root then
		vim.b.git_root = get_git_root(current_dir)
	else
		local git_root = vim.b.git_root
		if not is_git_repo(git_root) then
			vim.b.git_root = get_git_root(current_dir)
		end
	end
	local git_root = vim.b.git_root
	if not git_root then
		return
	end
	utils.system('cd ' .. git_root)
	local base_path = path:sub(#git_root + 2)

	local status
	if not bool(vim.fn.isdirectory(path)) then
		status = utils.systemlist(('git status --porcelain %s'):format(base_path))[1]
	else
		status = utils.systemlist(('git status --porcelain --ignored %s'):format(base_path))[1]
	end
	if not status then
		return
	end
	local data = { status:match('(.)(.)%s(.*)') }
	if #data > 0 then
		local us, them = data[1], data[2]
		return translate_git_status(us, them)
	end
end

---@param path string
local function get_git_icon(path)
	local status = get_git_status(path)
	if status then
		return M.config.git_icons[status]
	end
end

---@param file string
function M.add_icon(file)
	local git_icon = get_git_icon(file)
	if not git_icon then
		return file:sub(-1) == sep and M.config.git_icons.directory or M.config.git_icons.file
	end
	return git_icon
end

--- Set up the plugin
---@param opts table|dict: The options to set up the plugin. Being a table if you use Nvim, and a dictionary if you use Vim.
function M.setup(opts)
	local git_icons = {
		modified = '🖋️',
		staged = '✅',
		untracked = '❓',
		renamed = '🔄',
		unmerged = '❌',
		ignored = '🙈',
		file = '📄',
		directory = '📂',
	}
	if not bool(vim.fn.has('nvim')) then
		git_icons = vim.dict(git_icons)
	end
	local default_opts = {
		git_icons = git_icons,
	}
	if bool(vim.fn.has('nvim')) then
		M.config = vim.tbl_deep_extend('force', default_opts, opts or {})
	else
		M.config = vim.dict_deep_extend('force', vim.dict(default_opts), opts or vim.dict())
	end
	vim.fn['dirvish#add_icon_fn'](require('dirvish_git').add_icon)
end

return M
