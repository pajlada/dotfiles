-- Key bindings / actions to be attached whenever an LSP is attached to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method("textDocument/implementation") then
            vim.keymap.set("n", "gi", function()
                vim.lsp.buf.implementation()
            end)
        end
        if client:supports_method("textDocument/declaration") then
            vim.keymap.set("n", "gD", function()
                vim.lsp.buf.declaration()
            end)
        end
        if client:supports_method("textDocument/definition") then
            vim.keymap.set("n", "gd", function()
                vim.lsp.buf.definition()
            end)
        end

        -- TODO: confirm client supports these functions?
        vim.keymap.set("n", "gTD", function()
            vim.lsp.buf.type_definition()
        end)

        vim.keymap.set("n", "gr", function()
            vim.lsp.buf.references()
        end)

        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover()
        end)

        vim.keymap.set("n", "<leader>s", function()
            vim.lsp.buf.signature_help()
        end)

        vim.keymap.set("n", "<leader>rn", function()
            vim.lsp.buf.rename()
        end)

        vim.keymap.set({ "n", "v" }, "<leader>.", function()
            vim.lsp.buf.code_action()
        end)

        vim.keymap.set("n", "]e", function()
            vim.diagnostic.jump({
                count = 1,
                float = { scope = "line" },
            })
        end)

        vim.keymap.set("n", "[e", function()
            vim.diagnostic.jump({
                count = -1,
                float = { scope = "line" },
            })
        end)

        vim.keymap.set("n", "]f", function()
            vim.diagnostic.jump({
                count = 1,
                float = { scope = "line" },
                severity = vim.diagnostic.severity.ERROR,
            })
        end)

        vim.keymap.set("n", "[f", function()
            vim.diagnostic.jump({
                count = -1,
                float = { scope = "line" },
                severity = vim.diagnostic.severity.ERROR,
            })
        end)

        vim.keymap.set("n", "<leader>d", function()
            vim.diagnostic.open_float()
        end)

        if client:supports_method("textDocument/formatting") then
            -- Manual formatting bindings
            vim.keymap.set({ "n", "v" }, "<leader>f", function()
                vim.lsp.buf.format({ async = true })
            end)

            -- Auto-format ("lint") on save.
            -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
            if not client:supports_method("textDocument/willSaveWaitUntil") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
                    buffer = args.buf,
                    callback = function()
                        vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                    end,
                })
            end
        end

        if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
            vim.api.nvim_clear_autocmds({ buffer = args.buf, group = "lsp_document_highlight" })
            vim.api.nvim_create_autocmd("CursorHold", {
                callback = vim.lsp.buf.document_highlight,
                buffer = args.buf,
                group = "lsp_document_highlight",
                desc = "Document Highlight",
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
                callback = vim.lsp.buf.clear_references,
                buffer = args.buf,
                group = "lsp_document_highlight",
                desc = "Clear All the References",
            })
        end
    end,
})

--- Lua
-- Lua language server, mostly used for neovim stuff. from https://github.com/neovim/nvim-lspconfig/blob/d696e36d5792daf828f8c8e8d4b9aa90c1a10c2a/lsp/lua_ls.lua
vim.lsp.config("lua_ls", {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath("config")
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    -- Depending on the usage, you might want to add additional paths
                    -- here.
                    -- '${3rd}/luv/library'
                    -- '${3rd}/busted/library'
                },
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
            },
            format = {
                -- use stylua instead
                enable = false,
            },
        })
    end,
    settings = {
        Lua = {
            format = {
                enable = false,
            },
        },
    },
})
-- using stylua for lua code formatting
vim.lsp.config("stylua", {})
vim.lsp.enable({ "stylua", "lua_ls" })

-- Unsorted
local servers = {
    rust_analyzer = {},
    bashls = {},
    astro = {},
    tinymist = {
        -- for typst
        settings = {
            formatterMode = "typstyle",
            exportPdf = "never",
            semanticTokens = "disable",
        },
        init_options = {
            provideFormatter = false,
        },
    },
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
    jsonls = {
        -- prefer_null_ls = true,
        init_options = {
            provideFormatter = false,
        },
    },
    cssls = {
        cmd = { "vscode-css-languageserver", "--stdio" },
        filetypes = { "css", "scss", "less", "sass" },
        -- testing to avoid lspconfig.util.root_pattern, maybe this is just not needed
        -- root_dir = lspconfig.util.root_pattern("package.json", ".git"),
    },
    neocmake = {
        filetypes = { "cmake" },
    },
    ghcide = {},
    html = { cmd = { "vscode-html-languageserver", "--stdio" } },
    pyright = {},
    ruff = {},
    ts_ls = {},
    vimls = {},
    -- typos_lsp = {},
}

for server, config in pairs(servers) do
    if type(config) == "function" then
        config = config()
    end

    local client_capabilities = {
        offsetEncoding = { "utf-16" },
    }

    config.capabilities = vim.tbl_deep_extend("keep", config.capabilities or {}, client_capabilities)
    -- lspconfig[server].setup(config)
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
end

-- This was temporarily necessary for clippy because it threw weird errors
for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
