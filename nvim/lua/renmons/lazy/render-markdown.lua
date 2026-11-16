-- Markdown rendered in the buffer (headings, tables, checkboxes, code blocks); the cursor
-- line stays raw. Math is inkmath's: render-markdown's own latex would draw over its images.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "quarto", "rmd" }, -- same filetypes as inkmath
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {
		file_types = { "markdown", "quarto", "rmd" },
		latex = { enabled = false },
	},
	keys = {
		{
			"<leader>ur",
			"<cmd>RenderMarkdown toggle<cr>",
			ft = { "markdown", "quarto", "rmd" },
			desc = "Markdown: rendered / raw",
		},
	},
}
