" 기본 설정
set nu
set history=1000
set ttyfast
set ttymouse=xterm2
set mouse=a
set hlsearch
set ignorecase
set smartindent
set tabstop=2
set expandtab
set shiftwidth=2

syntax on
set t_Co=256
colorscheme jellybeans
hi Visual term=reverse cterm=reverse guibg=Grey

" VundleVim 설정
set nocompatible
filetype off
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'rhysd/vim-clang-format'
Plugin 'The-NERD-tree'
Plugin 'AutoComplPop'
Plugin 'taglist-plus'

call vundle#end()
filetype plugin indent on

" clang-format 설정
nnoremap <C-S-i> :ClangFormat<CR>
let g:clang_format#code_style = 'google'
"autocmd FileType c,cpp,objc ClangFormatAutoEnable

" NERD Tree를 왼쪽에 생성
let NERDTreeWinPos = "left"

" NERD Tree는 F7키. Tag List는 F8키에 매칭.
nmap <F7> :NERDTreeToggle<CR>
nmap <F8> :TlistToggle<CR>

filetype on

" Tag list가 사용하는 ctags의 경로 설정
let Tlist_Inc_Winwidth = 0
let Tlist_Exit_OnlyWindow = 0
let Tlist_Auto_Open = 0

" Tag list 창을 오른쪽으로 생성
let Tlist_Use_Right_Window = 1

set csprg=/usr/bin/cscope                     
set csto=0                                     
set cst                                       
set nocsverb                                   
cs add ~/master/src/toc/cscope.out ~/cscope.out
set csverb                                     

set tags=./tags,tags                           
set tags+=~/master/src/tags               
set tags+=~/master/src/toc/tags               
set tags+=~/master/src/lib/tuk/wincomp/tags              
set tags+=~/master/src/lib/tags              
set tags+=~/msvcrt/tags              
set tags+=~/master/src/lib/print/tags              
set tags+=~/cups/cups/tags
set tags+=~/bluez-5.50/tags
set tags+=~/dbus-1.12.12/tags
