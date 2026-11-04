-- daf deletes a function, vic selects the inside of a class, ...
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

    local select = require("nvim-treesitter-textobjects.select")
    for keys, object in pairs({
      af = "@function.outer",
      ["if"] = "@function.inner",
      ac = "@class.outer",
      ic = "@class.inner",
    }) do
      vim.keymap.set({ "x", "o" }, keys, function()
        select.select_textobject(object, "textobjects")
      end, { desc = object })
    end
  end,
}
