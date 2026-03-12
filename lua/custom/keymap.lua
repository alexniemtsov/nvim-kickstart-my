local function test_function()
  print 'Test function called'
end

-- Custom KeyMaps should be defined here

-- Annotation generator
vim.api.nvim_set_keymap('n', '<Leader>aa', ":lua require('neogen').generate()<CR>", { noremap = true, silent = true, desc = 'Add annotation' })

vim.keymap.set('n', '<Leader>l', test_function, { desc = 'Test function' })
