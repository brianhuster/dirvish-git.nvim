local utils = {}

function utils.bool(any)
	return any and any ~= 0
end

---@param cmd string
---@param callback function
function utils.async_system(cmd, callback)
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
end

return utils
