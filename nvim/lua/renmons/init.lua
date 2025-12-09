vim.g.mapleader = " "

vim.opt.encoding = "utf-8"
vim.opt.guifont = "JetBrainsMono Nerd Font:h14"
vim.opt.termguicolors = true

vim.opt.ignorecase = true
vim.opt.swapfile = false
vim.opt.smartcase = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 2
vim.opt.undodir = "/tmp/.vim-undo-dir"
vim.opt.undofile = true
vim.opt.scrolloff=4
vim.opt.spelllang = { 'en_us', 'de_de' }
vim.opt.spell = true

vim.opt.wrap = true
vim.opt.linebreak = true      -- wrap at word boundaries
vim.opt.breakindent = true    -- keep indent on wrapped lines

require("renmons.lazy_init")
require("renmons.set")
require("renmons.remap")
