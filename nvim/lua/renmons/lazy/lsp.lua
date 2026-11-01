return {
	{
		"folke/lazydev.nvim", -- replaces the archived neodev.nvim
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"b0o/SchemaStore.nvim", -- JSON/YAML schemas (package.json, tsconfig, CloudFormation, GH Actions, ...)
		},
		config = function()
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = false,
				virtual_lines = { current_line = true }, -- full message below the cursor line
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
					},
				},
			})

			vim.lsp.config("vtsls", {
				settings = {
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						inlayHints = {
							parameterNames = { enabled = "literals" },
							variableTypes = { enabled = false },
							functionLikeReturnTypes = { enabled = true },
						},
					},
					vtsls = { autoUseWorkspaceTsdk = true }, -- the project's own typescript version
				},
			})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})

			-- CloudFormation / SAM short-form intrinsics, otherwise yamlls flags them as unknown tags
			local cfn_tags = {}
			for _, tag in ipairs({ "Ref", "Condition", "GetAZs", "ImportValue", "Base64" }) do
				table.insert(cfn_tags, "!" .. tag)
			end
			for _, tag in ipairs({
				"Sub", "GetAtt", "Join", "If", "Equals", "Select", "Split",
				"FindInMap", "Cidr", "And", "Or", "Not", "Transform",
			}) do
				table.insert(cfn_tags, "!" .. tag)
				table.insert(cfn_tags, "!" .. tag .. " sequence")
				table.insert(cfn_tags, "!" .. tag .. " mapping")
			end

			vim.lsp.config("yamlls", {
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim provides them
						schemas = require("schemastore").yaml.schemas(),
						customTags = cfn_tags,
						keyOrdering = false,
					},
				},
			})

			-- Keymaps for every attached server
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
				callback = function(args)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
					end

					map("gd", vim.lsp.buf.definition, "Goto definition")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")

					-- eslint: apply all auto-fixes before saving (conform/prettier formats afterwards)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "eslint" then
						map("<leader>ce", "<cmd>LspEslintFixAll<cr>", "ESLint fix all")
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = args.buf,
							group = vim.api.nvim_create_augroup("UserEslintFix" .. args.buf, { clear = true }),
							command = "silent! LspEslintFixAll",
						})
					end
				end,
			})

			vim.lsp.enable({
				"lua_ls",
				"pyright",
				"vtsls",
				"eslint",
				"jsonls",
				"yamlls",
				"rust_analyzer",
				"clangd",
				"graphql",
			})
		end,
	},
}
