local bool = require('dirvish_git.utils').bool
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
