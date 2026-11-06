-- Debugger: one set of <leader>d keys for every language.
-- Adapters come from Mason (mason.lua): js-debug-adapter, debugpy, codelldb.
-- Java registers its adapter + main-class configs itself (java.lua, jdtls.setup_dap).
local mason = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")

local function setup_js(dap)
  -- vscode-js-debug; neotest-jest/vitest debug through the same "pwa-node" adapter
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = mason .. "/bin/js-debug-adapter", args = { "${port}" } },
  }
  dap.adapters["node"] = dap.adapters["pwa-node"] -- configs from launch.json often say "node"

  local attach = {
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process (node --inspect)",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to localhost:9229",
      port = 9229,
      cwd = "${workspaceFolder}",
    },
  }

  dap.configurations.javascript = vim.list_extend({
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
  }, vim.deepcopy(attach))

  dap.configurations.typescript = vim.list_extend({
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch current file (tsx)",
      runtimeExecutable = "npx",
      runtimeArgs = { "--yes", "tsx" }, -- runs .ts directly, downloads tsx on first use
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**", "**/node_modules/**" },
    },
  }, vim.deepcopy(attach))
end

local function setup_codelldb(dap)
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = { command = mason .. "/bin/codelldb", args = { "--port", "${port}" } },
  }
  local launch = {
    {
      type = "codelldb",
      request = "launch",
      name = "Launch executable",
      program = function()
        -- build first (cargo build / make), then pick the binary
        return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
  dap.configurations.rust = launch
  dap.configurations.c = launch
  dap.configurations.cpp = launch
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text", -- variable values inline while stepping
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      -- <leader>dd too: unmapped it falls through to a plain dd and deletes the line
      { "<leader>dd", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
        desc = "Debug: Conditional breakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start / continue" },
      { "<leader>dn", function() require("dap").step_over() end, desc = "Debug: Step over (next line)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Debug: Step out" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Debug: Run to cursor" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Debug: Restart" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run last" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "Debug: Stop" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug: Evaluate" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      -- open the UI when a session starts, close it when the program ends
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

      setup_js(dap)
      setup_codelldb(dap)
      -- Python: launch file / pytest test under cursor, via Mason's debugpy
      require("dap-python").setup(mason .. "/packages/debugpy/venv/bin/python")
    end,
  },
}
