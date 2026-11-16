-- Edit a folder like a buffer: rename / move / delete by editing lines, save with :w
return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Parent folder (oil)" },
		{ "<leader>E", "<cmd>Oil --float<cr>", desc = "Folder as float (oil)" },
	},
	opts = {
		default_file_explorer = false, -- nvim-tree stays the sidebar, oil opens only on demand
		skip_confirm_for_simple_edits = true,
		view_options = { show_hidden = true },
		keymaps = {
			["q"] = "actions.close",
			["<C-h>"] = false, -- keep Ctrl h/j/k/l for tmux-navigator
			["<C-l>"] = false,
		},
	},
}
