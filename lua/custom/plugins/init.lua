-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    opts = {
      mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>' },
      easing_function = 'quadratic',
      -- Scrolling speed
      duration_multiplier = 0.5,
      -- cursor_scrolls_alone = false,
      respect_scrolloff = true,
    },
  },
  {
    'danymat/neogen',
    config = true,
  },
  -- Code folding
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    config = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require('ufo').setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }

      -- Keymaps
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    end,
  },

  -- Copilot
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
      -- Optional: Configure copilot settings
      vim.g.copilot_no_tab_map = true
      vim.keymap.set('i', '<C-h>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })

      vim.g.copilot_assume_mapped = true
      -- vim.keymap.set('i', '<C-y>', function()
      --   if vim.fn['copilot#GetDisplayedSuggestion']().text ~= '' then
      --     return vim.fn['copilot#Accept'] '\\<CR>'
      --   else
      --     return '<C-y>' -- fallback to default LSP behavior
      --   end
      -- end, { expr = true, replace_keycodes = false })
      -- Set up key mappings
      -- vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
      --   expr = true,
      --   replace_keycodes = false,
      -- })
    end,
  },

  -- Database client
  -- TODO: Find a better plugin for this

  {
    {
      'mistweaverco/kulala.nvim',
      keys = {
        { '<leader>Xs', desc = 'Send request' },
        { '<leader>Xa', desc = 'Send all requests' },
        { '<leader>Xb', desc = 'Open scratchpad' },
      },
      ft = { 'http', 'rest' },
      opts = {
        global_keymaps = true,
        global_keymaps_prefix = '<leader>X',
        kulala_keymaps_prefix = '',
      },
    },
  },

  -- Markdown preview
  {
    'toppair/peek.nvim',
    event = { 'VeryLazy' },
    build = 'deno task --quiet build:fast',
    config = function()
      require('peek').setup { theme = 'dark' }
      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },
}
