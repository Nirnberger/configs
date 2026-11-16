-- inkmath.nvim: LaTeX math rendered as images (kitty graphics: Ghostty, kitty; also in tmux)
-- in .tex and markdown buffers. github.com/Nirnberger/inkmath; :help inkmath, :checkhealth inkmath.
return {
  "Nirnberger/inkmath", -- :Lazy update pulls new versions
  name = "inkmath.nvim",
  ft = { "tex", "markdown", "quarto", "rmd" },
  dependencies = { "nvim-treesitter/nvim-treesitter" }, -- latex/markdown parsers (treesitter.lua)
  build = ":InkMath build", -- installs the MathJax worker's node dependencies
  opts = {
    preview = { position = "above" }, -- insert-mode preview float above the formula
    -- render-markdown sets 'conceallevel' in markdown; inkmath leaves it alone there
    overrides = { markdown = { conceal = false }, quarto = { conceal = false }, rmd = { conceal = false } },
  },
  keys = {
    { "<leader>um", "<Plug>(inkmath-toggle)", ft = { "tex", "markdown" }, desc = "Toggle math images" },
  },
}
