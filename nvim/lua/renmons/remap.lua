local wk = require("which-key")

wk.add({
  -- CHADTree: always focus, never toggle closed
  {
    "<leader>e",
    function()
      vim.cmd("CHADopen --always-focus")
    end,
    desc = "Open CHADTree and focus",
    mode = "n",
  },
  {
    "<leader>nt",
    function()
      vim.cmd("CHADopen")
    end,
    desc = "Open CHADTree and focus",
    mode = "n",
  },

  -- your Today mapping
  {
    "<leader>tt",
    ":Today<CR>",
    desc = "Open today's note",
    mode = "n",
  },

  -- Telescope
  {
    "<leader>ff",
    function()
      require("telescope.builtin").find_files(
        require("telescope.themes").get_dropdown({ winblend = 10 })
      )
    end,
    desc = "Find files (dropdown)",
    mode = "n",
  },
  { "<leader>fg", "<cmd>Telescope live_grep<cr>", mode = "n", desc = "Live grep" },
  { "<leader>fb", "<cmd>Telescope buffers<cr>",   mode = "n", desc = "Buffers" },

  -- LSP code action
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = "n" },
  { "<leader>bx", ":bdelete<CR>", desc = "Delete buffer", mode = "n"},
  { "<leader>bn", ":bnext<CR>",     desc = "Next buffer",     mode = "n" },
  { "<leader>bp", ":bprevious<CR>", desc = "Previous buffer", mode = "n" },
  { "<leader>nh", ":nohl<CR>", desc = "Clear highlight", mode = "n"},


  { "<leader>sv", "<C-w>v", desc = "Split window vertically" },
  { "<leader>sh", "<C-w>s", desc = "Split window horizontally" },
  { "<leader>se", "<C-w>=", desc = "Make splits equal size" },
  { "<leader>sx", "<cmd>close<CR>", desc = "Close current split" },
  { "<leader>to", "<cmd>tabnew<CR>", desc = "Open new tab" },
  { "<leader>tx", "<cmd>tabclose<CR>", desc = "Close current tab" },
  { "<leader>tn", "<cmd>tabn<CR>", desc = "Go to next tab" },
  { "<leader>tp", "<cmd>tabp<CR>", desc = "Go to previous tab" },
  { "<leader>tf", "<cmd>tabnew %<CR>", desc = "Open current buffer in new tab" },

})

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "format file" })
