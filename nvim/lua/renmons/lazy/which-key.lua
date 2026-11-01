return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  opts = {
    preset = "modern",

    keys = {
      scroll_down = "<c-j>",
      scroll_up = "<c-k>",
    },

    spec = {
      { "<leader>b", group = "buffers" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>j", group = "java" },
      { "<leader>n", group = "notes / tree / search" },
      { "<leader>s", group = "splits" },
      { "<leader>t", group = "tabs / today" },
      { "<leader>T", group = "tests" },
      { "<leader>u", group = "ui toggles" },
      { "<leader>v", group = "vimtex" },
      { "<leader>x", group = "problems / diagnostics" },
      { "<leader>z", group = "spelling" },
    },
  },

  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Show buffer-local keymaps",
    },
  },
}
