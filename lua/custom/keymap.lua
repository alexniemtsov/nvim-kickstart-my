-- Custom KeyMaps should be defined here

-- Annotation generator
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<Leader>aa', ":lua require('neogen').generate()<CR>", opts)
