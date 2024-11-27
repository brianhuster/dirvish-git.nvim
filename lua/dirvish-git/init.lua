local utils = require('dirvish-git.utils')
local bool = utils.bool
local fn = vim.fn
local api = vim.api
local ns_id = api.nvim_create_namespace('conceal')

local M = {}
M.config = {}

M.cache = {}

---@type boolean
local isnvim = bool(fn.has('nvim'))

---@class dict

---@type string
local sep = bool(fn.exists('+shellslash')) and not bool(vim.o.shellslash) and '\\' or '/'

---@param current_dir string
---@return string|nil
local function get_git_root(current_dir)
	local root = vim.system({ 'git', '-C', current_dir, 'rev-parse', '--show-toplevel' }, { text = true }):wait().stdout
	return root and fn.isdirectory(root) == 1 and vim.trim(root) or nil
end

---@param dir string
local function is_git_repo(dir)
	return bool(fn.isdirectory(dir .. sep .. '.git'))
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

---@param line_number number : 1-indexed line number
local function get_git_status(line_number)
	local path = fn.getline(line_number)
	local current_dir = fn.expand('%')
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
	local base_path = path:sub(#git_root + 2)

	local callback = function(job, stdout)
		local status_msg = stdout[1]
		local data = { status_msg:match('(.)(.)%s(.*)') }
		if #data > 0 then
			local us, them = data[1], data[2]
			local status = translate_git_status(us, them)
			if M.config.git_icons then
				M.cache[path] = M.config.git_icons[status]
			end
		else
			M.cache[path] = nil
		end
		if not vim.o.filetype == 'dirvish' then
			return
		end
		vim.api.nvim_buf_set_extmark(0, ns_id, line_number - 1, 0, {
			conceal = M.cache[path] or (path:sub(-1) == sep and M.config.git_icons.directory or M.config.git_icons.file),
			end_col = #vim.api.nvim_buf_get_name(0),
		})
	end

	utils.async_system(('git status --porcelain --ignored=no %s'):format(base_path), callback)
end


function M.init()
	local last_line = api.nvim_buf_line_count(0)
	for i = 1, last_line do
		get_git_status(i)
	end
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
	if not isnvim then
		git_icons = vim.dict(git_icons)
	end
	local default_opts = {
		git_icons = git_icons,
	}
	if isnvim then
		M.config = vim.tbl_deep_extend('force', default_opts, opts or {})
	end
end

return M
