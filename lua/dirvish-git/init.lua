local utils = require('dirvish-git.utils')
local bool = utils.bool
local fn = vim.fn
---@type boolean
local isnvim = bool(fn.has('nvim'))
local api = vim.api
local g = vim.g
local ns_id
if isnvim then
	ns_id = api.nvim_create_namespace('dirvish_git')
else
	vim.fn.prop_type_add('dirvish_git', vim.dict())
end

local M = {}
M.cache = {}

---@type string
local sep = utils.sep

---@param current_dir string
---@return string|nil
local function get_git_root(current_dir)
	local to = fn.has('win32') and "2>NUL" or "2>/dev/null"
	local root = utils.read(('git -C %s rev-parse --show-toplevel %s'):format(current_dir, to))
	if root then
		if fn.isdirectory(root) == 1 then
			return root
		end
	end
end

---@param us string
---@param them string
---@return string
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
---@return string
local function get_icon(path)
	return M.cache[path] or (path:sub(-1) == sep and g.dirvish_git_icons.directory or g.dirvish_git_icons.file)
end

---@param line_number number : 1-indexed line number
local function get_git_status(line_number)
	local path = fn.getline(line_number)

	local function set_icon()
		if isnvim then
			api.nvim_buf_set_extmark(0, ns_id, line_number - 1, 0, {
				virt_text = { { get_icon(path), 'Comment' } },
				virt_text_pos = 'inline',
			})
		else
			fn.prop_add(line_number, 1, vim.dict({
				type = 'dirvish_git',
				text = get_icon(path),
			}))
		end
	end

	local git_root = vim.b.git_root
	if not git_root then
		if vim.eval('&filetype') == 'dirvish' then
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
			if g.dirvish_git_icons then
				M.cache[path] = g.dirvish_git_icons[status]
			end
		else
			M.cache[path] = nil
		end
		if vim.eval('&filetype') ~= 'dirvish' then
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

---@deprecated
function M.setup()
	print("`require('dirvish-git').setup()` is deprecated. Use `g:dirvish_git_icons` instead")
end

return M
