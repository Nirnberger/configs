return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree" },
		{ "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "History of this file" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "History of the repo / branch" },
		{ "<leader>gc", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview: last commit" },
		{ "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: branch vs origin/main" },
	},
	opts = {},
}
