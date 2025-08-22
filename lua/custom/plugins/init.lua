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
}
