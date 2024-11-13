require('dirvish_git._vim')
local utils = require('dirvish_git.utils')
local bool = utils.bool

local M = {}
M.config = {}

---@class dict

local sep = bool(vim.fn.exists('+shellslash')) and not bool(vim.o.shellslash) and '\\' or '/'

local function get_git_root(current_dir)
	local root = utils.system(('git -C %s rev-parse --show-toplevel'):format(current_dir))
	return root and vim.trim(root) or nil
end

local function get_status_list(current_dir)
	local status_list = {}
	local files = vim.fn.glob(current_dir .. '*', true, true)
	if #files == 0 then
		return {}
	end
	for i = 1, #files do
		local status = utils.system(('git status --porcelain --ignored %s'):format(files[i]))
		status = status and vim.trim(status)
		if status and not status:match('^fatal') then
			table.insert(status_list, status)
		end
	end

	return status_list
end

local function get_git_status(us, them)
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


function M.init()
	local git_files = {}
	local current_dir = vim.fn.expand('%')
	local git_root = get_git_root(current_dir)
	if not git_root then
		return
	end

	local status_list = get_status_list(current_dir)
	vim.print(status_list)
	if #status_list == 0 then
		return
	end

	for _, item in ipairs(status_list) do
		local data = { item:match('(.)(.)%s(.*)') }
		if #data > 0 then
			local us = data[1]
			local them = data[2]
			local file = data[3]
			if file:find(' ') and file:sub(1, 1) == '"' then
				file = file:match('^"(.*)"$')
			end

			-- Rename status returns both old and new filename "old_name.ext -> new_name.ext"
			-- but only new name is needed here
			if us == 'R' then
				file = (file:match(' -> (.*)') or file)
			end

			file = vim.fn.fnamemodify(git_root .. sep .. file, ':p')
			print(file)
			if M.config.git_icons then
				local status = get_git_status(us, them)
				if status then
					git_files[file] = M.config.git_icons[status]
				end
			end
		end
	end
	return git_files
end

function M.add_icon(file)
	local dict = M.init()
	vim.print(dict)
	if not dict then
		return ' '
	end
	if not dict[file] then
		return file:sub(-1) == sep and M.config.git_icons.directory or M.config.git_icons.file
	end
	return dict[file]
end

--- Set up the plugin
---@param opts table|dict: The options to set up the plugin. Being a table if you use Nvim, and a dictionary if you use Vim.
function M.setup(opts)
	local git_icons = {
		modified = '🖋️',
		staged = '✅',
		untracked = '❔',
		renamed = '🔄',
		unmerged = '❌',
		ignored = '🙈',
		unknown = '❓',
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
