-- Install packer if it's not already installed
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = true
    vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
end

return require("packer").startup({ function(use)
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
            { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
            'hrsh7th/cmp-nvim-lsp',
            { 'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
            { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
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
                    grey = "#878787", -- define a new color
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
        run = "cd app && npm install",
        setup = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    })

    -- Python import sorter
    use("stsewd/isort.nvim")

    -- Go plugin (does most things Go-related)
    use("fatih/vim-go")

    -- Fuzzy file finder (like Ctrl+K in other apps)
    use("ctrlpvim/ctrlp.vim")

    use("editorconfig/editorconfig-vim")

    -- Allow plugins to define their own operator
    use("kana/vim-operator-user")

    -- clang-format plugin
    use("rhysd/vim-clang-format")

    -- Plug which allows me to press a button to toggle between header and source
    -- file. Currently bound to LEADER+H
    use("ericcurtin/CurtineIncSw.vim")

    use("rust-lang/rust.vim")

    -- use({ "neoclide/coc.nvim", branch = "release" })

    use({
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
                                command = "clippy"
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

    use("tomtom/tcomment_vim")

    use("sk1418/HowMuch")

    use("hashivim/vim-terraform")

    use("jparise/vim-graphql")

    use("nvim-treesitter/playground")

    use("kevinhwang91/promise-async")

    use({ "ckipp01/stylua-nvim", run = "cargo install stylua" })

    if packer_bootstrap then
        require('packer').sync()
    end
end, config = {
    log = {
        level = "trace",
    },
} })
