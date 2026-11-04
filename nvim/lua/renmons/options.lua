-- lua/renmons/options.lua
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

vim.opt.termguicolors = true
vim.opt.spelllang = { "en_us" } --, "de_de" }
vim.opt.spell = false

-- Make the current position easier to track
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- ueep unfolded when starting
vim.opt.foldlevelstart = 99

vim.opt.showmode = false -- lualine already shows the mode
vim.opt.laststatus = 3 -- global statusline, matches globalstatus = true

vim.opt.mousescroll = "ver:3,hor:6"

vim.opt.signcolumn = "yes" -- text doesn't shift when git or error marks appear
vim.opt.updatetime = 250 -- default 4000; CursorHold fires sooner
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split" -- live preview of :s
vim.opt.confirm = true -- ask instead of failing on :q with unsaved changes

-- guicursor + cursor colors: autocommands.lua

-- no plugins need these hosts; silences their :checkhealth warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
