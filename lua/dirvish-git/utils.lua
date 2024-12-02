local utils = {}

local isnvim = vim.fn.has('nvim') == 1

function utils.bool(any)
	return any and any ~= 0
end

if not vim.o then
	vim.o = {}
	setmetatable(vim.o, {
		__index = function(_, key)
			local expr = '&' .. key
			return vim.fn.exists(expr) == 1 and vim.eval(expr)
		end,
	})
end

if not vim.json then
	vim.json = {
		encode = vim.fn.json_encode,
		decode = vim.fn.json_decode
	}
end

function utils.read(path, opts)
	local file = opts and opts.type == 'file' and io.open(path, "r") or io.popen(path)
	if not file then
		return
	end
	local content = file:read("*a")
	file:close()
	return vim.fn.trim(content)
end

local function get_path_lua_file()
	local info = debug.getinfo(2, "S")
	if not info then
		print("Cannot get info")
		return nil
	end
	local source = info.source
	if source:sub(1, 1) == "@" then
		return source:sub(2)
	end
end

function utils.get_plugin_path()
	local filepath = get_path_lua_file()
	if not filepath then
		return
	end
	return filepath:sub(1, - #("/lua/dirvish-git/utils.lua") - 1)
end

---@param cmd string
---@param callback function
function utils.async_system(cmd, callback)
	local count = 0
	if isnvim then
		vim.fn.jobstart(cmd, {
			on_stdout = function(job, data, _)
				count = count + 1
				if count > 1 then
					return
				end
				callback(job, data)
			end,
			cwd = vim.b.git_root or vim.fn.getcwd(),
		})
	else
		vim.fn.job_start(cmd, vim.dict({
			outcb = function(job, data)
				count = count + 1
				if count > 1 then
					return
				end
				data = vim.fn.split(data, "\n")
				callback(job, data)
			end,
			cwd = vim.b.git_root or vim.fn.getcwd(),
		}))
	end
end

return utils
