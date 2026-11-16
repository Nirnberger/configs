return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"python",
			"rust",
			"javascript",
			"typescript",
			"tsx",
			"html",
			"graphql",
			"bash",
			"json",
			"yaml",
			"toml",
			"java",
			"dockerfile",
			"hcl",
			"terraform",
			"markdown",
			"markdown_inline",
			"latex", -- for inkmath's math detection (highlighting stays vimtex's, see below)
			"elixir",
		})

		-- main no longer enables highlighting/indent for you
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
			callback = function(args)
				-- tex: vimtex's syntax highlighting, not treesitter's (the latex parser is
				-- installed only for inkmath, which needs no highlighting)
				if args.match == "tex" then
					return
				end
				-- pcall: silently skip filetypes without a parser (chadtree, ...)
				if pcall(vim.treesitter.start, args.buf) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
