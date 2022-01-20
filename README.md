TEXT FORM COMPLETE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin can transform textual options (in the form FOO|BAR, as they are
often found in templates or snippets) into a printed list or insert-mode
completion, which offer all alternatives ("FOO" and "BAR" in this example),
and allow to choose one and replace the full options block with it.

USAGE
------------------------------------------------------------------------------

    q|                      List all individual alternatives in the text form
                            close to the cursor and allow the user to choose one,
                            which then replaces the full options block.
    {Visual}q|              List all individual alternatives in the selected text
    {Select}CTRL-X |        form and allow the user to choose one, which then
                            replaces the selection.
    [count]q|               Replace the full options block / selection with the
    {Visual}[count]q|       [count]'th alternative from it.

    CTRL-X |                Convert the text form before the cursor into the
                            individual alternatives and offer them for completion.

### SYNTAX

    The text forms can be in simple and extended syntax. The simple syntax is just
    a list of word characters (without whitespace!), delimited by | characters:
        FOO|BAZ|QUUX
    You can include [], (), + and |, too, but you have to escape with a backslash.

    The extended syntax is bracketed by [...], and its alternatives can contain
    whitespace and any other characters.
        [FOO+BAR|My BAZ|The QUUX!]
    Additionally, you can append an optional explanation to each alternative. This
    will only be shown in the completion menu, but is not inserted into the
    buffer. The explanation must be enclosed in (...) and comes after the
    alternative text, separated by a <Space>:
        [FOO (default)|BAZ (softer)|QUUX (the special choice)]

    Another form element is a slider where the active element # can be positioned
    anywhere on the linear measure ----- between the [...] stops.
        [---#------]
    You can choose among all possible positions (indicated with their percentage
    ranges), and after that quickly adjust with CTRL-A / CTRL-X.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-TextFormComplete
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim TextFormComplete*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.037 or
  higher.
- SwapIt ([vimscript #2294](http://www.vim.org/scripts/script.php?script_id=2294)) plugin (optional)
- repeat.vim ([vimscript #2136](http://www.vim.org/scripts/script.php?script_id=2136)) plugin (optional)
- visualrepeat.vim ([vimscript #3848](http://www.vim.org/scripts/script.php?script_id=3848)) plugin (optional)

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

When there's only a single option, the plugin allows to deselect that value.
This expression configures what the deselected value is (in i\_CTRL-X\_Bar,
this must not be empty to be included in the completion list). By default, a
string of "---" with the same length as the sole option is offered. You can
change this to e.g. a single dash via:

    let g:TextFormComplete_DeselectionExpr = '"-"'

If you want to use different mappings, map your keys to the
&lt;Plug&gt;(TextFormComplete) mapping targets _before_ sourcing the script (e.g.
in your vimrc):

    imap <C-x><Bar> <Plug>(TextFormComplete)
    smap <C-x><Bar> <Plug>(TextFormComplete)
    nmap q<Bar> <Plug>(TextFormComplete)
    xmap q<Bar> <Plug>(TextFormComplete)

INTEGRATION
------------------------------------------------------------------------------

When the SwapIt plugin is installed, the completed alternatives are defined as
a :SwapList, so you can change your initial completed choice and move
through all alternatives just by pressing CTRL-A / CTRL-X on them. (With a
visual selection, this even works for alternatives containing whitespace!)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-TextFormComplete/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.11    RELEASEME
-

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.037!__

##### 1.10    15-Jan-2014
- ENH: Add support for sliders [---#-----].
- Set change marks when replacing the text form with a match from normal mode.

##### 1.00    04-Oct-2013
- First published version.

##### 0.01    21-Aug-2012
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
