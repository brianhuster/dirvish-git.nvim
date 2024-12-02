local utils = require('dirvish-git.utils')
local bool = utils.bool
local fn = vim.fn
---@type boolean
local isnvim = bool(fn.has('nvim'))
local api = vim.api
local o = vim.o

local M = {}
M.config = {}

M.cache = {}


---@class dict

---@type string
local sep = bool(fn.exists('+shellslash')) and not bool(vim.o.shellslash) and '\\' or '/'

---@param current_dir string
---@return string|nil
local function get_git_root(current_dir)
	local root = utils.read(('git -C %s rev-parse --show-toplevel'):format(current_dir))
	if root then
		if fn.isdirectory(root) == 1 then
			return root
		end
	end
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

local function get_icon(path)
	return M.cache[path] or (path:sub(-1) == sep and M.config.git_icons.directory or M.config.git_icons.file)
end

---@param line_number number : 1-indexed line number
local function get_git_status(line_number)
	local path = fn.getline(line_number)

	local function set_icon()
		if isnvim then
			local ns_id = api.nvim_create_namespace('dirvish_git')
			api.nvim_buf_set_extmark(0, ns_id, line_number - 1, 0, {
				virt_text = { { get_icon(path), 'Comment' } },
				virt_text_pos = 'inline',
			})
		else
			fn.propadd(line_number, 1, vim.dict({
				text = get_icon(path),
			}))
		end
	end

	local git_root = vim.b.git_root
	if not git_root then
		if o.filetype == 'dirvish' then
			set_icon()
		end
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
		if o.filetype ~= 'dirvish' and o.filetype ~= 'netrw' then
			return
		end
		set_icon()
	end
	utils.async_system(('git status --porcelain --ignored=no %s'):format(base_path), callback)
end


function M.init()
	vim.b.git_root = get_git_root(fn.expand('%'))
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
