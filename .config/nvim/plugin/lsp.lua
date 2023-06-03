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
