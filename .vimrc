set nocompatible
filetype off

call plug#begin('~/.vim/plugged')

" Plug 'scrooloose/syntastic'
Plug 'w0rp/ale'

" Python import sorter
Plug 'fisadev/vim-isort'

" Go plugin (does most things Go-related)
Plug 'fatih/vim-go'

" Fuzzy file finder (like Ctrl+K in other apps)
Plug 'ctrlpvim/ctrlp.vim'

Plug 'editorconfig/editorconfig-vim'

" Allow plugins to define their own operator
Plug 'kana/vim-operator-user'

" clang-format plugin
Plug 'rhysd/vim-clang-format'

" Plug which allows me to press a button to toggle between header and source
" file. Currently bound to LEADER+H
Plug 'ericcurtin/CurtineIncSw.vim'

" Completes ( with )
Plug 'jiangmiao/auto-pairs'

" Plug 'Rip-Rip/clang_complete'

" Plug 'Valloric/YouCompleteMe'

" Plug 'rust-lang/rust.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'rust-analyzer/rust-analyzer'

Plug 'leafgarland/typescript-vim'

Plug 'liuchengxu/graphviz.vim'

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'

call plug#end()
filetype plugin indent on

syntax on

" Ignore various cache/vendor folders
set wildignore+=*/node_modules/*,*/dist/*,*/__pycache__/*,*/venv/*

" Ignore C/C++ Object files
set wildignore+=*.o,*.obj
set wildignore+=*.ilk
set wildignore+=*/build/*
set wildignore+=*/build_native/*
set wildignore+=*/build-*/*
set wildignore+=*/vendor/*

" Ignore generated C/C++ Qt files
set wildignore+=moc_*.cpp,moc_*.h

" Ignore generated C/C++ Qt files
set wildignore+=moc_*.cpp,moc_*.h
" set wildignore+=*/lib/*
set wildignore+=*/target/debug/*
set wildignore+=*/target/release/*

" Ignore Unity asset meta-files
set wildignore+=*/Assets/*.meta

" Disable swap file. Some people say to keep swap file enabled but in a
" temporary folder instead. I dislike the dialog that pops up every now and
" then if a swapfile is left so I just leave it fully disabled
set noswapfile

" Enable line numbers
set number

" Don't wrap lines
set nowrap

" Let backspace delete indentations, newlines, and don't make it stop after
" reaching the start of your insert mode
set backspace=indent,eol,start

" Incremental search. start searching and moving through the file while typing
" the search phrase
set incsearch

" Other options that I just copied and haven't tried understanding yet
set showmode
set nocompatible
set wildmenu
set lazyredraw
set hidden
set softtabstop=4
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set cindent
set mouse=a
set cursorline
set numberwidth=6
set encoding=utf-8

" Enable relative line numbering
set rnu

" Disable mode line
set nomodeline

" Customize our status line
set statusline=%f%m%r%h%w\ 
set statusline+=[%{&ff}]
set statusline+=%=
set statusline+=[\%03.3b/\%02.2B]\ [POS=%04v]

set laststatus=2

if &t_Co == 256
    " If we're on a 256-color terminal, use pixelmuerto color scheme
    colorscheme pixelmuerto
else
    " Else fall back to ron
    colorscheme ron
    hi CursorLine term=bold cterm=bold guibg=Grey40
endif

" Make a slight customization with the cursorline to the ron theme
set cursorline

" Store an undo buffer in a file in $HOME/.vimundo
set undofile
set undodir=$HOME/.vimundo
set undolevels=1000
set undoreload=10000

" Use ; as :
" Very convenient as you don't have to press shift to run commands
nnoremap ; :

" Unbind Q (it used to take you into Ex mode)
nnoremap Q <nop>

" Unbind F1 (it used to show you a help menu)
nnoremap <F1> <nop>

" Unbind Shift+K, it's previously used for opening manual or help or something
map <S-k> <Nop>

let g:syntastic_mode_map = { 'mode': 'active',
                          \ 'active_filetypes': [],
                          \ 'passive_filetypes': ['cpp', 'c'] }
"let g:syntastic_auto_loc_list=1
"
" let g:syntastic_go_checkers = ['gometalinter']
let g:syntastic_go_checkers = ['go']

nnoremap <silent> <F5> :lnext<CR>
nnoremap <silent> <F6> :lprev<CR>
nnoremap <silent> <C-Space> :ll<CR>

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_cpp_checker = 1
let g:syntastic_cpp_checkers=['clang_tidy']
let g:syntastic_cpp_clang_tidy_post_args=""
let g:ale_linters = { 'cpp': ['clangcheck', 'clangtidy', 'clang-format', 'clazy', 'cquery', 'uncrustify'] }
" let g:syntastic_cpp_clang_tidy_config_file=['/home/pajlada/work/vapour/.clang-tidy']

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*)}
"

let mapleader = "\<Space>"
let g:go_fmt_command = "gofmt"
let g:go_fmt_options = {
  \ 'gofmt': '-s',
  \ }

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <leader>d <Plug>(go-doc)
au FileType go nmap <leader>e :GoIfErr<CR>

au FileType cpp nmap <leader>c :call SyntasticCheck()<CR>
au FileType cpp nmap <leader>f <Plug>(operator-clang-format)
au FileType cpp nmap <leader>h :call CurtineIncSw()<CR>
au FileType c nmap <leader>f <Plug>(operator-clang-format)
au FileType c nmap <leader>h :call CurtineIncSw()<CR>

" Python leader-bindings (Space+Key)
au FileType python nmap <leader>f <Plug>(ale_fix)

au FileType javascript setlocal ts=2 sw=2 sts=2
au FileType html setlocal ts=2 sw=2 sts=2

autocmd! BufWritePost *.go :GoImports
" autocmd! BufWritePost *.go :GoMetaLinter

" ctrlpvim/ctrlp.vim extension options
" let g:ctrlp_cmd = 'CtrlP .'
let g:ctrlp_working_path_mode = 'rwa'

nnoremap <silent> <C-B> :CtrlPBuffer<CR>
nnoremap <silent> <C-K> :CtrlPMixed<CR>
nnoremap <silent> <C-Y> :CtrlPTag<CR>

" clang-format extension options
autocmd FileType c ClangFormatAutoEnable
autocmd FileType cpp ClangFormatAutoEnable
autocmd FileType javascript ClangFormatAutoDisable

" clang_complete
let g:clang_library_path='/usr/local/lib/libclang.so'
let g:clang_auto_select=1
let g:clang_close_preview=1

let g:ale_fixers = {
    \ 'python': ['black'],
    \ 'typescript': ['tslint'],
    \ 'rust': ['rustfmt'],
  \ }

" auto-pairs
" let g:AutoPairsMapCR = 0
" imap <silent><CR> <CR><Plug>AutoPairsReturn

" YouCompleteMe
let g:ycm_python_binary_path = '/usr/bin/python3'
let g:ycm_key_list_stop_completion = ['<C-y>', '<CR>']

let g:rustfmt_autosave = 1

let g:go_list_type = "quickfix"
let g:go_metalinter_autosave = 0

au FocusGained,BufEnter * :silent! checktime

let g:clang_format#enable_fallback_style = 0

let g:vim_isort_python_version = 'python3'

" SPACE+Y = Yank  (SPACE being leader)
" SPACE+P = Paste
vmap <silent> <leader>y :w !xsel -i -b<CR><CR>

" Graphviz
"" Compile .dot-files to png
let g:graphviz_output_format = 'png'

"" Open Graphviz results with sxiv
let g:graphviz_viewer = 'sxiv'

"" Automatically compile dot files when saving
"" XXX: For some reason, setting the output format is not respected so I need to specify png here too
autocmd BufWritePost *.dot GraphvizCompile png

if executable('cquery')
   au User lsp_setup call lsp#register_server({
      \ 'name': 'cquery',
      \ 'cmd': {server_info->['cquery']},
      \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},
      \ 'initialization_options': { 'cacheDirectory': '/home/pajlada/.cache/cquery' },
      \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
      \ })
endif

nn <f2> :LspRename<cr>
nn <silent> <C-h> :LspHover<cr>
nn <silent> <C-g> :LspPeekDefinition<cr>

" Macro @e will take your default register (whatever you last yanked) and create an ostream operator for it as if it's an enum.
" This expected your register to be formatted like this:
" A,
" B,
" C,
" Enums with values do not work.
let @e='POinline std::ostream &operator<<(std::ostream &os, Type v){€ýadd}i}%oswitch (v) {€ýa%O}€ýa%jVi{:norm ^veyIcase Type::$i: return os << "p$s";joreturn os << static_cast<int>(v);'

let g:lsp_preview_keep_focus = 0

set viminfo+=n~/.vim/viminfo

let g:ale_fix_on_save = 1
