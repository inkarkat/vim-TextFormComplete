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
"	004	22-Aug-2012	I18N: Allow for non-ASCII characters in the
"				non-bracketed text form. Modify the s:chars
"				regexps to include non-ASCII characters. Because
"				we only have the endCol of the text form (and
"				cannot easily match beyond that; the line may
"				end there), we cannot simply use strpart(), but
"				have to use matchstr() with /\%c/ to correctly
"				deal with a final non-ASCII character.
"	003	21-Aug-2012	ENH: Also offer normal-mode q| mapping that
"				prints list or used supplied [count].
"				FIX: With the use of the \%# addendum, the
"				backwards match spans multiple text forms
"				(despite \{-}!). Do away with the \%# anchor and
"				instead check for the end match at the cursor
"				position first, then do the search for the
"				beginning of the text form.
"				FIX: Handle corner cases when there's only a [ /
"				] at the beginning / end; this should then not
"				be included in the first / last alternative.
"				Have s:Search() return the text form type (0/1),
"				and pass that in to the second search for the
"				other side, to avoid matches with the other
"				pattern.
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
let s:chars = '\%([][()|\\0-9A-Za-z_+-]\|[^\x00-\x7F]\)'
"              01234567
let s:startChars = s:chars[0:4].s:chars[6:].s:chars.'*'
let s:endChars = s:chars.'*'.s:chars[0:3].s:chars[5:]
function! s:Search( flags, ... )
    let l:type = 0

    if ! a:0 || a:1 == 0
	" Locate the start of a text form in the format "[foo bar|quux]".
	let l:col = searchpos(s:unescaped.'\[.\{-}'.s:unescaped.']', a:flags, line('.'))[1]
    endif
    if a:0 && a:1 == 1 || ! a:0 && l:col == 0
	let l:type = 1

	" Locate the start of a text form in the format "foo|quux".
	let l:col = searchpos(s:startChars.'\%('.s:unescaped.'|'.s:chars.'\+'.'\)*'.s:unescaped.'|'.s:endChars, a:flags, line('.'))[1]
    endif
    return [l:type, l:col - 1] " Return byte index, not column.
endfunction
function! s:Matches( formText )
    let l:formText = (a:formText =~# '^\[.*]$' ? a:formText[1:-2] : a:formText) " Since [ and ] are in the ASCII range and always represented by a single byte, we can use simple array slicing to remove them.
    let l:formItems = split(l:formText, s:unescaped.'|')
    let l:matches = map(l:formItems, 's:FormItemToMatch(v:val)')
    call s:AddToSwapIt(l:matches)
    return l:matches
endfunction
function! TextFormComplete#TextFormComplete( findstart, base )
    if a:findstart
	let [l:type, l:col] = s:Search('ben')
	let l:isCursorAtEndOfFormText = (l:col + 2 == col('.'))
	return (l:isCursorAtEndOfFormText ? s:Search('bn', l:type)[1] : -1)
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
    call setline('.', strpart(l:line, 0, a:startCol) . a:match.word . matchstr(l:line, '\%>'.(a:endCol + 1).'c.*$'))    " Columns in /\%c/ are 1-based.
endfunction
function! TextFormComplete#Choose( count )
    " Try before / at the cursor.
    let [l:type, l:startCol] = s:Search('bc')
    if l:startCol == -1
	" Try after the cursor.
	let [l:type, l:startCol] = s:Search('')
    endif
    if l:startCol == -1
	call s:ErrorMsg('No text form under cursor')
	return
    endif

    let l:endCol = s:Search('cen', l:type)[1]
    let l:formText = matchstr(getline('.'), '\%'.(l:startCol + 1).'c.*\%'.(l:endCol + 1).'c.')  " Columns in /\%c/ are 1-based.
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
