vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0

vim.opt.termguicolors = true

vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        icons_enabled = false,
        theme = "onedark",
        sections = {
          lualine_b = { "filename" },
          lualine_c = { "branch", "diff" },
          lualine_x = {},
          lualine_y = { "diagnostics" },
        },
      })
    end,
  },

  -- Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "cmake",
          "cpp",
          "c",
          "lua",
          "rust",
          "python",
          "go",
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        highlight = { enable = true, use_languagetree = true },
        indent = { enable = false },
        endwise = { enable = true },
      })
    end,
    opts = {},
  },
  -- Adds "end" to function() in lua, and some other languages
  "RRethy/nvim-treesitter-endwise",

  { "L3MON4D3/LuaSnip", lazy = true },
  { "hrsh7th/cmp-nvim-lsp", lazy = true },
  { "hrsh7th/cmp-nvim-lsp-signature-help", lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },

  -- https://github.com/lukas-reineke/cmp-under-comparator
  -- Makes python completions for class methods sort better
  -- It ensures methods prefixed with __ aren't always on top
  "lukas-reineke/cmp-under-comparator",
  "hrsh7th/cmp-nvim-lsp-document-symbol",

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp_kinds = {
        Text = "  ",
        Method = "  ",
        Function = "  ",
        Constructor = "  ",
        Field = "  ",
        Variable = "  ",
        Class = "  ",
        Interface = "  ",
        Module = "  ",
        Property = "  ",
        Unit = "  ",
        Value = "  ",
        Enum = "  ",
        Keyword = "  ",
        Snippet = "  ",
        Color = "  ",
        File = "  ",
        Reference = "  ",
        Folder = "  ",
        EnumMember = "  ",
        Constant = "  ",
        Struct = "  ",
        Event = "  ",
        Operator = "  ",
        TypeParameter = "  ",
      }

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        completion = { completeopt = "menu,menuone,noinsert" },
        sorting = {
          comparators = {
            -- function(entry1, entry2)
            --   local score1 = entry1.completion_item.score
            --   local score2 = entry2.completion_item.score
            --   if score1 and score2 then
            --     return (score1 - score2) < 0
            --   end
            -- end,

            -- The built-in comparators:
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require("clangd_extensions.cmp_scores"),
            require("cmp-under-comparator").under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        formatting = {
          format = function(_, vim_item)
            vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
            vim_item.abbr = string.sub(vim_item.abbr, 1, vim.fn.winwidth(0) - 40)
            return vim_item
          end,
        },
        mapping = {
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<cr>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          {
            name = "nvim_lsp_signature_help",
            entry_filter = function(entry, _)
              return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
            end,
          },
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },

  -- Theme
  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup({
        style = "darker",
        colors = {
          grey = "#878787", -- define a new color
          green = "#00ffaa", -- redefine an existing color
        },
        highlights = {
          Visual = { bg = "#4a4a4a" },
        },
      })
      require("onedark").load()
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- Python import sorter
  "stsewd/isort.nvim",

  -- Go plugin (does most things Go-related)
  "fatih/vim-go",

  "junegunn/fzf",
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    config = function()
      require("fzf-lua").setup({
        "max-perf",
        global_git_icons = true,
        global_file_icons = true,
      })
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    -- optional for icon support
    config = function()
      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")

          local function opts(desc)
            return {
              desc = "nvim-tree: " .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          local function edit_or_open()
            local node = api.tree.get_node_under_cursor()

            if node.nodes ~= nil then
              -- expand or collapse folder
              api.node.open.edit()
            else
              -- open file
              api.node.open.edit()
              -- Close the tree if file was opened
              api.tree.close()
            end
          end

          -- open as vsplit on current node
          local function vsplit_preview()
            local node = api.tree.get_node_under_cursor()

            if node.nodes ~= nil then
              -- expand or collapse folder
              api.node.open.edit()
            else
              -- open file as vsplit
              api.node.open.vertical()
            end

            -- Finally refocus on tree if it was lost
            api.tree.focus()
          end
          vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
          vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
          vim.keymap.set("n", "h", api.tree.close, opts("Close"))
          vim.keymap.set("n", "<Esc>", api.tree.close, opts("Close"))
          vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
        end,
      })
    end,
  },

  "gpanders/editorconfig.nvim",

  -- Allow plugins to define their own operator
  "kana/vim-operator-user",

  -- Plug which allows me to press a button to toggle between header and source
  -- file. Currently bound to LEADER+H
  "ericcurtin/CurtineIncSw.vim",

  "rust-lang/rust.vim",

  -- use({ "neoclide/coc.nvim", branch = "release" })

  { "antoinemadec/FixCursorHold.nvim", lazy = true },
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "stylua",
      },
    },
  },
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  "folke/trouble.nvim",
  "ray-x/lsp_signature.nvim",

  "p00f/clangd_extensions.nvim",

  {
    "simrat39/rust-tools.nvim",
    config = function()
      require("rust-tools").setup({
        tools = {
          inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
          },
        },
        -- all the opts to send to nvim-lspconfig
        -- these override the defaults set by rust-tools.nvim
        -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
        server = {
          -- on_attach is a callback called when the language server attachs to the buffer
          -- on_attach = on_attach,
          settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
              -- enable clippy on save
              checkOnSave = {
                command = "clippy",
                extraArgs = { "--release" },
              },
              -- https://github.com/simrat39/rust-tools.nvim/issues/300
              inlayHints = {
                locationLinks = false,
              },
            },
          },
        },
      })
    end,
  },
  "simrat39/inlay-hints.nvim",

  "nvim-lua/plenary.nvim",
  "neovim/nvim-lspconfig",

  { "jose-elias-alvarez/null-ls.nvim" },

  -- Plug 'rust-analyzer/rust-analyzer'

  "leafgarland/typescript-vim",

  "liuchengxu/graphviz.vim",

  "prabirshrestha/async.vim",

  "martinda/Jenkinsfile-vim-syntax",

  "modille/groovy.vim",

  "rcarriga/nvim-notify",

  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Plug 'integralist/vim-mypy'

  "sk1418/HowMuch",

  "hashivim/vim-terraform",

  "jparise/vim-graphql",

  "nvim-treesitter/playground",

  "kevinhwang91/promise-async",
})

local function autocmd(group, cmds, clear)
  clear = clear == nil and false or clear
  if type(cmds) == "string" then
    cmds = { cmds }
  end
  vim.cmd("augroup " .. group)
  if clear then
    vim.cmd([[au!]])
  end
  for _, c in ipairs(cmds) do
    vim.cmd("autocmd " .. c)
  end
  vim.cmd([[augroup END]])
end

local function map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

vim.opt.showmode = false

-- Enable line numbers
vim.opt.number = true
-- Enable relative line numbering
vim.opt.relativenumber = true
vim.opt.numberwidth = 6
vim.opt.cursorline = true

vim.opt.mouse = "a"

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.expandtab = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Don't wrap lines
vim.opt.wrap = false

-- Disable mode line
vim.opt.modeline = false

-- Disable swap files
vim.opt.swapfile = false

vim.opt.termguicolors = true

-- Always keep 5 lines visible
vim.opt.scrolloff = 5

vim.opt.smartcase = true

vim.opt.list = true
vim.opt.listchars = {
  trail = "·",
  extends = ">",
  tab = "  ",
}

-- vim.opt.statusline = "%f%m%r%h%w [%{&ff}] %=[%03.3b/%02.2B] [POS=%04v]"

-- Store an undo buffer in a file in nvims default folder ($XDG_DATA_HOME/nvim/undo)
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

vim.g.python3_host_prog = "/home/pajlada/.local/share/nvim/venv/bin/python3"

-- isort
autocmd("isort for python", [[ FileType python vnoremap <buffer> <C-i> :Isort<CR>]], true)

-- terraform
vim.g.terraform_fmt_on_save = true

-- Ignore various cache/vendor folders
vim.opt.wildignore:append({
  "*/node_modules/*",
  "*/dist/*",
  "*/__pycache__/*",
  "*/venv/*",
  "*/target/*",
  "*/doc/*html",
})

-- Ignore C/C++ Object files
vim.opt.wildignore:append({ "*.o", "*.obj" })
vim.opt.wildignore:append({ "*.ilk" })
vim.opt.wildignore:append({ "*/build/*" })
vim.opt.wildignore:append({ "*/build_native/*" })
vim.opt.wildignore:append({ "*/build-*/*" })
vim.opt.wildignore:append({ "*/vendor/*" })

-- Ignore generated C/C++ Qt files
vim.opt.wildignore:append({ "moc_*.cpp", "moc_*.h" })

-- set wildignore+=*/lib/*
vim.opt.wildignore:append({ "*/target/debug/*" })
vim.opt.wildignore:append({ "*/target/release/*" })

-- Ignore Unity asset meta-files
vim.opt.wildignore:append({ "*/Assets/*.meta" })

-- Use ; as :
-- Very convenient as you don't have to press shift to run commands
map("n", ";", ":", { noremap = true })

-- Unbind Q (it used to take you into Ex mode)
map("n", "Q", "<nop>")

-- Unbind F1 (it used to show you a help menu)
map("n", "<F1>", "<nop>")

-- Unbind <Space> as we use it as leader
map("n", "<Space>", "<nop>")

map("n", "<F5>", ":lnext<CR>", { noremap = true, silent = true })
map("n", "<F6>", ":lprev<CR>", { noremap = true, silent = true })

-- Unbind Shift+K, it's previously used for opening manual or help or something
map("n", "<S-k>", "<nop>")

map("n", "<C-Space>", ":ll<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-s>", function()
  local api = require("nvim-tree.api")

  return api.tree.toggle()
  -- return vim.fn["NvimTreeToggle"]()
end)

vim.keymap.set("n", "K", function()
  local filetype = vim.bo.filetype

  if filetype == "vim" or filetype == "help" then
    vim.api.nvim_command("h " .. filetype)
  else
    vim.api.nvim_command("!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>"))
  end
end, { silent = true, noremap = true })

vim.keymap.set("n", "<C-h>", function()
  vim.fn.CocAction("doHover")
end, { silent = true, noremap = true })

-- Copy to clipboard
-- SPACE+Y = Yank  (SPACE being leader)
-- SPACE+P = Paste
map("v", "<leader>y", '"*y', { silent = false })
map("v", "<leader>p", '"*p', { silent = true })
map("n", "<leader>p", '"*p', { silent = true })

-- vim-go
vim.g.go_fmt_command = "gofmt"
vim.g.go_fmt_options = {
  gofmt = "-s",
}

autocmd("vim_go_bindings", {
  [[ FileType go nmap <leader>b <Plug>(go-build) ]],
  [[ FileType go nmap <leader>t <Plug>(go-test) ]],
  [[ FileType go nmap <leader>c <Plug>(go-coverage) ]],
}, true)

-- clang_format
vim.g["clang_format#enable_fallback_style"] = 0

-- Check for edits when focusing vim
autocmd("check_for_edits", {
  [[ FocusGained,BufEnter * :silent! checktime ]],
}, true)

-- graphviz (liuchengxu/graphviz.vim)
-- Compile .dot-files to png
vim.g.graphviz_output_format = "png"

-- Open Graphviz results with sxiv
vim.g.graphviz_viewer = "sxiv"

-- Automatically compile dot files when saving
-- XXX: For some reason, setting the output format is not respected so I need to specify png here too
autocmd("graphviz_autocompile", {
  [[BufWritePost *.dot GraphvizCompile png]],
}, true)

-- Trying out folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Open all folds by default

-- fzf config
vim.g.fzf_preview_window = {}

-- fzf bindings
vim.keymap.set("n", "<C-p>", function()
  require("fzf-lua").git_files({
    cwd = vim.fn.getcwd(),
    previewer = false,
    scrollbar = false,
  })
end)
vim.keymap.set("n", "<C-b>", function()
  require("fzf-lua").buffers({
    previewer = false,
    scrollbar = false,
  })
end)

-- Make a :W command that is an alias for :w
vim.cmd("command W w")

-- Configure LSP
local lspconfig = require("lspconfig")
local null_ls = require("null-ls")
local trouble = require("trouble")

require("clangd_extensions.config").setup({
  extensions = { inlay_hints = { only_current_line = false, show_variable_name = true } },
})

local lsp = vim.lsp
-- local cmd = vim.cmd

local sign_define = vim.fn.sign_define
sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

trouble.setup({})

-- Global config for diagnostics
vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = false,
  severity_sort = false,
})

-- Show hover popup with a border
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

local async_formatting = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(bufnr, "textDocument/formatting", vim.lsp.util.make_formatting_params({}), function(err, res, ctx)
    if err then
      local err_msg = type(err) == "string" and err or err.message
      -- you can modify the log message / level (or ignore it completely)
      vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
      return
    end

    -- don't apply results if buffer is unloaded or has been modified
    if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
      return
    end

    if res then
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent noautocmd update")
      end)
    end
  end)
end

require("lsp_signature").setup({ bind = true, handler_opts = { border = "single" } })
local function on_attach(client, bufnr)
  local keymap_opts = { noremap = true, silent = true, buffer = bufnr }
  require("lsp_signature").on_attach({ bind = true, handler_opts = { border = "single" } })
  vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", keymap_opts)
  vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", keymap_opts)
  vim.keymap.set("n", "gTD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", keymap_opts)
  vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", keymap_opts)
  vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", keymap_opts)
  vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", keymap_opts)
  vim.keymap.set("n", "<leader>s", "<cmd>lua vim.lsp.buf.signature_help()<CR>", keymap_opts)
  vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", keymap_opts)
  vim.keymap.set("n", "<leader>.", "<cmd>lua vim.lsp.buf.code_action()<CR>", keymap_opts)
  vim.keymap.set("v", "<leader>.", "<cmd>lua vim.lsp.buf.range_code_action()<CR>", keymap_opts)
  vim.keymap.set("n", "]e", '<cmd>lua vim.diagnostic.goto_next { float = {scope = "line"} }<cr>', keymap_opts)
  vim.keymap.set("n", "[e", '<cmd>lua vim.diagnostic.goto_prev { float = {scope = "line"} }<cr>', keymap_opts)
  -- vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<cr>', keymap_opts)

  if client.supports_method("textDocument/formatting") then
    -- Set up auto formatting on save
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        -- sync
        vim.lsp.buf.format({ bufnr = bufnr })

        -- async
        -- async_formatting()
      end,
    })

    -- Manual formatting bindings
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, keymap_opts)
    vim.keymap.set("v", "<leader>f", function()
      local params = vim.lsp.util.make_given_range_params()
      params.async = true
      vim.lsp.buf.format(params)

      --
      if vim.fn.mode() ~= "n" then
        local keys = vim.api.nvim_replace_termcodes("<esc>", true, true, true)
        vim.api.nvim_feedkeys(keys, "n", false)
      end
    end, keymap_opts)
  end

  vim.cmd("augroup lsp_aucmds")
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd("au CursorHold <buffer> lua vim.lsp.buf.document_highlight()")
    vim.cmd("au CursorMoved <buffer> lua vim.lsp.buf.clear_references()")
  end

  vim.cmd("augroup END")
end

local function prefer_null_ls_fmt(client)
  client.server_capabilities.documentHighlightProvider = false
  client.server_capabilities.documentFormattingProvider = false
  on_attach(client)
end

local servers = {
  bashls = {},
  clangd = {
    on_attach = function()
      require("clangd_extensions.inlay_hints").setup_autocmd()
      require("clangd_extensions.inlay_hints").set_inlay_hints()
      require("clangd_extensions").hint_aucmd_set_up = true
    end,
    prefer_null_ls = true,
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=bundled",
      "--header-insertion=iwyu",
      "--cross-file-rename",
    },
    -- handlers = lsp_status.extensions.clangd.setup(),
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true,
    },
  },
  gopls = {},
  cmake = {},
  jsonls = {
    prefer_null_ls = true,
    init_options = {
      provideFormatter = false,
    },
  },
  cssls = {
    cmd = { "vscode-css-languageserver", "--stdio" },
    filetypes = { "css", "scss", "less", "sass" },
    root_dir = lspconfig.util.root_pattern("package.json", ".git"),
  },
  ghcide = {},
  html = { cmd = { "vscode-html-languageserver", "--stdio" } },
  pyright = {},
  -- ruff_lsp = { },
  rust_analyzer = {},
  lua_ls = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          },
        },
      },
    },
    prefer_null_ls = false,
  },
  tsserver = {},
  vimls = {},
}

local client_capabilities = require("cmp_nvim_lsp").default_capabilities()
client_capabilities.textDocument.completion.completionItem.snippetSupport = true
client_capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
client_capabilities.offsetEncoding = { "utf-16" }

for server, config in pairs(servers) do
  if type(config) == "function" then
    config = config()
  end

  if config.prefer_null_ls then
    if config.on_attach then
      local old_on_attach = config.on_attach
      config.on_attach = function(client, bufnr)
        old_on_attach(client, bufnr)
        prefer_null_ls_fmt(client)
      end
    else
      config.on_attach = prefer_null_ls_fmt
    end
  else
    if config.on_attach then
      local old_on_attach = config.on_attach
      config.on_attach = function(client, bufnr)
        old_on_attach(client, bufnr)
        prefer_null_ls_fmt(client)
      end
    else
      config.on_attach = on_attach
    end
  end

  config.capabilities = vim.tbl_deep_extend("keep", config.capabilities or {}, client_capabilities)
  lspconfig[server].setup(config)
end

-- null-ls setup
local null_fmt = null_ls.builtins.formatting
local null_diag = null_ls.builtins.diagnostics
null_ls.setup({
  debug = true,
  sources = {
    null_diag.actionlint,
    -- null_diag.cppcheck,
    -- null_diag.proselint,
    -- null_diag.pylint,
    null_diag.selene,
    null_diag.shellcheck,
    --null_diag.teal,
    -- null_diag.vale,
    --null_diag.vint,
    --null_diag.write_good.with { filetypes = { 'markdown', 'tex' } },
    null_fmt.clang_format,
    -- null_fmt.cmake_format,
    --null_fmt.isort,
    null_fmt.prettier,
    null_fmt.rustfmt,
    --null_fmt.shfmt,
    null_fmt.stylua,
    --null_fmt.trim_whitespace,
    -- null_fmt.yapf,
    null_fmt.black,
    -- null_fmt.ruff,
  },
  on_attach = on_attach,
})
