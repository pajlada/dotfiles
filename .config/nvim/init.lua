vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0

vim.opt.termguicolors = true

vim.g.mapleader = " "

vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        -- Random functionality
        "nvim-tree/nvim-web-devicons",
        "chrisbra/improvedft",
        "mfussenegger/nvim-dap",
        "junegunn/fzf",
        {
            "ibhagwan/fzf-lua",
            -- optional for icon support
            config = function()
                require("fzf-lua").setup({
                    "max-perf",
                    defaults = {
                        git_icons = false,
                        file_icons = true,
                    },
                })
            end,
        },
        "rcarriga/nvim-notify",
        {
            "windwp/nvim-autopairs",
            config = true,
        },
        -- Adds a tab of all compiler errors, accessible through :Trouble
        -- {
        --     "folke/trouble.nvim",
        --     config = true,
        -- },

        -- LSP
        "neovim/nvim-lspconfig",
        {
            "ray-x/lsp_signature.nvim",
            opts = {
                bind = true,
                handler_opts = {
                    border = "rounded",
                },
            },
            config = true,
        },
        {
            "p00f/clangd_extensions.nvim",
            lazy = true,
            config = function() end,
            opts = {
                ast = {
                    --These require codicons (https://github.com/microsoft/vscode-codicons)
                    role_icons = {
                        type = "",
                        declaration = "",
                        expression = "",
                        specifier = "",
                        statement = "",
                        ["template argument"] = "",
                    },
                    kind_icons = {
                        Compound = "",
                        Recovery = "",
                        TranslationUnit = "",
                        PackExpansion = "",
                        TemplateTypeParm = "",
                        TemplateTemplateParm = "",
                        TemplateParamObject = "",
                    },
                },
            },
        },
        {
            "williamboman/mason.nvim",
            opts = {
                ensure_installed = {
                    "tinymist",
                },
            },
        },

        -- Highlighting
        {
            "romus204/tree-sitter-manager.nvim",
            dependencies = {}, -- tree-sitter CLI must be installed system-wide
            config = function()
                require("tree-sitter-manager").setup({
                    ensure_installed = {
                        "cmake",
                        "cpp",
                        -- "c_sharp",
                        "c",
                        "lua",
                        "rust",
                        "python",
                        "go",
                    },
                    -- Optional: custom paths
                    -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
                    -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
                })
            end,
        },
        -- {
        --     "nvim-treesitter/nvim-treesitter",
        --     build = ":TSUpdate",
        --     config = function()
        --         -- require("nvim-treesitter").install({ "cpp" })
        --         local configs = require("nvim-treesitter.configs")

        --         configs.setup({
        --             ensure_installed = {
        --                 "cmake",
        --                 "cpp",
        --                 "c_sharp",
        --                 "c",
        --                 "lua",
        --                 "rust",
        --                 "python",
        --                 "go",
        --             },
        --             context_commentstring = {
        --                 enable = true,
        --                 enable_autocmd = false,
        --             },
        --             highlight = { enable = true, use_languagetree = true },
        --             indent = { enable = false },
        --             endwise = { enable = true },
        --         })
        --     end,
        --     opts = {},
        -- },
        -- -- Adds "end" to function() in lua, and some other languages
        -- "RRethy/nvim-treesitter-endwise",

        -- Auto/tab-completions
        { "L3MON4D3/LuaSnip" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },
        { "saadparwaiz1/cmp_luasnip" },

        -- https://github.com/lukas-reineke/cmp-under-comparator
        -- Makes python completions for class methods sort better
        -- It ensures methods prefixed with __ aren't always on top
        "lukas-reineke/cmp-under-comparator",
        "hrsh7th/cmp-nvim-lsp-document-symbol",

        {
            "hrsh7th/nvim-cmp",
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                local has_words_before = function()
                    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                    return col ~= 0
                        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end

                cmp.setup({
                    preselect = cmp.PreselectMode.None,
                    completion = { completeopt = "menu,menuone,noinsert,noselect" },
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
                            vim_item.abbr = string.sub(vim_item.abbr, 1, vim.fn.winwidth(0) - 20)
                            return vim_item
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
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
                    }),
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

        -- Styling
        {
            "nvim-lualine/lualine.nvim",
            config = function()
                require("lualine").setup({
                    icons_enabled = false,
                    theme = "onedark",
                    sections = {
                        lualine_b = { "filename" },
                        -- lualine_c = { "branch", "diff" },
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = { "diagnostics" },
                    },
                })
            end,
        },
        {
            "navarasu/onedark.nvim",
            config = function()
                require("onedark").setup({
                    style = "darker",
                    colors = {
                        grey = "#878787",
                        green = "#00ffaa",
                    },
                    highlights = {
                        Visual = { bg = "#4a4a4a" },
                        LspReferenceText = { bg = "#303830" },
                        LspReferenceRead = { bg = "#303830" },
                        LspReferenceWrite = { bg = "#383030" },
                    },
                })
                require("onedark").load()
            end,
        },

        -- Language-specific things
        {
            "iamcco/markdown-preview.nvim",
            lazy = true,
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            build = function()
                vim.fn["mkdp#util#install"]()
            end,
        },

        {
            "izocha/graphviz.nvim",
            ft = { "dot" },
            config = true,
        },
    },
    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
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

-- Enable mode line
vim.opt.modeline = true

-- Disable swap files
vim.opt.swapfile = false

-- CursorHold after 500ms instead of default 4000ms
vim.o.updatetime = 500

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

-- vim.opt.spell = true

-- vim.opt.statusline = "%f%m%r%h%w [%{&ff}] %=[%03.3b/%02.2B] [POS=%04v]"

-- Store an undo buffer in a file in nvims default folder ($XDG_DATA_HOME/nvim/undo)
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

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

-- Copy to clipboard
-- SPACE+Y = Yank  (SPACE being leader)
-- SPACE+P = Paste
map("v", "<leader>y", '"+y', { silent = false })
map("v", "<leader>p", '"+p', { silent = true })
map("n", "<leader>p", '"+p', { silent = true })

-- Check for edits when focusing vim
autocmd("check_for_edits", {
    [[ FocusGained,BufEnter * :silent! checktime ]],
}, true)

-- Trying out folds
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldlevel = 99 -- Open all folds by default

-- Make a :W command that is an alias for :w
vim.cmd("command W w")

---- Plugin configs
require("graphviz").setup({
    format = "png",
    preview = "png",
})

-- Automatically compile dot files when saving
-- XXX: For some reason, setting the output format is not respected so I need to specify png here too
-- autocmd("graphviz_autocompile", {
--     [[BufWritePost *.dot GraphExport]],
-- }, true)

--- fzf
-- fzf config
vim.g.fzf_preview_window = {}

-- fzf bindings
vim.keymap.set("n", "<C-p>", function()
    require("fzf-lua").git_files({
        -- TODO: this doesn't work, stupid llm shit
        --         cmd = [[bash -c '
        --     git ls-files --exclude-standard |
        --       awk '{
        --         score = 0
        --         if ($0 ~ /^tests\//) score += 10    # deprioritize tests
        --         if ($0 ~ /\.(c|cc|cpp)$/) score += 1 # deprioritize sources
        --         print score "\t" $0
        --       }' |
        --       sort -k1,1n -k2,2 |
        --       cut -f2-
        --   ']],
        cwd = vim.fn.getcwd(),
        previewer = false,
        scrollbar = false,
        file_ignore_patterns = {
            ".*.png",
            ".*.wav",
        },
    })
end)
vim.keymap.set("n", "<C-b>", function()
    require("fzf-lua").buffers({
        previewer = false,
        scrollbar = false,
    })
end)
vim.keymap.set("n", "<C-k>", function()
    require("fzf-lua").files({
        cwd = vim.fn.getcwd(),
        previewer = false,
        scrollbar = false,
    })
end)

--- dap
local dap = require("dap")
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" },
}
dap.configurations.cpp = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}

-- The lua/user/lspconfig.lua contains most LSP-related functionality
require("user.lspconfig")

-- custom functions
local function Palc(opts)
    local view = vim.fn.winsaveview()

    for lnum = opts.line1, opts.line2 do
        vim.fn.cursor(lnum, 1)
        vim.cmd("norm <h^df]xwwlvi(x^I    pa, # wwwhD")
    end

    vim.fn.winrestview(view)
end
vim.api.nvim_create_user_command("Palc", Palc, { range = true })
