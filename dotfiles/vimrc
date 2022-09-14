" TODO: https://kgrz.io/faster-vim-better-manpager.html
" TODO: https://old.reddit.com/r/vim/comments/24gqq8/is_it_a_good_idea_to_remap_the_keyboard_what/
" TODO: https://old.reddit.com/r/vim/comments/caxu3s/til_that_m_marks_horizontal_position_too/

let mapleader=" "

"colorscheme dim

" <leader>gf creates the file
noremap <leader>gf :e <cfile><cr>

" Allow navigating away from unsaved files
set hidden

" Do indent on new lines
set autoindent
filetype plugin indent on

" Case-insensitive on all-lower, any upper triggers case-sensitivity
set ignorecase
set smartcase

"" Search
" Highlight search
set hlsearch
" Incremental search
set incsearch
" Highlight without moving
nnoremap <leader>* :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>
" Clear search (long-form of :noh)
noremap <leader>/ :nohlsearch<cr>
highlight Search ctermbg=DarkYellow
highlight Search ctermfg=Black

"This doesn't work
"map gf gf:nohlsearch<cr>

" Source vimrc
noremap <leader>s :source ~/.vimrc<cr>

" Insert timestamp
nnoremap <leader>D O<ESC>"=strftime("%F %a")<CR>Po<CR><ESC>k
"nnoremap <leader>D "=strftime("%c")<CR>P

" Recommended tab settings
" https://reddit.com/r/vim/wiki/tabstop
"set tabstop=8
"set softtabstop=4
"set shiftwidth=4
"set expandtab
"Tabs over spaces
"https://old.reddit.com/r/javascript/comments/c8drjo/nobody_talks_about_the_real_reason_to_use_tabs/

" My preferred tab width (4 columns)
"set tabstop=4 shiftwidth=4

" Toggle tab width between 4 and 8
"function ToggleTabStop()
"	if &tabstop == 8
"		set tabstop=4
"	elseif &tabstop == 4
"		set tabstop=8
"	endif
"endfunction
"nnoremap <leader>T :call ToggleTabStop()<cr>

" Display whitespace (tabs and trailing, mostly)
set list

" Jump between this buffer and the previous buffer
" This is available natively as ctrl-6 or ctrl-^
function! PreviousBuffer()
	edit #
endfunction
nnoremap <leader><tab> :call PreviousBuffer()<cr>

" Highlight TODOs globally
augroup HighlightTODO
	" Remove all auto-commands from the group so they don't run twice after sourcing this again
    autocmd!

    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO:', -1)
augroup END

" Quick access to running home-manager switch on my home.nix
nnoremap <leader>H :! home-manager switch<cr>

" Quick access to browsing open buffers
nnoremap <leader>b :buffers<CR>:buffer<Space>

" Customized `gx` that understands Jira card ids.
" Based on https://vi.stackexchange.com/questions/744/can-i-pass-a-custom-string-to-the-gx-command
map gx :call Goto(expand('<cWORD>'))<CR>
fun! Goto(target)
    let l:target = a:target

    " Prepend the rest of the URL if we detect a card id
    if l:target =~? '^DMARCH\|^PRO\|^GEN'
        let l:target = 'https://watermarkinsights.atlassian.net/browse/' . l:target
    endif

    " This is what `gx` calls under the hood.
    :call netrw#BrowseX(l:target, 0)
" Test strings
" http://google.com
" DMARCH-984
" PRO-7912
endfun

" " Copy to X clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy
" " Paste from X clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

map <leader>k :call ExecuteCommandUnderCursor()<cr>
fu ExecuteCommandUnderCursor()
    " Save off the selection and clipboard registers to avoid clobbering them
    let l:save_clipboard = &clipboard
    set clipboard =
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')

    " The important bit
    normal! yi`
    let l:command = @@ " Your text object contents are here
    #execute "silent ! " . l:command # Use this if you don't want to see the output
    execute "! " . l:command
    execute 'redraw!'

    " Restore register and clipboard
    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard
endfu
" Test command `pwd`

map <leader>K :call ExecuteWholeFileAndDisplayInSplit()<cr>
fu ExecuteWholeFileAndDisplayInSplit()
	if winwidth('%')*1.0/winheight('%') > 4
		set splitright | vnew | set filetype=sh | read !sh #
	else
		set splitbelow | new | set filetype=sh | read !sh #
	endif
endfu

" Search for visually selected text with //
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Better diff colors
if &diff
    colorscheme betterdiffcolors
endif

" Built-in autocompletion
"set path=a.,,,**/*
nnoremap <Leader>e :e **/*
" Show results
set wildmenu
" Don't offer to open certain files/directories
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
set wildignore+=*.pdf,*.psd
set wildignore+=node_modules/*,.git/*

" Set the working directory to wherever the open file lives
" TODO: Consider whether I really want this. Can it be conditional, like for
" ~/notes? Disabling for now. I think I don't want it. I'll use the % trick.
" Remember it can be toggled with :set autochdir!
" :e %:h/baz.txt is another trick. % expands to the current file. :h modifies
" the expansion to just the current directory.
"set autochdir

" Quick switch buffers with C-n and C-p
nmap <C-P> :bp<CR>
nmap <C-N> :bn<CR>

" Generate GUID into default register
" Read from the external utility uuidgen, and remove the surrounding newline
" from that read.
nnoremap <Leader>G :let @" = substitute(system("uuidgen"), '[\r\n]*$','','')<cr>

" Enable mouse in all modes (for scrolling in tmux)
set mouse=r

" Format XML
com! FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"

" When vim is in readonly mode, such as when using it as a pager for pgcli,
" map 'q' to exit vim so it behaves more like other pagers. I haven't needed a
" macro in readonly mode yet, but this does shadow that keybind.
nnoremap <expr> q (&readonly == 1) ? ':q<CR>' : 'q'

" Yank rest of line
nnoremap Y y$

" Wrap/no-wrap, with nowrap by default.
" Linebreak tells vim to only wrap at a character in the 'breakat' option
" ========================================================================================================================================================================================================
set nowrap
nmap <leader>w :set wrap!<CR>:set linebreak!<CR>

" Mouse scrolling in all modes
set mouse=a

" Don't play a sound effect on errors. Boy that's annoying.
set belloff=all

