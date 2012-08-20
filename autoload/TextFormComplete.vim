" TextFormComplete.vim: Convert textual options into completion candidates.
"
" DEPENDENCIES:
"   - ingouserquery.vim autoload script
"   - SwapIt.vim plugin (optional)
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	21-Aug-2012	ENH: Also offer normal-mode q| mapping that
"				prints list or used supplied [count].
"	002	21-Aug-2012	ENH: Define completed alternatives in SwapIt, so
"				that the choice made can be corrected via
"				CTRL-A / CTRL-X.
"	001	20-Aug-2012	file creation

function! s:ErrorMsg( text )
    let v:errmsg = a:text
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None
endfunction

let s:SwapItFormCnt = 0
function! s:AddToSwapIt( matches )
    if ! exists('g:swap_lists')
	" The SwapIt plugin is not installed.
	return
    endif

    let l:options = map(copy(a:matches), 'v:val.word')

    " Avoid defining the form twice, or SwapIt will ask for the option each
    " time.
    let l:swapLists = map(copy(g:swap_lists), 'v:val.options')
    if index(l:swapLists, l:options) != -1
	" The same set of options is already defined.
	return
    endif

    " Add the new options directly to the variable, not through :SwapList; this
    " way, multi-word swaps can be used, too.
    let s:SwapItFormCnt += 1
    call add(g:swap_lists, {'name': 'form' . s:SwapItFormCnt, 'options': l:options})
endfunction

let s:unescaped = '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!'
function! s:Unescape( text )
    return substitute(a:text, s:unescaped.'\\\ze[][|(\\]', '', 'g')
endfunction
function! s:FormItemToMatch( formItem )
    let [l:item, l:explanation] = matchlist(a:formItem, '^\(.\{-}\)\%( '.s:unescaped.'(\([^)]*\))\)\?$')[1:2]
    let l:match = {'word': s:Unescape(l:item)}
    if ! empty(l:explanation)
	let l:match.menu = s:Unescape(l:explanation)
    endif
    return l:match
endfunction
let s:chars = '[][()|\\0-9A-Za-z_+-]'
function! s:Search( addendum, flags )
    " Locate the start of a text form in the format "[foo bar|quux]".
    let l:col = searchpos(s:unescaped.'\[.\{-}'.s:unescaped.']'.a:addendum, a:flags, line('.'))[1]
    if l:col == 0
	" Locate the start of a text form in the format "foo|quux".
	let l:col = searchpos('\%('.s:chars.'\+'.s:unescaped.'|\)\+'.s:chars.'\w\+'.a:addendum, a:flags, line('.'))[1]
    endif
    return l:col - 1 " Return byte index, not column.
endfunction
function! s:Matches( formText )
    let l:formText = (a:formText =~# '^\[.*]$' ? a:formText[1:-2] : a:formText)
    let l:formItems = split(l:formText, s:unescaped.'|')
    let l:matches = map(l:formItems, 's:FormItemToMatch(v:val)')
    call s:AddToSwapIt(l:matches)
    return l:matches
endfunction
function! TextFormComplete#TextFormComplete( findstart, base )
    if a:findstart
	return s:Search('\%#', 'bn')
    else
	return s:Matches(a:base)
    endif
endfunction

function! TextFormComplete#Expr()
    set completefunc=TextFormComplete#TextFormComplete
    return "\<C-x>\<C-u>"
endfunction

function! s:GetChoice( matches )
    echohl Title
    echo ' # alternative'
    echohl None
    for i in range(1, len(a:matches))
	let l:explanation = get(a:matches[i - 1], 'menu', '')
	echo printf('%2d %s', i, a:matches[i - 1].word)
	if ! empty(l:explanation)
	    echohl Directory
	    echon "\t" . l:explanation
	    echohl None
	endif
    endfor
    echo 'Type number (<Enter> cancels): '
    let l:choice = ingouserquery#GetNumber(len(a:matches))
    redraw	" Somehow need this to avoid the hit-enter prompt.
    return l:choice
endfunction
function! s:ReplaceWithMatch( startCol, endCol, match )
    let l:line = getline('.')
    call setline('.', strpart(l:line, 0, a:startCol) . a:match.word . strpart(l:line, a:endCol + 1))
endfunction
function! TextFormComplete#Choose( count )
    " Try before / at the cursor.
    let l:startCol = s:Search('', 'bc')
    if l:startCol == -1
	" Try after the cursor.
	let l:startCol = s:Search('', '')
    endif
    if l:startCol == -1
	call s:ErrorMsg('No text form under cursor')
	return
    endif

    let l:endCol = s:Search('', 'cen')
    let l:formText = strpart(getline('.'), l:startCol, l:endCol - l:startCol + 1)
    let l:matches = s:Matches(l:formText)
    if empty(l:matches)
	call s:ErrorMsg('No text form alternatives')
	return
    endif

    let l:count = (a:count ? a:count : s:GetChoice(l:matches))

    if l:count == -1
	return
    elseif l:count > len(l:matches)
	call s:ErrorMsg(printf('Only %d alternatives', len(l:matches)))
	return
    endif

    call s:ReplaceWithMatch(l:startCol, l:endCol, l:matches[l:count - 1])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
