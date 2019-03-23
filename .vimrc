" General

set number
set showbreak=+++
set textwidth=200
set showmatch
set visualbell
 
set hlsearch
set smartcase
set ignorecase
set incsearch
 
set autoindent
set expandtab
set smarttab

" Disable Swap files
set nobackup
set nowritebackup

" Automatically change the directory when opening file
" set autochdir

set backupdir=~/.vimtmp
if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backup files, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif
set noswapfile

" Prevent line wrapping
set nowrap

" Thinner cursor

" Advanced
set ruler
 
set undolevels=2000
set backspace=indent,eol,start

set cursorline
autocmd InsertEnter * highlight CursorLine guibg=#000050 guifg=fg
autocmd InsertLeave * highlight CursorLine guibg=#004000 guifg=fg

set shellslash
set noswapfile
set relativenumber
set nocompatible              " be iMproved, required

inoremap jj  <esc>

" Code folding

" set foldmethod=syntax
" set foldlevelstart=1

" let javaScript_fold=1         " JavaScript
" let perl_fold=1               " Perl
" let php_folding=1             " PHP
" let r_syntax_folding=1        " R
" let ruby_fold=1               " Ruby
" let sh_fold_enabled=1         " sh
" " let vimsyn_folding='af'       " Vim script
" let xml_syntax_folding=1      " XML

" inoremap <F9> <C-O>za
" nnoremap <F9> za
" onoremap <F9> <C-C>za
" vnoremap <F9> zf

" Window navigation napping 
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l


" When hitting n/N after search, keep the 
" cursor in the middle of the screen (vertically)

nnoremap n nzzzv
nnoremap N Nzzzv

"Don't move on *
nnoremap * *<c-o>

filetype on                  " required
syntax on

" Vundle & Plugins configuration
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()


" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Nerdtree
Plugin 'scrooloose/nerdtree'

" Synctonize nerdTree with opened file
Plugin 'unkiwii/vim-nerdtree-sync'
let g:nerdtree_sync_cursorline = 1

" Commentary
" Plugin 'tpope/vim-commentary'
" Tcomment plugin (supports embedded syntax)
Plugin 'tomtom/tcomment_vim.git'
" Autogenerate comments
" Plugin 'joegesualdo/jsdoc.vim'
" nnoremap jsd :<C-u>call JSDocAdd()<CR>
Plugin 'heavenshell/vim-jsdoc'
let g:jsdoc_allow_input_prompt = 1
let g:jsdoc_enable_es6 = 1
let g:jsdoc_input_description = 1
let g:jsdoc_additional_descriptions = 1

" Surround
Plugin 'tpope/vim-surround.git'

" All of your Plugins must be added before the following line
call vundle#end()            " required

"js beautify (html,css,js beatufier)
" Plugin 'maksimr/vim-jsbeautify'

" Vim repeat
Plugin 'tpope/vim-repeat'

" Tern
" Plugin 'ternjs/tern_for_vim'

" YouCompleteMe
Plugin 'Valloric/YouCompleteMe'

" Delimimate - autocompletion with brackets etc
" Plugin 'Raimondi/delimitMate'

" Track the engine.
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
" Plugin 'honza/vim-snippets'
" es6 Snippets
Plugin 'isRuslan/vim-es6'

" Full path fuzzy file, buffer, mru, tag, ... finder for Vim.
" Plugin 'ctrlpvim/ctrlp.vim'

" Search inside files
Plugin 'mileszs/ack.vim'

" Js syntax highlighting and improved indetation
Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'

" Gruvbox colorscheme
Plugin 'morhetz/gruvbox'

" Tmux & vim pane-navigation shortcuts
Plugin  'christoomey/vim-tmux-navigator'

" Airline plugin 
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 0
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'

" Git Plugin for sublime
Plugin 'tpope/vim-fugitive'
" Git Plugin to work well with nerdtree
" Plugin 'Xuyuanp/nerdtree-git-plugin'
" Plugin 'gregsexton/gitv'

" Plugin to navigate through node modules
Plugin 'moll/vim-node'

" Editorconfig support for vim
Plugin 'editorconfig/editorconfig-vim'

" Plugin to autoclose quotes,parens,brackets etc.
" Works well with close tag to prevent closing < tag and let
" closetag hand autoclosing of tags
Plugin 'jiangmiao/auto-pairs'

" Js hint plugin
" Plugin 'wookiehangover/jshint.vim'

" Vim-Solidity
Plugin 'tomlion/vim-solidity'
autocmd BufNewFile,BufRead *.sol   set syntax=solidity

" Close html tag
Plugin 'alvan/vim-closetag'
" filenames like *.xml, *.html, *.xhtml, ...
let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.vue"

" Syntax highlighting for vim
Plugin 'posva/vim-vue'
Plugin 'othree/html5.vim'
autocmd BufNewFile,BufRead *.vue set filetype=html
autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript.css
" autocmd BufWritePre *.vue :/<script>/+1,/<\/script>/-1 !standard --fix --stdin

" autocmd BufWritePre *.vue silent! :/<script>/+1,/<\/script>/-1 !standard --fix --stdin
" autocmd BufWritePre *.vue silent! :/<template>/+1,/<\/template>/-1 !html-beautify --stdin
" autocmd BufWritePre *.vue silent! :/<style lang="scss">/+1,/<\/style>/-1 !sass-convert --from scss --to scss --stdin
" autocmd FileType vue syntax sync fromstart
"
"
" Fix syntax highlighting if broken on files with multiple languages
autocmd BufEnter * :syntax sync fromstart
let g:vue_disable_pre_processors=1

" Ale
Plugin 'w0rp/ale'
let g:ale_fixers = {
\   'javascript': ['standard', 'eslint'],
\}
let g:ale_fix_on_save = 1
" autocmd bufwritepost *.js silent !standard --fix %
set autoread

" Polyglot
" A collection of language packs for Vim.
" Plugin 'vim-polyglot'

" Synastic
" Plugin 'vim-syntastic/syntastic'
" let g:syntastic_error_symbol = "✗"
" let g:syntastic_warning_symbol = "-"
" Vim autoformat
" Plugin 'Chiel92/vim-autoformat'
" let g:autoformat_verbosemode=1
" let g:formatdef_eslint_local='"eslint'
" Vim xo - javascript style linter
" Plugin 'sindresorhus/vim-xo'
" let g:syntastic_javascript_checkers = ['xo']
" let g:syntastic_javascript_checkers = ['standard', 'eslint']
" let g:syntastic_javascript_standard_exec = "/usr/local/bin/standard"
" let g:syntastic_javascript_eslint_exec = "/usr/local/bin/eslint"
" autocmd bufwritepost *.js silent !standard % --format > /dev/null
" set autoread
" Elm plugin for vim
Plugin 'ElmCast/elm-vim'
autocmd BufNewFile,BufRead *.elm set filetype=elm

" Plugin 'elmcast/elm-vim'
" Elm you complete me intergration
" let g:ycm_semantic_triggers = {
"      \ 'elm' : ['.'],
"      \}

" Startify plugin for vim, to keep sessions and a starter screen
" Plugin 'mhinz/vim-startify'

" Denite is a dark powered plugin for Neovim/Vim to unite all interfaces. 
" It can replace many features or plugins with its interface. 
" It is like a fuzzy finder, but is more generic. 
" You can extend the interface and create the sources.
" Plugin 'Shougo/denite.nvim'

" Powerline is a statusline plugin for vim, 
" and provides statuslines and prompts for several other applications, 
" including zsh, bash, fish, tmux, IPython, Awesome, i3 and Qtile.
Plugin 'powerline/powerline' 

" QFEnter allows you to open items from Vim's quickfix or location list wherever you wish.
Plugin 'yssl/QFEnter'
let g:qfenter_keymap = {}
let g:qfenter_keymap.vopen = ['<C-v>']
let g:qfenter_keymap.hopen = ['<C-CR>', '<C-i>']
let g:qfenter_keymap.topen = ['<C-t>']

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-g>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

set autoindent
filetype plugin indent on    " required

" commenting json as javascript
" see  @http://www.codeography.com/2010/07/13/json-syntax-highlighting-in-vim.html
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd BufNewFile,BufRead *.mjs set ft=javascript

Plugin 'cohama/agit.vim'

Plugin 'junegunn/gv.vim'


" A vim plugin that simplifies the transition between multiline and single-line code. 
" Objects etc
Plugin 'andrewradev/splitjoin.vim'


" Yankstack.vim is a lightweight implementation of the Emacs 'kill ring' for Vim. 
" It allows you to yank and delete things without worrying about 
" losing the text that you yanked previously. 
" It effectively turns your default register into a stack, and lets you 
" cycle through the items in the stack after doing a paste.
Plugin 'maxbrunsfeld/vim-yankstack'

" beautify
" autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" autocmd FileType json noremap <buffer> <c-f> :call JsonBeautify()<cr>
" autocmd FileType jsx noremap <buffer> <c-f> :call JsxBeautify()<cr>
" autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
" autocmd FileType vue noremap <buffer> <c-f> :call HtmlBeautify()<cr>
"
"
"
" autocmd FileType javascript vnoremap <buffer>  <c-f> :call RangeJsBeautify()<cr>
" autocmd FileType json vnoremap <buffer> <c-f> :call RangeJsonBeautify()<cr>
" autocmd FileType jsx vnoremap <buffer> <c-f> :call RangeJsxBeautify()<cr>
" autocmd FileType html vnoremap <buffer> <c-f> :call RangeHtmlBeautify()<cr>
" autocmd FileType css vnoremap <buffer> <c-f> :call RangeCSSBeautify()<cr>
" autocmd FileType vue vnoremap <buffer> <c-f> :call RangeHtmlBeautify()<cr>
" prevent youcompleteme errors
let g:ycm_path_to_python_interpreter="/usr/bin/python2.7"

" nicely break lines while {} is inserter
"BreakLine: Return TRUE if in the middle of {} or () in INSERT mode
fun BreakLine()
  if (mode() == 'i')
    return ((getline(".")[col(".")-2] == '{' && getline(".")[col(".")-1] == '}') ||
          \(getline(".")[col(".")-2] == '(' && getline(".")[col(".")-1] == ')'))
  else
    return 0
  endif
endfun

" Remap <Enter> to split the line and insert a new line in between if
" BreakLine return True
inoremap <expr> <CR> BreakLine() ? "<CR><ESC>O" : "<CR>"

" Css omnicomplete autocompletion while writing
let g:ycm_semantic_triggers = {
    \   'css': [ 're!^\s{4}', 're!:\s+' ],
    \ }
"Set html autocomplete on
set omnifunc=htmlcomplete#CompleteTags

" show existing tab with 4 spaces width


set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=2    " Indents will have a width of 4
set softtabstop=2   " Sets the number of columns for a TAB

set binary
set noeol
set expandtab       " Expand TABs to spaces

"Tmux custom mappings
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
" nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

"
" Resize
nnoremap <silent> <A-h> <C-w><
nnoremap <silent> <A-j> <C-W>-
nnoremap <silent> <A-k> <C-W>+
nnoremap <silent> <A-l> <C-w>>



" Airline theme selection
" let g:airline_theme='simple'
set t_Co=256
set background=dark
colorscheme gruvbox

" Use system's clipboard
set clipboard=unnamedplus



" Map search keys (with Ack)
nnoremap <C-g> :Ack! 
nnoremap <C-f> :AckFile! 


" Status line
" function! GitBranch()
"   return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
" endfunction
"
" function! StatuslineGit()
"   let l:branchname = GitBranch()
"   return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
" endfunction
"
" set statusline=
" set statusline+=%#PmenuSel#
" set statusline+=%{StatuslineGit()}
" set statusline+=%#LineNr#
" set statusline+=\ %f
" set statusline+=%m\
" set statusline+=%=
" set statusline+=%#CursorColumn#
" set statusline+=\ %y
" set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
" set statusline+=\[%{&fileformat}\]
" set statusline+=\ %p%%
" set statusline+=\ %l:%c
" set statusline+=\ 

" On enter click, select the highlighted item on autocompletion dropdown
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"


" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line