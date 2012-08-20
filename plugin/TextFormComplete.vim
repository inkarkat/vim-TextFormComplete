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
"	001	20-Aug-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_TextFormComplete') || (v:version < 700)
    finish
endif
let g:loaded_TextFormComplete = 1

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
