-- One list for diagnostics, references, symbols and quickfix: <leader>x
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {},
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Problems: project" },
    { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Problems: this file" },
    { "<leader>xr", "<cmd>Trouble lsp_references toggle focus=true<cr>", desc = "References of symbol" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (outline)" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
  },
}
