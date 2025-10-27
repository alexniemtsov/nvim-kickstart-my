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
  {
    'kndndrj/nvim-dbee',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require('dbee').install()
    end,
    cmd = { 'Dbee', 'DbeeToggle', 'DbeeExecute' }, -- Lazy load only when called
    config = function()
      local install_path = vim.fn.stdpath 'data' .. '/lazy/nvim-dbee'
      require('dbee').setup {
        sources = {
          require('dbee.sources').MemorySource:new({
            {
              name = 'Snowflake Production',
              type = 'snowflake',
              -- Use environment variables for security
              -- No database or schema specified - access everything
              url = '{{ env "SNOWFLAKE_USER" }}:{{ env "SNOWFLAKE_PASSWORD" }}@{{ env "SNOWFLAKE_ACCOUNT" }}.snowflakecomputing.com:443?warehouse={{ env "SNOWFLAKE_WAREHOUSE" }}',
            },
          }),
        },
        extra_helpers = {},
        drawer = {
          disable_help = false,
        },
        -- Specify the binary path
        install_path = install_path,
      }
    end,
  },
}
