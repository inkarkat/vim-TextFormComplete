" TextFormComplete.vim: Convert textual options into completion candidates.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	21-Aug-2012	ENH: Add normal-mode q| mapping.
"	001	20-Aug-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_TextFormComplete') || (v:version < 700)
    finish
endif
let g:loaded_TextFormComplete = 1

inoremap <silent> <expr> <Plug>(TextFormComplete) TextFormComplete#Expr()
if ! hasmapto('<Plug>(TextFormComplete)', 'i')
    imap <C-x><Bar> <Plug>(TextFormComplete)
endif

nnoremap <silent> <Plug>(TextFormComplete) :<C-u>call setline('.', getline('.'))<Bar>call TextFormComplete#Choose(v:count)<CR>
if ! hasmapto('<Plug>(TextFormComplete)', 'n')
    nmap q<Bar> <Plug>(TextFormComplete)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
