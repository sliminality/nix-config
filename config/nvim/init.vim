""" Formatting

set wrap            " Wrap lines
set nojoinspaces    " No double spaces after punctuation on join
set autoindent      " Auto indent
set expandtab       " Use spaces instead of tabs
set smarttab        " Be smart when using tabs
set shiftwidth=4    " 1 tab == 4 spaces
set softtabstop=4
set tabstop=4

filetype plugin indent on   " Auto detect filetypes

""" UI

color rainbow-contrast

set number          " Enable line numbers
set termguicolors   " Nice colors
syntax enable       " Enable syntax highlighting
set lazyredraw      " Make rendering performance better
set nospell         " Disable spellcheck
set incsearch       " Find as you type search
set hlsearch        " Highlight found search results
set ignorecase      " Case insensitive search
set smartcase       " Case sensitive when uc present
set wildmenu        " Show list instead of just completing

set mouse=a         " Automatically enable mouse usage
set mousehide       " Hide the mouse cursor while typing

" Stop automatically inserting new comment leaders.
augroup commentgroup
  autocmd!
  autocmd FileType * set fo-=r fo-=c fo-=o
augroup END

set splitbelow        " Open new splits to the right and below
set splitright
set fillchars+=vert:\ " Remove | char from vertical splits

" Make matched parens visually distinct from cursor
highlight MatchParen gui=underline guifg=NONE guibg=NONE  

""" Editing

set autoread                     " Autoread when a file is changed externally
set backspace=indent,eol,start   " Backspace for dummies
set scrolljump=5                 " Lines to scroll when cursor leaves screen
set scrolloff=10                 " Minimum lines to keep above and below cursor

set iskeyword-=.                 " '.' delimits words
set iskeyword-=#                 " '#' delimits words
set iskeyword-=-                 " '-' delimits words

" Command <Tab> completion, list matches, then longest common part, then all.
set wildmode=list:longest,full

" Enable persistent undo across buffers and sessions
try
  set undodir=~/.vim_runtime/temp_dirs/undodir
  set undofile
  set undolevels=1000
  set undoreload=10000
catch
endtry

" Return to last edit position when opening files
augroup SaveEditPosition
  autocmd!
  autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
augroup END

""" Mapping

let mapleader=" "                  " Leader key to space
set timeoutlen=500 ttimeoutlen=0   " Less key delay lag

" Navigate wrapped lines
noremap j gj
noremap k gk

" Move lines around easily
nnoremap <leader>k :m-2<cr>==
nnoremap <leader>j :m+<cr>==
xnoremap <leader>k :m-2<cr>gv=gv
xnoremap <leader>j :m'>+<cr>gv=gv

" Find merge conflict markers
noremap <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

" Shift without exiting Visual mode
vnoremap < <gv
vnoremap > >gv
" Repeat visual selections http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>
" Re-select and re-yank text pasted in visual mode.  https://stackoverflow.com/a/5093286
xnoremap p "_dP

" Open new empty buffer
nmap <leader>T :enew<CR>
" Next buffer
nmap <leader>l :bnext<CR>
" Previous buffer
nmap <leader>h :bprevious<CR>
" Close buffer
nmap <leader>w :bp <BAR> bd #<CR>
" Really close buffer
nmap <leader>W :bdelete!<CR>

" Copy to system clipboard
vnoremap <C-c> "*y

" Pull path into system clipboard
command! Path let @* = expand("%")

" List syntax highlight groups under cursor
nnoremap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
if !exists("*synstack")
  return
endif
echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Feed tsserver and related processes
let $NODE_OPTIONS = "--max-old-space-size=8192"
