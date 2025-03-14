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
    spec = {
        -- Random functionality
        "nvim-tree/nvim-web-devicons",
        "mfussenegger/nvim-dap",
        "junegunn/fzf",
        {
            "ibhagwan/fzf-lua",
            -- optional for icon support
            config = function()
                require("fzf-lua").setup({
                    "max-perf",
                    defaults = {
                        git_icons = true,
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
        "nvim-lua/lsp-status.nvim",
        "neovim/nvim-lspconfig",
        -- {
        --     "mrcjkb/rustaceanvim",
        --     version = "^5",
        --     lazy = false, -- This plugin is already lazy
        -- },
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
                        "c_sharp",
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
                    return col ~= 0 and
                        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end

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
                            vim_item.abbr = string.sub(vim_item.abbr, 1, vim.fn.winwidth(0) - 20)
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
                        lualine_c = { "require'lsp-status'.status()" },
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
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Open all folds by default

-- Make a :W command that is an alias for :w
vim.cmd("command W w")

---- Plugin configs

--- graphviz
-- Compile .dot-files to png
vim.g.graphviz_output_format = "png"

-- Open Graphviz results with sxiv
vim.g.graphviz_viewer = "sxiv"

-- Automatically compile dot files when saving
-- XXX: For some reason, setting the output format is not respected so I need to specify png here too
autocmd("graphviz_autocompile", {
    [[BufWritePost *.dot GraphvizCompile png]],
}, true)

--- fzf
-- fzf config
vim.g.fzf_preview_window = {}

-- fzf bindings
vim.keymap.set("n", "<C-p>", function()
    require("fzf-lua").git_files({
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

local function shared_on_attach(client, bufnr)
    local keymap_opts = { noremap = true, silent = true, buffer = bufnr }
    -- require("lsp_signature").on_attach({ bind = true, handler_opts = { border = "rounded" } })
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
    vim.keymap.set("n", "]f",
        '<cmd>lua vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR, float = {scope = "line"} }<cr>',
        keymap_opts)
    vim.keymap.set("n", "[f",
        '<cmd>lua vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR, float = {scope = "line"} }<cr>',
        keymap_opts)
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
    else
        print("client DOES NOT support formatting")
    end

    vim.cmd("augroup lsp_aucmds")
    if client.server_capabilities.documentHighlightProvider then
        vim.cmd("au CursorHold <buffer> lua vim.lsp.buf.document_highlight()")
        vim.cmd("au CursorMoved <buffer> lua vim.lsp.buf.clear_references()")
    end

    vim.cmd("augroup END")
end

--- Rustaceanvim
vim.g.rustaceanvim = {
    -- Plugin configuration
    tools = {
        enable_clippy = true,
    },
    -- LSP configuration
    server = {
        on_attach = shared_on_attach,
        default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
                cargo = {
                    allFeatures = true,
                    loadOutDirsFromCheck = true,
                    buildScripts = {
                        enable = true,
                    },
                },
                checkOnSave = true,
            },
        },
    },
    -- DAP configuration
    dap = {
    },
}

--- dap
local dap = require("dap")
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" }
}
dap.configurations.cpp = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}

--- clangd
autocmd("clangd_toggle_source_header", {
    [[ FileType cpp nmap <leader>h :ClangdSwitchSourceHeader<CR>]],
    [[ FileType c nmap <leader>h :ClangdSwitchSourceHeader<CR>]],
}, true)



--- lspconfig
local lspconfig = require("lspconfig")

local servers = {
    rust_analyzer = {},
    bashls = {},
    astro = {},
    clangd = {
        on_attach = function()
            -- vim.lsp.inlay_hint.enable()
            require("clangd_extensions").hint_aucmd_set_up = true
        end,
        -- prefer_null_ls = true,
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
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "hpp" },
    },
    gopls = {},
    cmake = {},
    jsonls = {
        -- prefer_null_ls = true,
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
    ruff = {},
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
        -- prefer_null_ls = false,
    },
    ts_ls = {},
    vimls = {},
}

local client_capabilities = {
    offsetEncoding = { "utf-16" },
}
-- client_capabilities.textDocument.completion.completionItem.snippetSupport = true
-- client_capabilities.textDocument.completion.completionItem.resolveSupport = {
--     properties = { "documentation", "detail", "additionalTextEdits" },
-- }
-- client_capabilities.offsetEncoding = { "utf-16" }

for server, config in pairs(servers) do
    if type(config) == "function" then
        config = config()
    end

    if config.on_attach then
        local old_on_attach = config.on_attach
        config.on_attach = function(client, bufnr)
            old_on_attach(client, bufnr)
            shared_on_attach(client, bufnr)
        end
    else
        config.on_attach = shared_on_attach
    end

    config.capabilities = vim.tbl_deep_extend("keep", config.capabilities or {}, client_capabilities)
    lspconfig[server].setup(config)
end

-- TEMPORARY WORKAROUND
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
