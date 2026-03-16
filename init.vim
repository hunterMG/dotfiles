inoremap jj <ESC>
inoremap jk <ESC>
inoremap fd <ESC>

" enable python3
let g:python3_host_prog = '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/bin/python3'

" highlight col 88
set textwidth=88
set colorcolumn=+1

set nocompatible
set t_Co=256
set termguicolors
"colorscheme macvim256
"colorscheme morning
" colorscheme solarized8
" Use the Solarized Dark theme
set background=dark
"set background=light
"let g:solarized_termtrans=1

let g:minBufExplForceSyntaxEnable = 1

set laststatus=2
set guifont=Source\ Code\ Pro\ for\ Powerline:h16
set noshowmode

" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
" set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif

" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Make tabs as wide as 4 spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
" set smartindent
filetype plugin indent on
syntax enable
" use space replace tab in input
set expandtab
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" don't ignore case if search content has upper case
set smartcase
" highlight 80th line
" set colorcolumn=80
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
if exists("&relativenumber")
    set relativenumber
    au BufReadPost * set relativenumber
endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace (,ss)
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
    " Enable file type detection
    filetype on
    " Treat .json files as .js (Deprecated, neovim doesn't need it)
    " autocmd BufNewFile,BufRead *.json setfiletype json | set syntax=javascript
    " Treat .md files as Markdown
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
    " AppleScript commentstring for vim-commentary
    autocmd FileType applescript setlocal commentstring=--\ %s
endif

autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$")
    \ |   exe "normal! g`\""
    \ | endif

" ------------ EasyMotion config begin ------------
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" [IdeaVim doean't support `overwin` motions]
" `s{char}{label}`
" nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
" nmap s <Plug>(easymotion-overwin-f2)
nmap s <Plug>(easymotion-s2)
nmap t <Plug>(easymotion-t2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
" ------------ EasyMotion config end   ------------

" Plug
call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'jiangmiao/auto-pairs'
Plug 'preservim/nerdcommenter' " leader ,
Plug 'preservim/nerdtree'
Plug 'machakann/vim-highlightedyank'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'  " leader g
Plug 'easymotion/vim-easymotion'
Plug 'olimorris/onedarkpro.nvim'
Plug 'lifepillar/vim-solarized8', { 'branch': 'neovim' }
call plug#end()

colorscheme solarized8
" ========== Lua Config ==========
" 加载 Lua 模块 (相当于 require("plugins.onedarkpro"))
" lua require("plugins.onedarkpro")
