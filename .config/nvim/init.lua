-- Install packer if it's not already installed
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = true
    vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
end

require("packer").startup({
    function(use)
        -- Packer can manage itself
        use("wbthomason/packer.nvim")

        use({
            'nvim-lualine/lualine.nvim',
            config = function()
                require("lualine").setup({
                    icons_enabled = false,
                    theme = "onedark",
                    sections = {
                        lualine_b = { 'filename' },
                        lualine_c = { 'branch', 'diff' },
                        lualine_x = {},
                        lualine_y = { 'diagnostics' },
                    }
                })
            end,
        })


        -- Highlighting
        use({
            {
                "nvim-treesitter/nvim-treesitter",
                requires = {
                    "nvim-treesitter/nvim-treesitter-refactor",
                    "RRethy/nvim-treesitter-textsubjects",
                },
                run = ":TSUpdate",
            },
            { "RRethy/nvim-treesitter-endwise" },
        })

        -- Completion
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                'L3MON4D3/LuaSnip',
                { 'hrsh7th/cmp-buffer',                  after = 'nvim-cmp' },
                'hrsh7th/cmp-nvim-lsp',
                { 'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' },
                { 'hrsh7th/cmp-path',                    after = 'nvim-cmp' },
                { 'hrsh7th/cmp-nvim-lua',                after = 'nvim-cmp' },
                { 'saadparwaiz1/cmp_luasnip',            after = 'nvim-cmp' },
                'lukas-reineke/cmp-under-comparator',
                { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
            },
            config = function() require('config.cmp') end,
        }

        -- Theme
        use({
            "navarasu/onedark.nvim",
            config = function()
                require("onedark").setup {
                    style = "darker",
                    colors = {
                        grey = "#878787",  -- define a new color
                        green = "#00ffaa", -- redefine an existing color
                    },
                    highlights = {
                        Visual = { bg = "#4a4a4a" },
                    },
                }
                require("onedark").load()
            end
        })

        use({
            "iamcco/markdown-preview.nvim",
            run = function() vim.fn["mkdp#util#install"]() end,
            setup = function()
                vim.g.mkdp_filetypes = { "markdown" }
            end,
            ft = { "markdown" },
        })

        -- Python import sorter
        use("stsewd/isort.nvim")

        -- Go plugin (does most things Go-related)
        use("fatih/vim-go")

        use("junegunn/fzf")
        use { 'ibhagwan/fzf-lua',
            -- optional for icon support
            requires = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                require("fzf-lua").setup({
                    "max-perf",
                    global_git_icons = true,
                    global_file_icons = true,
                })
            end,
        }

        use("gpanders/editorconfig.nvim")

        -- Allow plugins to define their own operator
        use("kana/vim-operator-user")

        -- Plug which allows me to press a button to toggle between header and source
        -- file. Currently bound to LEADER+H
        use("ericcurtin/CurtineIncSw.vim")

        use("rust-lang/rust.vim")

        -- use({ "neoclide/coc.nvim", branch = "release" })

        use({
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "folke/trouble.nvim",
            "ray-x/lsp_signature.nvim",
            {
                "kosayoda/nvim-lightbulb",
                requires = "antoinemadec/FixCursorHold.nvim",
            },
        })

        use("p00f/clangd_extensions.nvim")

        use {
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
                            }
                        }
                    },
                })
            end
        }
        use 'simrat39/inlay-hints.nvim'

        use 'nvim-lua/plenary.nvim'

        use({
            "jose-elias-alvarez/null-ls.nvim",
            requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        })

        -- Plug 'rust-analyzer/rust-analyzer'

        use("leafgarland/typescript-vim")

        use("liuchengxu/graphviz.vim")

        use("prabirshrestha/async.vim")

        use("martinda/Jenkinsfile-vim-syntax")

        use("modille/groovy.vim")

        use 'rcarriga/nvim-notify'

        use {
            "windwp/nvim-autopairs",
            config = function()
                require("nvim-autopairs").setup {}
            end
        }

        -- Plug 'integralist/vim-mypy'

        use("sk1418/HowMuch")

        use("hashivim/vim-terraform")

        use("jparise/vim-graphql")

        use("nvim-treesitter/playground")

        use("kevinhwang91/promise-async")

        use({ "ckipp01/stylua-nvim", run = "cargo install stylua" })

        if packer_bootstrap then
            require('packer').sync()
        end
    end,
    config = {
        log = {
            -- level = "trace",
        },
    }
})

local function autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == 'string' then
        cmds = { cmds }
    end
    vim.cmd('augroup ' .. group)
    if clear then
        vim.cmd [[au!]]
    end
    for _, c in ipairs(cmds) do
        vim.cmd('autocmd ' .. c)
    end
    vim.cmd [[augroup END]]
end

local function map(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    if type(modes) == 'string' then
        modes = { modes }
    end
    for _, mode in ipairs(modes) do
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
end

vim.opt.showmode = false

vim.opt.termguicolors = true

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

vim.g.mapleader = " "

vim.g.python3_host_prog = "/home/pajlada/.local/share/nvim/venv/bin/python3"

-- isort
autocmd("isort for python",
    [[ FileType python vnoremap <buffer> <C-i> :Isort<CR>]],
    true)

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

-- coc
map("n", "<leader>j", ":call CocAction('diagnosticNext')<cr>")
map("n", "<leader>k", ":call CocAction('diagnosticPrevious')<cr>")
map("n", "<leader>t", "<Plug>(coc-references)")
map("n", "<leader>w", "<Plug>(coc-references-used)")
map("n", "<leader>r", ":<C-u>call CocAction('jumpReferences')<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-f>", function()
    return vim.fn["coc#float#has_scroll"]() and vim.fn["coc#float#scroll"](1) or t("<C-f>")
end, { silent = true, noremap = true, nowait = true, expr = true })
vim.keymap.set("n", "<C-b>", function()
    return vim.fn["coc#float#has_scroll"]() and vim.fn["coc#float#scroll"](0) or t("<C-b>")
end, { silent = true, noremap = true, nowait = true, expr = true })

vim.keymap.set("n", "K", function()
    local filetype = vim.bo.filetype

    if filetype == "vim" or filetype == "help" then
        vim.api.nvim_command("h " .. filetype)
    elseif vim.fn["coc#rpc#ready"]() then
        vim.fn.CocActionAsync("doHover")
    else
        vim.api.nvim_command("!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>"))
    end
end, { silent = true, noremap = true })

vim.keymap.set("n", "<C-h>", function()
    vim.fn.CocAction("doHover")
end, { silent = true, noremap = true })

autocmd("coc_cpp", {
    [[ FileType cpp nmap <leader>f <Plug>(coc-fix-current) ]],
    [[ FileType cpp nmap <leader>h :ClangdSwitchSourceHeader<CR>]],
    [[ FileType c nmap <leader>h :ClangdSwitchSourceHeader<CR>]],
}, true)

autocmd("coc_python", {
    [[ FileType python let b:coc_root_patterns = ['.git', '.env', 'venv', '.venv', 'setup.cfg', 'setup.py', 'pyproject.toml', 'pyrightconfig.json'] ]],
}, true)

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

-- CtrlP
vim.g.ctrlp_working_path_mode = "rwa"

map("n", "<C-B>", ":CtrlPBuffer<CR>", { noremap = true, silent = true })
map("n", "<C-Y>", ":CtrlPTag<CR>", { noremap = true, silent = true })

-- Reload LSP
map("n", "<leader>L", ":lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>:edit<CR>")

-- clang_format
vim.g["clang_format#enable_fallback_style"] = 0

-- Check for edits when focusing vim
autocmd("check_for_edits", {
    [[ FocusGained,BufEnter * :silent! checktime ]],
}, true)

autocmd("packer_user_config", {
    [[ BufWritePost plugins.lua source <afile> | PackerCompile ]]
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
vim.keymap.set('n', '<C-p>', function()
    require('fzf-lua').git_files({
        cwd = vim.fn.getcwd(),
        previewer = false,
        scrollbar = false,
    })
end)
vim.keymap.set('n', '<C-b>', function()
    require('fzf-lua').buffers({
        previewer = false,
        scrollbar = false,
    })
end)

-- Make a :W command that is an alias for :w
vim.cmd("command W w")

-- Configure LSP
local lspconfig = require 'lspconfig'
local trouble = require 'trouble'
local null_ls = require 'null-ls'
local lightbulb = require 'nvim-lightbulb'

require('clangd_extensions.config').setup {
    extensions = { inlay_hints = { only_current_line = false, show_variable_name = true } },
}

local lsp = vim.lsp
local cmd = vim.cmd

vim.api.nvim_command 'hi link LightBulbFloatWin YellowFloat'
vim.api.nvim_command 'hi link LightBulbVirtualText YellowFloat'

local kind_symbols = {
    Text = '  ',
    Method = '  ',
    Function = '  ',
    Constructor = '  ',
    Field = '  ',
    Variable = '  ',
    Class = '  ',
    Interface = '  ',
    Module = '  ',
    Property = '  ',
    Unit = '  ',
    Value = '  ',
    Enum = '  ',
    Keyword = '  ',
    Snippet = '  ',
    Color = '  ',
    File = '  ',
    Reference = '  ',
    Folder = '  ',
    EnumMember = '  ',
    Constant = '  ',
    Struct = '  ',
    Event = '  ',
    Operator = '  ',
    TypeParameter = '  ',
}

local sign_define = vim.fn.sign_define
sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

trouble.setup {}
lightbulb.setup {}

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

    vim.lsp.buf_request(
        bufnr,
        "textDocument/formatting",
        vim.lsp.util.make_formatting_params({}),
        function(err, res, ctx)
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
        end
    )
end

require('lsp_signature').setup { bind = true, handler_opts = { border = 'single' } }
local function on_attach(client, bufnr)
    local keymap_opts = { noremap = true, silent = true, buffer = bufnr }
    require('lsp_signature').on_attach { bind = true, handler_opts = { border = 'single' } }
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', keymap_opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', keymap_opts)
    vim.keymap.set('n', 'gTD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', keymap_opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', keymap_opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', keymap_opts)
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', keymap_opts)
    vim.keymap.set('n', '<leader>s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', keymap_opts)
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', keymap_opts)
    vim.keymap.set('n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<CR>', keymap_opts)
    vim.keymap.set('v', '<leader>.', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', keymap_opts)
    vim.keymap.set('n', ']e', '<cmd>lua vim.diagnostic.goto_next { float = {scope = "line"} }<cr>', keymap_opts)
    vim.keymap.set('n', '[e', '<cmd>lua vim.diagnostic.goto_prev { float = {scope = "line"} }<cr>', keymap_opts)
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
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format({ async = true })
        end, keymap_opts)
        vim.keymap.set('v', '<leader>f', function()
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

    cmd 'augroup lsp_aucmds'
    if client.server_capabilities.documentHighlightProvider then
        cmd 'au CursorHold <buffer> lua vim.lsp.buf.document_highlight()'
        cmd 'au CursorMoved <buffer> lua vim.lsp.buf.clear_references()'
    end

    cmd 'au CursorHold,CursorHoldI <buffer> lua require"nvim-lightbulb".update_lightbulb ()'
    cmd 'augroup END'
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
            require('clangd_extensions.inlay_hints').setup_autocmd()
            require('clangd_extensions.inlay_hints').set_inlay_hints()
            require('clangd_extensions').hint_aucmd_set_up = true
        end,
        prefer_null_ls = true,
        cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=bundled',
            '--header-insertion=iwyu',
            '--cross-file-rename',
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
    cssls = {
        cmd = { 'vscode-css-languageserver', '--stdio' },
        filetypes = { 'css', 'scss', 'less', 'sass' },
        root_dir = lspconfig.util.root_pattern('package.json', '.git'),
    },
    ghcide = {},
    html = { cmd = { 'vscode-html-languageserver', '--stdio' } },
    pyright = {},
    rust_analyzer = {},
    lua_ls = {
        cmd = { 'lua-language-server' },
        settings = {
            Lua = {
                diagnostics = { globals = { 'vim' } },
                runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
                workspace = {
                    library = {
                        [vim.fn.expand '$VIMRUNTIME/lua'] = true,
                        [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
                    },
                },
            },
        },
        prefer_null_ls = false,
    },
    texlab = {
        settings = {
            texlab = {
                build = {
                    args = { "-lualatex", "-shell-escape", "-file-line-error", "-synctex=1",
                        "-interaction=nonstopmode",
                        "%f" },
                    onSave = true,
                    forwardSearchAfter = true -- Automatically open after building
                },
                chktex = { onOpenAndSave = true },
                formatterLineLength = 100,
                forwardSearch = { executable = 'zathura', args = { '--synctex-forward', '%l:1:%f', '%p' } },
            },
        },
        commands = {
            TexlabForwardSearch = {
                function()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    local params = {
                        textDocument = { uri = vim.uri_from_bufnr(0) },
                        position = { line = pos[1] - 1, character = pos[2] },
                    }
                    lsp.buf_request(0, 'textDocument/forwardSearch', params, function(err, _, _, _)
                        if err then
                            error(tostring(err))
                        end
                    end)
                end,
                description = 'Run synctex forward search',
            },
        },
    },
    tsserver = {},
    vimls = {},
}

require("mason").setup()
require("mason-lspconfig").setup()

local client_capabilities = require('cmp_nvim_lsp').default_capabilities()
client_capabilities.textDocument.completion.completionItem.snippetSupport = true
client_capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
}
client_capabilities.offsetEncoding = { 'utf-16' }

for server, config in pairs(servers) do
    if type(config) == 'function' then
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

    config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, client_capabilities)
    lspconfig[server].setup(config)
end

-- null-ls setup
local null_fmt = null_ls.builtins.formatting
local null_diag = null_ls.builtins.diagnostics
local null_act = null_ls.builtins.code_actions
null_ls.setup {
    debug = true,
    sources = {
        null_diag.chktex,
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
        --null_fmt.stylua,
        --null_fmt.trim_whitespace,
        -- null_fmt.yapf,
        null_fmt.black
        --null_act.gitsigns,
        --null_act.refactoring.with { filetypes = { 'javascript', 'typescript', 'lua', 'python', 'c', 'cpp' } },
    },
    on_attach = on_attach,
}

-- Configure TreeSitter
local ts_configs = require("nvim-treesitter.configs")
ts_configs.setup {
    ensure_installed = { "cpp", "c", "lua", "rust", "python", "go", "kotlin" },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    highlight = { enable = true, use_languagetree = true },
    indent = { enable = false },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
    refactor = {
        --smart_rename = { enable = true, keymaps = { smart_rename = 'grr' } }, -- Rename provided by LSP
        highlight_definitions = { enable = true },
        -- highlight_current_scope = { enable = true }
    },
    textsubjects = {
        enable = true,
        keymaps = {
            ['.'] = 'textsubjects-smart',
            [';'] = 'textsubjects-container-outer',
            ['i;'] = 'textsubjects-container-inner',
        },
    },
    endwise = { enable = true },
}
