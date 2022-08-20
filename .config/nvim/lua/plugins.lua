-- Install packer if it's not already installed
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	packer_bootstrap =
		vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd([[packadd packer.nvim]])
end

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

    -- pretty icons xd
    use 'kyazdani42/nvim-web-devicons'

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
        config = function() require("config.cmp") end,
        event = 'InsertEnter *',
    }

	-- Theme
	use("navarasu/onedark.nvim")

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

	use("simrat39/rust-tools.nvim")

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
    }

	-- Plug 'integralist/vim-mypy'

	use("tomtom/tcomment_vim")

	use("sk1418/HowMuch")

	use("hashivim/vim-terraform")

	use("jparise/vim-graphql")

	use("nvim-treesitter/playground")

	use("kevinhwang91/promise-async")

	use({ "ckipp01/stylua-nvim", run = "cargo install stylua" })

     use {
         'nvim-lualine/lualine.nvim',
         requires = { 'kyazdani42/nvim-web-devicons' },
         config = function() -- TODO: Proper config file
             require("lualine").setup {
                 options = {
                     theme = "nord"
                 }
             }
         end
     }

	if packer_bootstrap then
	    require('packer').sync()
	end
end)
