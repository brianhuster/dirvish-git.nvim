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
		local count = 0
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
		local has_out = false
		vim.fn.job_start(cmd, vim.dict({
			out_cb = function(job, data)
				has_out = true
				data = vim.split(data, '\n')
				callback(job, data)
			end,
			exit_cb = function()
				if not has_out then
					callback(nil, { '' })
				end
			end,
		}))
	end
end

return utils
