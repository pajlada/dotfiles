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
-- configuration in after/lsp/stylua.lua and after/lsp/lua_ls.lua
vim.lsp.enable({ "stylua", "lua_ls" })

--- C++
--- configuration in after/lsp/clangd.lua
vim.lsp.enable("clangd")

--- typst
--- configuration in after/lsp/tinymist.lua
vim.lsp.enable("tinymist")

--- Go
--- using default nvim-lspconfig configuration
vim.lsp.enable("gopls")

--- Rust
vim.lsp.config("rust_analyzer", {})
vim.lsp.enable("rust_analyzer")

vim.lsp.enable("gh_actions_ls")

-- Unsorted
local servers = {
    bashls = {},
    astro = {},
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
