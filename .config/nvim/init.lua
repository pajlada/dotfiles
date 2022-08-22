require("plugins")

local utils = require("config.utils")
local autocmd = utils.autocmd
local map = utils.map

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

-- styling
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
map("n", "<leader>d", ":call CocActionAsync('jumpDefinition')<cr>")
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
map("v", "<leader>y", '"+y', { silent = true })
map("v", "<leader>p", '"+p', { silent = true })
map("n", "<leader>p", '"+p', { silent = true })

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

-- clang-format extension options
autocmd("clang-format auto enable", {
    [[ FileType c ClangFormatAutoEnable ]],
    [[ FileType cpp ClangFormatAutoEnable ]],
}, true)

-- Check for edits when focusing vim
autocmd("check_for_edits", {
    [[ FocusGained,BufEnter * :silent! checktime ]],
}, true)

require("plugin_configs")

require('lualine').setup {
    icons_enabled = false,
    theme = "onedark",
    sections = {
        lualine_b = {'filename'},
        lualine_c = {'branch', 'diff'},
        lualine_x = {},
        lualine_y = {'diagnostics'},
    }
}

require("nvim-autopairs").setup {}
