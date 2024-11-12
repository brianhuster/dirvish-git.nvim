require('dirvish_git._vim')
local utils = require('dirvish_git.utils')
local bool = utils.bool

local M = {}
M.config = {}

local sep = bool(vim.fn.exists('+shellslash')) and not bool(vim.o.shellslash) and '\\' or '/'

local function get_git_root(current_dir)
	return utils.system(('git -C %s rev-parse --show-toplevel'):format(current_dir))
end

local function get_status_list(current_dir)
	local status = utils.systemlist(('git status --porcelain --ignored %s'):format(current_dir))
	if #status == 0 or (#status == 1 and status[1]:match('^fatal')) then
		return {}
	end

	return status
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
	if #status_list == 0 then
		return
	end

	for _, item in ipairs(status_list) do
		local data = { item:match('(%.)(%.)(%s)(.*)') }
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
	if not dict then
		return ' '
	end
	return dict[file]
end

function M.setup()
	if not M.config.git_icons then
		M.config.git_icons = {
			modified = '✎',
			staged = '✚',
			untracked = 'U',
			renamed = '➜',
			unmerged = '✖',
			ignored = '!',
			unknown = '?',
		}
	end
	if bool(vim.fn.has('nvim')) then
		vim.api.nvim_create_autocmd('FileType', {
			pattern = 'dirvish',
			callback = function()
				vim.fn['dirvish#add_icon_fn'](M.add_icon)
			end,
		})
	else
		vim.command([[
			autocmd FileType dirvish lua vim.fn['dirvish#add_icon_fn'](require('dirvish_git').add_icon)
		]])
	end
end

return M
