return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = buf, desc = "Git: " .. desc })
        end

        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        -- same without [ ] (Option+5/6 on a German layout)
        map("n", "<leader>gj", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "<leader>gk", function() gs.nav_hunk("prev") end, "Previous hunk")

        map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
      end,
    },
  },

  {
    "kdheepak/lazygit.nvim", -- needs the lazygit binary (Brewfile)
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitLog" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Git: lazygit" },
      { "<leader>gl", "<cmd>LazyGitLog<cr>", desc = "Git: log" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "Git: lazygit (file's repo)" },
    },
  },
}
