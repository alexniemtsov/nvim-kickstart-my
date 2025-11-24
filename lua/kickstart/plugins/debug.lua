-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mxsdev/nvim-dap-vscode-js',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F17>',
      function()
        require('dap').terminate()
        require('dapui').close()
      end,
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'js',
        'js-debug-adapter',
        'netcoredbg',
        'php-debug-adapter',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    -- Open/close DAP UI automatically with custom behavior for PHP
    dap.listeners.after.event_initialized['dapui_config'] = function(session)
      pcall(dapui.open)
      -- For PHP, close only the console element after UI is fully opened
      -- if session and session.config and session.config.type == 'php' then
      --   vim.defer_fn(function()
      --     pcall(dapui.close, 'console')
      --   end, 200)
      -- end
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      vim.schedule(function()
        pcall(dapui.close)
      end)
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      vim.schedule(function()
        pcall(dapui.close)
      end)
    end

    -- PHP Auto-trigger: Run Docker command when PHP debugging starts and capture output to REPL
    dap.listeners.after.event_initialized['php_docker_trigger'] = function(session)
      if session.config.type == 'php' and session.config.dockerCommand then
        vim.defer_fn(function()
          vim.fn.jobstart(session.config.dockerCommand, {
            detach = false,
            on_stdout = function(_, data)
              if data then
                vim.schedule(function()
                  for _, line in ipairs(data) do
                    if line ~= '' then
                      require('dap.repl').append(line)
                    end
                  end
                end)
              end
            end,
            on_stderr = function(_, data)
              if data then
                vim.schedule(function()
                  for _, line in ipairs(data) do
                    if line ~= '' then
                      require('dap.repl').append('[stderr] ' .. line)
                    end
                  end
                end)
              end
            end,
          })
        end, 100)
      end
    end

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
    -- VS Code JS debugger setup
    require('dap-vscode-js').setup {
      node_path = 'node',
      debugger_cmd = { 'js-debug-adapter' },
      adapters = { 'pwa-node' },
    }

    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = { vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
      },
    }
    -- Always launch current file with `node <file>`
    dap.configurations.javascript = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch current .js file',
        program = '${file}', -- debug the open buffer
        cwd = vim.fn.getcwd(),
        console = 'integratedTerminal',
      },
    }

    dap.configurations.typescript = {
      {
        name = 'Launch TS (ts-node)',
        type = 'pwa-node',
        request = 'launch',
        runtimeArgs = { '-r', 'ts-node/register/transpile-only' },
        -- runtimeExecutable = 'ts-node',
        runtimeExecutable = 'ts-node',
        args = { '${file}' },
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
        resolveSourceMapLocations = {
          '${workspaceFolder}/**',
          '!**/node_modules/**',
        },
        console = 'integratedTerminal',
      },
    }
    dap.adapters['php'] = {
      type = 'executable',
      command = 'node',
      args = { vim.fn.stdpath 'data' .. '/mason/packages/php-debug-adapter/extension/out/phpDebug.js' },
    }
    dap.configurations.php = {
      {
        name = 'Listen for Xdebug (no auto-run)',
        type = 'php',
        request = 'launch',
        port = 9003,
        pathMappings = {
          ['/var/www'] = '/Users/alex/work/projects/nano_reality_srv',
        },
        log = false,
        xdebugSettings = {
          max_children = 128,
          max_data = 512,
          max_depth = 3,
        },
      },
      {
        name = 'Remote Debugging Session',
        type = 'php',
        request = 'launch',
        port = 51864,
        pathMappings = {
          ['/var/www/sandbox/conditions'] = '/Users/alex/work/projects/nano_reality_srv',
        },
        log = false,
        xdebugSettings = {
          max_children = 128,
          max_data = 512,
          max_depth = 3,
        },
      },
      {
        name = 'Debug: yii test/alex',
        type = 'php',
        request = 'launch',
        port = 9003,
        pathMappings = {
          ['/var/www'] = '/Users/alex/work/projects/nano_reality_srv',
        },
        log = false,
        xdebugSettings = {
          max_children = 128,
          max_data = 512,
          max_depth = 3,
        },
        dockerCommand = 'cd /Users/alex/work/projects/nano_reality_srv && docker-compose exec -T -e XDEBUG_SESSION=1 php-fpm php yii test/alex',
      },
      {
        name = 'Debug: Custom Yii Command',
        type = 'php',
        request = 'launch',
        port = 9003,
        pathMappings = {
          ['/var/www'] = '/Users/alex/work/projects/nano_reality_srv',
        },
        log = false,
        xdebugSettings = {
          max_children = 128,
          max_data = 512,
          max_depth = 3,
        },
        dockerCommand = function()
          local command = vim.fn.input 'Yii command (e.g., test/alex): '
          if command and command ~= '' then
            return 'cd /Users/alex/work/projects/nano_reality_srv && docker-compose exec -T -e XDEBUG_SESSION=1 php-fpm php yii ' .. command
          end
          return nil
        end,
      },
    }

    -- Resolve dockerCommand if it's a function before the listener fires
    local original_run = dap.run
    dap.run = function(config, opts)
      if config.dockerCommand and type(config.dockerCommand) == 'function' then
        config.dockerCommand = config.dockerCommand()
      end
      original_run(config, opts)
    end

    -- local function create_rust_dap_config(name)
    --   return {
    --     name = 'Debug (cargo build)',
    --     type = 'codelldb',
    --     request = 'launch',
    --     program = function()
    --       vim.fn.system 'cargo build'
    --       local metaJson = vim.fn.system 'cargo metadata --format-version 1 --no-deps'
    --       local meta = vim.fn.json_decode(metaJson)
    --       local pkg = meta.packages[1]
    --       local targetDir = meta.target_directory
    --       return string.format('%s/debug/%s', targetDir, pkg.name)
    --     end,
    --     cwd = '${workspaceFolder}',
    --     stopOnEntry = false,
    --     args = {},
    --   }
    -- end
    -- local metaJson = vim.fn.system 'cargo metadata --format-version 1 --no-deps'
    -- local meta = vim.fn.json_decode(metaJson)
    -- local targets = {}
    -- for i, target in ipairs(meta.packages[1].targets) do
    --   if vim.tbl_contains(target.kind or {}, 'bin') then
    --     table.insert(targets, create_rust_dap_config 'Binary Debug')
    --     -- table.insert(dap.configurations.rust, create_rust_dap_config 'Binary Debug')
    --   end
    --
    --   if vim.tbl_contains(target.kind or {}, 'test') then
    --     table.insert(targets, create_rust_dap_config 'Test Debug')
    --     -- table.insert(dap.configurations.rust, create_rust_dap_config 'Test Debug ')
    --   end
    -- end
    --
    -- local compiler_messages = vim.fn.systemlist { 'cargo', 'test', '--no-run', '--message-format=json' }
    --
    -- for _, msgJson in ipairs(compiler_messages) do
    --   local msg = vim.fn.json_decode(msgJson)
    --
    --   if msg.reason == 'compiler-artifact' then
    --     vim.print(msg)
    --   end
    -- end
    -- vim.print(targets)

    local function generate_rust_configurations()
      local configs = {}
      local metaJson = vim.fn.system 'cargo metadata --format-version 1 --no-deps'
      if vim.v.shell_error ~= 0 then
        return {}
      end

      local meta = vim.fn.json_decode(metaJson)
      if not meta or not meta.packages or #meta.packages == 0 then
        return {}
      end

      for _, pkg in ipairs(meta.packages) do
        for _, target in ipairs(pkg.targets) do
          if vim.tbl_contains(target.kind or {}, 'bin') then
            table.insert(configs, {
              name = string.format('Debug %s (cargo build)', target.name),
              type = 'codelldb',
              request = 'launch',
              program = function()
                vim.fn.system 'cargo build'
                local currentMetaJson = vim.fn.system 'cargo metadata --format-version 1 --no-deps'
                local currentMeta = vim.fn.json_decode(currentMetaJson)
                local targetDir = currentMeta.target_directory
                return string.format('%s/debug/%s', targetDir, target.name)
              end,
              -- cwd = '${workspaceFolder}',
              cwd = vim.fn.getcwd(),
              stopOnEntry = false,
              args = {},
            })
          end
        end
      end
      return configs
    end

    dap.configurations.rust = generate_rust_configurations()

    -- Customize DAP breakpoint icons
    vim.fn.sign_define('DapBreakpoint', {
      text = '🛑',
      texthl = 'DapBreakpoint',
      linehl = '', -- no full-line highlight
      numhl = '', -- no line-number highlight
    })
    --
    -- vim.fn.sign_define('DapBreakpointCondition', {
    --   text = '🔶',
    --   texthl = 'DapBreakpointCondition',
    --   linehl = '',
    --   numhl = '',
    -- })
    --
    -- vim.fn.sign_define('DapLogPoint', {
    --   text = '✏️',
    --   texthl = 'DapLogPoint',
    --   linehl = '',
    --   numhl = '',
    -- })
    --
    vim.fn.sign_define('DapStopped', {
      text = '⭐',
      texthl = 'DapStopped',
      linehl = 'Visual',
      numhl = 'DapStopped',
    })
  end,
}
