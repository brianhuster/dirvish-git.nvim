 local bool = require('dirvish-git.utils').bool
if bool(vim.fn.has('nvim')) then
	return
end

--- Credit : SongTianxiang
vim.o = setmetatable({}, {
	__index = function(_, k)
		local ok, optv = pcall(vim.eval, "&" .. k) -- notice this like
		if not ok then
			return error("Unknown option " .. k)
		end
		return optv
	end,
	__newindex = function(o, k, v)
		local _ = vim.o[k]
		if type(v) == "boolean" then
			k = v and k or "no" .. k
			vim.command('set ' .. k)
			return
		end
		vim.command('set ' .. k .. '=' .. v)
	end,
})

vim.trim = vim.fn.trim
vim.split = vim.fn.split

vim.dict_deep_extend = function(mode, dict1, dict2)
	local function merge(mode, d1, d2)
		for k, v in d2() do
			if vim.type(v) == "dict" and vim.type(d1[k]) == "dict" then
				merge(mode, d1[k], v)
			else
				vim.fn.extend(dict1, dict2, mode)
			end
		end
	end

	local result = dict1
	merge(mode, result, dict2)

	return result
end
