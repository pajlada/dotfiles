set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Package manager KKona
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/syntastic'

" Python import sorter
Plugin 'fisadev/vim-isort'

" Go plugin (does most things Go-related)
Plugin 'fatih/vim-go'

Plugin 'neomake/neomake'

" Fuzzy file finder (like Ctrl+K in other apps)
Plugin 'ctrlpvim/ctrlp.vim'

Plugin 'editorconfig/editorconfig-vim'

" clang-format plugin
Plugin 'rhysd/vim-clang-format'

" Plugin which allows me to press a button to toggle between header and source
" file. Currently bound to LEADER+H
Plugin 'ericcurtin/CurtineIncSw.vim'

" Completes ( with )
Plugin 'jiangmiao/auto-pairs'

call vundle#end()
filetype plugin indent on

syntax on

" Ignore various cache/vendor folders
set wildignore+=*/node_modules/*,*/dist/*,*/__pycache__/*

" Ignore C/C++ Object files
set wildignore+=*.o

" Ignore generated C/C++ Qt files
set wildignore+=moc_*.cpp,moc_*.h

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

" Other options that I just copied and haven't tried understanding yet
set incsearch
set showmode
set nocompatible
filetype on
set wildmenu
set ruler
set lz
set hid
set softtabstop=4
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set cindent
set ai
set si
set cin
set mouse=a
set cursorline
set numberwidth=6
set encoding=utf-8

" Enable relative line numbering
set rnu

" Customize our status line
set statusline=%f%m%r%h%w\ 
set statusline+=[%{&ff}]
set statusline+=%=
set statusline+=[\%03.3b/\%02.2B]\ [POS=%04v]

set laststatus=2

" By default, use the "ron" colorscheme
colorscheme ron

" Make a slight customization with the cursorline to the ron theme
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40

" Store an undo buffer in a file in $HOME/.vimundo
set undofile
set undodir=$HOME/.vimundo
set undolevels=1000
set undoreload=10000

" Use ; as :
" Very convenient as you don't have to press shift to run commands
nnoremap ; :

" Unbind Shift+K, it's previously used for opening manual or help or something
map <S-k> <Nop>

"let g:syntastic_mode_map = { 'mode': 'passive',     
"                          \ 'active_filetypes': [],     
"                          \ 'passive_filetypes': [] } 
"let g:syntastic_auto_loc_list=1     
"
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']

nnoremap <silent> <F5> :lnext<CR>
nnoremap <silent> <F6> :lprev<CR>
nnoremap <silent> <C-Space> :ll<CR>

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_enable_cpp_checker = 0
let g:syntastic_cpp_checkers=['']

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*)}
"

let mapleader = "\<Space>"
let g:go_fmt_command = "goimports"

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)

au FileType cpp nmap <leader>f :ClangFormat<CR>
au FileType cpp nmap <leader>h :call CurtineIncSw()<CR>

autocmd! BufWritePost *.go Neomake

" ctrlpvim/ctrlp.vim extension options
" let g:ctrlp_cmd = 'CtrlP .'
let g:ctrlp_working_path_mode = 'rwa'
