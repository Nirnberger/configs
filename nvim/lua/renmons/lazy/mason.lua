return {
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		opts = {}, -- mason itself has no ensure_installed
	},

	-- only for the lspconfig -> mason name mapping below; lsp.lua already calls vim.lsp.enable()
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = { automatic_enable = false },
	},

	-- One list for everything, so install.sh can install it headless (:MasonToolsInstallSync)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
		opts = {
			ensure_installed = {
				-- language servers (lspconfig names)
				"lua_ls", "pyright", "vtsls", "eslint", "jsonls", "yamlls",
				"rust_analyzer", "clangd", "graphql",
				-- formatters, linters, debuggers
				"stylua", "shfmt", "ruff", "prettierd",
				"jdtls", "java-debug-adapter", "java-test", -- java.lua (nvim-jdtls)
				"js-debug-adapter", "debugpy", "codelldb", -- dap.lua
			},
			run_on_start = true,
		},
	},
}
