-- Sessions per folder (and git branch): the open files and splits are saved when nvim quits.
-- `nvim` without file arguments reopens the last session of that folder, so after a reboot
-- tmux-resurrect restarts nvim in each pane and the files come back too.
return {
  "folke/persistence.nvim",
  lazy = false, -- has to be there at VimEnter for the auto restore
  opts = {},
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore session (this folder)" },
    { "<leader>qS", function() require("persistence").select() end, desc = "Pick a session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
  },
  init = function()
    -- no blank/terminal windows in sessions, they come back as empty buffers
    vim.opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "skiprtp" }

    local group = vim.api.nvim_create_augroup("renmons_persistence", { clear = true })
    local from_stdin = false
    vim.api.nvim_create_autocmd("StdinReadPre", {
      group = group,
      callback = function() from_stdin = true end,
    })
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      callback = function()
        if vim.fn.argc() == 0 and not from_stdin then
          -- after startup: loaded inside VimEnter the buffers get no filetype (no LSP, no colors)
          vim.schedule(function() require("persistence").load() end)
        end
      end,
    })
    -- the file tree would come back as an empty "NvimTree_1" buffer
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "PersistenceSavePre",
      callback = function() pcall(vim.cmd, "NvimTreeClose") end,
    })
  end,
}
