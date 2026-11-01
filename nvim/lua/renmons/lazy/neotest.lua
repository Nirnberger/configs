-- Test runner for TS/JS (jest + vitest, each project uses what it has) and Python (pytest).
-- Java tests run through jdtls instead: <leader>jt / <leader>jT (java.lua).
-- <leader>T because <leader>t is tabs / today.
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
    "nvim-neotest/neotest-python",
  },
  keys = {
    { "<leader>Tr", function() require("neotest").run.run() end, desc = "Test: Run nearest" },
    { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: Run file" },
    { "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Test: Run last" },
    {
      "<leader>Td",
      function() require("neotest").run.run({ strategy = "dap" }) end,
      desc = "Test: Debug nearest",
    },
    { "<leader>Tq", function() require("neotest").run.stop() end, desc = "Test: Stop" },
    { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Test: Summary tree" },
    {
      "<leader>To",
      function() require("neotest").output.open({ enter = true, auto_close = true }) end,
      desc = "Test: Output",
    },
    { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Test: Output panel" },
    {
      "<leader>Tw",
      function() require("neotest").watch.toggle(vim.fn.expand("%")) end,
      desc = "Test: Watch file (rerun on save)",
    },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-vitest"),
        require("neotest-jest")({ jestCommand = "npx jest" }),
        require("neotest-python")({ runner = "pytest" }),
      },
    })
  end,
}
