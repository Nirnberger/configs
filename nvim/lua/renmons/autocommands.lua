local onSave = vim.api.nvim_create_augroup("AutoFormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = onSave,
  pattern = { "*.lua", "*.ts", "*.tsx", "*.py" },
  desc = "Format file befor save.",
  callback = function(args)
    vim.lsp.buf.format({ async = false })
  end,
})

local trim_group = vim.api.nvim_create_augroup("TrimTrailingWhitespace", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = trim_group,
  pattern = "*",
  desc = "Remove trailing whitespace on save",
  callback = function()
    local ft = vim.bo.filetype

    if ft == "markdown" or ft == "diff" then
      return
    end
    -- save cursor/window position
    local view = vim.fn.winsaveview()

    -- remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])

    -- restore cursor/window position
    vim.fn.winrestview(view)
  end,
})
