require("renmons.options")
require("renmons.keymaps")
require("renmons.lazy_init")
require("renmons.autocommands")

-- Machine-local extras, not in this repo (e.g. work tools): ~/.config/nvim-local/*.lua
for _, file in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "-local/*.lua", false, true)) do
	local ok, err = pcall(dofile, file)
	if not ok then
		vim.notify("nvim-local: " .. err, vim.log.levels.ERROR)
	end
end
