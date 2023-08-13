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
