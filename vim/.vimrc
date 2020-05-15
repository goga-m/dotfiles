" url: HTTP://VIM.WIKIA.COM/WIKI/eXAMPLE_VIMRC
" Authors: http://vim.wikia.com/wiki/Vim_on_Freenode
" B
" Description: A minimal, but feature rich, example .vimrc. If you are a
"              newbie, basing your first .vimrc on this file is a good choice.
"              If you're a more advanced user, building your own .vimrc based
"              on this file is still a good idea.

"------------------------------------------------------------
" Features {{{1
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on





"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline

" Maintain scroll offset from top & bottom when scrolling.
" Cursor will alway between +10 lines from top and -10 lines from bottom.
set so=10



"------------------------------------------------------------
" Plugins {{{1
"
" vim-plug as the main plugin manager configuration.
"
" Main feature: unlike Vundle, allows branch selection, required for plugins
"               like coc.
"
" Automatically install vim-plug if not detected in ~/.vim/autoload
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')


" Gruvbox colorscheme
Plug 'morhetz/gruvbox'

" tcomment provides easy to use, file-type sensible comments for Vim. It 
" can handle embedded syntax.
Plug 'tomtom/tcomment_vim'

" Coc is an intellisense engine for Vim/Neovim.
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" User the full paths of the sources.
" Works with symlinks
let path = expand('<sfile>:p:h')
exec 'source' path . '/plugins/coc.vim'
exec 'source' path . '/plugins/coc-snippets.vim'

" coc-explorer Use preset argument to open it
set completeopt+=preview
nmap <space>ed :CocCommand explorer --preset .vim<CR>
nmap <space>ef :CocCommand explorer --preset floating<CR>

" List all presets
nmap <space>el :CocList explPresets

" The Silver Searcher
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'



" Plugin to autoclose quotes,parens,brackets etc.
" Works well with close tag to prevent closing < tag and let
" closetag hand autoclosing of tags.
Plug 'jiangmiao/auto-pairs'

" This plugin is meant to simplify a task I've 
" found too common in my workflow: switching between a 
" single-line statement and a multi-line one. It offers 
" the following default keybindings, which can be customized:
"  * gS to split a one-liner into multiple lines
"  * gJ to join a block into a single-line statement.
Plug 'andrewradev/splitjoin.vim'

" Close html tag
Plug 'alvan/vim-closetag'
" filenames like *.xml, *.html, *.xhtml, ...
let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.vue, *.blade.php"

" A Vim plugin for Livedown.
" Preview live while editing markdown files.
Plug 'shime/vim-livedown'

" With Wildfire you can quickly select the 
" closest text object among a group of candidates. 
" By default candidates are i', i", i), i], i}, ip and it.
Plug 'gcmt/wildfire.vim'


" Light tabline for vim.
Plug 'vim-airline/vim-airline'
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='dark'

" Vim syntax highlighting for Vue components.
" Works best for vue inline component.
" Allows to highlight js code in <script> and css in <style>
Plug 'posva/vim-vue'

call plug#end()


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Set leader key
let mapleader = ','

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" disable creating .swp files.
set noswapfile

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Copy the structure of the existing lines indent when autoindenting a
" new line.
set copyindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" press <Enter> to continue
set cmdheight=2

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

" Use system's clipboard. Gives access to yank/paste between vim and os.
set clipboard=unnamedplus

" Auto read file changes.
set autoread

" Persistent undo.

" This allows you to use undos after exiting and restarting Vim.
" This, like swap and backup files, uses .vim-undo first, then ~/.vim/undo
" :help undo-persistence.
" This is only present in 7.3+
set backupdir=~/.vimtmp
if exists("+undofile")
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif

" Binary files. 
"
" Some options like (textwidth, wrapmargin, modeline, expandtab)
" Also 'fileromat' and 'fileformats' options will not be used
" will be changed when editing 
set binary
" Do not write <EOL> on binary files.
set noeol

" When selecting with '*', prevent jumping to the next
nnoremap * *<c-o>

" Move quickly between panes. Just hit control and use
" vim's navigation hjkl.
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l



"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=2
set softtabstop=2
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
"set shiftwidth=4
"set tabstop=4


"------------------------------------------------------------
" Custom commands {{{1
"

" Profiling.
" Vim can measure the time spent on executing functions or scripts.
" These commands start stop and preview the results of a profiler.
command! ProfileMe :profile start ~/.vim/profile.log <bar> profile func * <bar> profile file *
command! ProfileStop :profile pause
command! ProfileView :e ~/.vim/profile.log


"------------------------------------------------------------
" UI Config {{{1
"
" Options to modify visuals in Vim.

" Apply colors on all terminals
set t_Co=256
set background=dark
colorscheme gruvbox

" Display line numbers on the left.
set number

" User relative numbering. The line numbers on the left are relative to the
" cursorline. The cursor shows the actual line.
set relativenumber

" While typing a search command, highlight the matched patterns,
set incsearch

" Disable Swap files.
set nobackup
set nowritebackup

" Set the character encoding used inside Vim.
set encoding=utf-8

" Faster redrawing on terminal.
set ttyfast

" 
" Faster redrawing on terminal.

" When this option is set, the screen will not be redrawn while
" executing macros, registers and other commands that have not been
" typed.  Also, updating the window title is postponed.  To force an
" update use |:redraw|.
set lazyredraw

" Prevent line wrapping.
set nowrap

" Highlight the text line of the cursor.
set cursorline

hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#000050 ctermbg=234

" Highlight the current column of the cursor.
" set cursorcolumn
" hi cursorcolumn cterm=none term=none
" autocmd WinEnter * setlocal cursorcolumn
" autocmd WinLeave * setlocal nocursorline
" highlight cursorcolumn guibg=#000050 ctermbg=234

"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
" nnoremap <C-L> :nohl<CR><C-L>

" Map exiting insert mode with jj
inoremap jj  <esc>

" Correcting bad indent while pasting with zp :-)
nnoremap zp p=`] 

" Resize panes using alt + hjkl.
nnoremap <silent> <A-h> <C-w><
nnoremap <silent> <A-j> <C-W>-
nnoremap <silent> <A-k> <C-W>+
nnoremap <silent> <A-l> <C-w>>

" Indent the entire file and return to the current position.
noremap <silent> <F5> m8gg=G`8