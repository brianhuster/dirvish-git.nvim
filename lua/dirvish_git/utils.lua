local utils = {}

function utils.system(cmd)
	local handle = io.popen(cmd)
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

return utils
