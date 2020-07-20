call plug#begin()
" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" NVim LSP configs
Plug 'neovim/nvim-lsp'
" Diagnostics
Plug 'haorenW1025/diagnostic-nvim'
" Completion
Plug 'haorenW1025/completion-nvim'

" Auto parenthesis/bracket pairing
"Plug 'jiangmiao/auto-pairs'

" Viewer & Finder for LSP symbols and tags
Plug 'liuchengxu/vista.vim'

" Reason/OCaml additions
Plug 'reasonml-editor/vim-reason-plus'

" Git integration
Plug 'tpope/vim-fugitive'
" Git changes column
Plug 'airblade/vim-gitgutter'

" Main status line bar
Plug 'itchyny/lightline.vim'

" Syntax
Plug 'sheerun/vim-polyglot'
" May be redundant due to polyglot
Plug 'justinmk/vim-syntax-extra'

" Themes
Plug 'gruvbox-community/gruvbox'

call plug#end()
"------------------------------------------------------------


"-Aesthetics-------------------------------------------------
syntax enable
set t_Co=256
set termguicolors
highlight CursorLine cterm = NONE

" Set theme options
color gruvbox
let g:gruvbox_italic=1
let g:gruvbox_invert_selection=0
let g:gruvbox_contrast_light='hard'
let g:gruvbox_contrast_dark='soft'

" Set terminal title to file name
set title
set titlestring=%t%(\ %M%)
"------------------------------------------------------------


"-Vim-only overrides-----------------------------------------
if !has("nvim")
	filetype plugin indent on
	"syntax enable
	set laststatus=2
	set smarttab
	set ttyfast
endif
"------------------------------------------------------------


"-ETC--------------------------------------------------------
" Show relative line numbers
set nu rnu

" Indents
set autoindent
set smartindent

" Enable mouse support
set mouse=a

" Allows undo-ing changes across sessions (creates an undo file)
set undofile

" Highlights line the cursor is currently on
set cursorline

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Disables showing current-match-count for completion functions
set shortmess+=c

" Disables showing current mode in status-line
set noshowmode

" Allows leaving a buffer without saving it 
set hidden

" Set ghost-characters to show tabs and trailing whitespace
set list listchars=tab:\|\ ,trail:~

set sessionoptions=blank,buffers,curdir,folds,help,options,tabpages,winsize
"------------------------------------------------------------


"-Plugin-ETC-------------------------------------------------
" Try to deprioritize git signs
let g:gitgutter_sign_allow_clobber = 0

" Disable diagnostic virtual text
let g:diagnostic_enable_virtual_text = 0

" Delay diagnostics during insert
let g:diagnostic_insert_delay = 1
"------------------------------------------------------------


"-Remaps-----------------------------------------------------
" Use enter to enter command mode
nnoremap <expr> <CR> &buftype ==# 'quickfix' ? "\<CR>" : ':'

" Allows typing 'jk' in insert mode to exit
inoremap jk <Esc>

" Opens the Tagbar
nmap <F8> :Vista!!<CR>

" For navigating the location list
map <C-j> :lnext<CR>
map <C-k> :lprev<CR>

" Mappings for buffer manipulation
nmap <C-b><C-l> :ls<CR>
nmap <C-b><C-d> :bd<CR>
nmap <C-b><C-n> :bn<CR>
nmap <C-b><C-p> :bp<CR>

" Mappings for quickfix window
map <C-c><C-o> :copen<CR>
" TODO: Either use a plugin, or find a way to get the window to toggle
map <C-c><C-x> :cclose<CR>
map <C-c><C-n> :cnext<CR>
map <C-c><C-p> :cprev<CR>
"------------------------------------------------------------

"-nvim-lsp----------------------------------------------------
lua << EOF
local on_attach_vim = function()
  require'completion'.on_attach()
    require'diagnostic'.on_attach()
    end
    require'nvim_lsp'.pyls.setup{on_attach=on_attach_vim}
    require'nvim_lsp'.clangd.setup{on_attach=on_attach_vim}
    require'nvim_lsp'.ocamllsp.setup{on_attach=on_attach_vim}
EOF

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-[> <cmd>lua vim.lsp.util.show_line_diagnostics()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gR    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <c-a> <cmd>lua vim.lsp.buf.code_action()<CR>
"------------------------------------------------------------


"-vista------------------------------------------------------
" Set to use lsp
let g:vista_default_executive = 'nvim_lsp'

function! NearestMethodOrFunction() abort
	  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

" Show nearest function automatically
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
"------------------------------------------------------------

"-lightline--------------------------------------------------
let g:lightline = {
			\ 'colorscheme': 'gruvbox',
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'fugitive', 'readonly', 'filename'],
			\             [ 'method' ]]
			\ },
			\ 'component_function': {
			\   'filename': 'LightlineFilename',
			\   'readonly': 'LightlineReadonly',
			\   'fugitive': 'LightlineFugitive',
			\   'method': 'NearestMethodOrFunction'
			\ },
			\ 'separator': { 'left': '', 'right': '' },
			\ 'subseparator': { 'left': '', 'right': '' }
			\ }
function! LightlineReadonly()
	return &readonly ? '' : ''
endfunction
function! LightlineFugitive()
	if exists('*fugitive#head')
		let branch = fugitive#head()
		return branch !=# '' ? ''.branch : ''
	endif
	return ''
endfunction
function! LightlineFilename()
	let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
	let modified = &modified ? ' +' : ''
	return filename . modified
endfunction

autocmd OptionSet background
      \ execute 'source' globpath(&rtp, 'autoload/lightline/colorscheme/gruvbox.vim')
      \ | call lightline#colorscheme() | call lightline#update()
"------------------------------------------------------------
