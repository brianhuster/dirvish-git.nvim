local utils = {}

function utils.system(cmd)
	local _, handle = pcall(io.popen, cmd .. " 2> ~/err.log")
	if not handle then
		return
	end
	local result = handle:read("*a")
	handle:close()
	return result
end

function utils.systemlist(cmd)
	local result = utils.system(cmd)
	if not result then
		return {}
	end
	local lines = {}
	for line in result:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

function utils.bool(any)
	return any and any ~= 0
end

function utils.async_system(cmd, callback)
	if utils.bool(vim.fn.has('nvim')) then
		vim.fn.jobstart(cmd, {
			on_stdout = function(_, data, _)
				callback(data)
			end,
		})
	else
		vim.fn.job_start(cmd, {
			out_cb = function(_, data)
				data = vim.split(data, '\n')
				callback(data)
			end
		})
	end
end

return utils
