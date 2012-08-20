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

let s:unescaped = '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!'
function! s:Unescape( text )
    return substitute(a:text, s:unescaped.'\\\ze[][|\\]', '', 'g')
endfunction
let s:chars = '[][()|\\0-9A-Za-z_-]'
function! TextFormComplete#TextFormComplete( findstart, base )
    if a:findstart
	" Locate the start of a text form in the format "[foo bar|quux]".
	let l:startCol = searchpos(s:unescaped.'\[.\{-}'.s:unescaped.']\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    " Locate the start of a text form in the format "foo|quux".
	    let l:startCol = searchpos('\%('.s:chars.'\+'.s:unescaped.'|\)\+'.s:chars.'\w\+\%#', 'bn', line('.'))[1]
	endif

	return l:startCol - 1 " Return byte index, not column.
    else
	let l:formText = (a:base =~# '^\[.*]$' ? a:base[1:-2] : a:base)
	let l:formItems = map(split(l:formText, s:unescaped.'|'), "s:Unescape(v:val)")
	let l:matches = map(l:formItems, '{"word": v:val}')
	return l:matches
    endif
endfunction

function! TextFormComplete#Expr()
    set completefunc=TextFormComplete#TextFormComplete
    return "\<C-x>\<C-u>"
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
