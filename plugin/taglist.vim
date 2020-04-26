" File: taglist.vim
" Author: Yegappan Lakshmanan
" Version: l.9
" Last Modified: Oct 07, 2002
"
" Overview
" --------
" The "Tag List" plugin provides the following features:
"
" 1. Opens a vertically/horizontally split Vim window with a list of tags
"    (functions, classes, structures, variables, etc) defined in the current
"    file.
" 2. Groups the tags by their type and displays them in a foldable tree.
" 3. Automatically updates the taglist window as you switch between
"    files/buffers.
" 4. When a tag name is selected from the taglist window, positions the cursor
"    at the definition of the tag in the source file
" 5. Automatically highlights the current tag name.
" 6. Can display the prototype of a tag from the taglist window.
" 7. Displays the scope of a tag.
" 8. Can optionally use the tag prototype instead of the tag name.
" 9. The tag list can be sorted either by name or by line number.
" 10. Supports the following language files: Assembly, ASP, Awk, C, C++,
"     Cobol, Eiffel, Fortran, Java, Lisp, Make, Pascal, Perl, PHP, Python,
"     Rexx, Ruby, Scheme, Shell, Slang, TCL, Verilog, Vim and Yacc.
" 11. Runs in all the platforms where the exuberant ctags utility and Vim are
"     supported (this includes MS-Windows and Unix based systems).
" 12. Runs in both console/terminal and GUI versions of Vim.
" 13. The ctags output for a file is cached to speed up displaying the taglist
"     window.
"
" This plugin relies on the exuberant ctags utility to generate the tag
" listing. You can download the exuberant ctags utility from
" http://ctags.sourceforge.net. The exuberant ctags utility must be installed
" in your system to use this plugin. You should use exuberant ctags version
" 5.3 and above.  There is no need for you to create a tags file to use this
" plugin.
"
" Installation
" ------------
" 1. Copy the taglist.vim script to the $HOME/.vim/plugin directory.  Refer to
"    ':help add-plugin', ':help add-global-plugin' and ':help runtimepath' for
"    more details about Vim plugins.
" 2. Set the Tlist_Ctags_Cmd variable to point to the exuberant ctags utility
"    path.
" 3. If you are running a terminal/console version of Vim and the terminal
"    doesn't support changing the window width then set the Tlist_Inc_Winwidth
"    variable to 0.
" 4. Restart Vim.
" 5. You can use the ":Tlist" command to open/close the taglist window. 
"
" Usage
" -----
" You can open the taglist window from a source window by using the ":Tlist"
" command. Invoking this command will toggle (open or close) the taglist
" window. You can map a key to invoke this command:
"
"               nnoremap <silent> <F8> :Tlist<CR>
"
" Add the above mapping to your ~/.vimrc file.
"
" You can close the taglist window from the taglist window by pressing 'q' or
" using the Vim ":q" command. As you switch between source files, the taglist
" window will be automatically updated with the tag listing for the current
" source file.
"
" The tag names will grouped by their type (variable, function, class, etc)
" and displayed as a foldable tree using the Vim folding support. You can
" collapse the tree using the '-' key or using the Vim zc fold command. You
" can open the tree using the '+' key or using hte Vim zo fold command. You
" can open all the fold using the '*' key or using the Vim zR fold command
" You can also use the mouse to open/close the folds.
"
" You can select a tag either by pressing the <Enter> key or by double
" clicking the tag name using the mouse.
"
" For tags with scope information (like class members, structures inside
" structures, etc), the scope information will be displayed in square brackets
" "[]" after the tagname.
"
" The script will automatically highlight the name of the current tag.  The
" tag name will be highlighted after 'updatetime' milliseconds. The default
" value for this Vim option is 4 seconds.  You can also use the ":TlistSync"
" command to force the highlighting of the current tag. You can map a key to
" invoke this command:
"
"               nnoremap <silent> <F9> :TlistSync<CR>
"
" Add the above mapping to your ~/.vimrc file.
"
" If you place the cursor on a tag name in the "Tag List" window, then the tag
" prototype will be displayed at the Vim status line after 'updatetime'
" milliseconds. The default value for the 'updatetime' Vim option is 4
" seconds. You can also press the space bar to display the prototype of the
" tag under the cursor.
"
" By default, the tag list will be sorted by the order in which the tags
" appear in the file. You can sort the tags either by name or by order by
" pressing the "s" key in the taglist window.
"
" This script relies on the Vim "filetype" detection mechanism to determine
" the type of the current file. To turn on filetype detection use
"
"               :filetype on
"
" This script will not work in 'compatible' mode.  Make sure the 'compatible'
" option is not set.
"
" Configuration
" -------------
" By changing the following variables you can configure the behavior of this
" script. Set the following variables in your .vimrc file using the 'let'
" command.
"
" The script uses the Tlist_Ctags_Cmd variable to locate the ctags utility.
" By default, this is set to ctags. Set this variable to point to the location
" of the ctags utility in your system:
"
"               let Tlist_Ctags_Cmd = 'd:\tools\ctags.exe'
"
" By default, the tag names will be listed in the order in which they are
" defined in the file. You can alphabetically sort the tag names by pressing
" the "s" key in the taglist window. You can also change the default order by
" setting the variable Tlist_Sort_Type to "name" or "order":
"
"               let Tlist_Sort_Type = "name"
"
" Be default, the tag names will be listed in a vertically split window.  If
" you prefer a horizontally split window, then set the
" 'Tlist_Use_Horiz_Window' variable to 1. If you are running MS-Windows
" version of Vim in a MS-DOS command window, then you should use a
" horizontally split window instead of a vertically split window.  Also, if
" you are using an older version of xterm in a Unix system that doesn't
" support changing the xterm window width, you should use a horizontally split
" window.
"
"               let Tlist_Use_Horiz_Window = 1
"
" By default, the vertically split taglist window will appear on the left hand
" side. If you prefer to open the window on the right hand side, you can set
" the Tlist_Use_Right_Window variable to one:
"
"               let Tlist_Use_Right_Window = 1
"
" To automatically open the taglist window, when you start Vim, you can set
" the Tlist_Auto_Open variable to 1. By default, this variable is set to 0 and
" the taglist window will not be opened automatically on Vim startup.
"
"               let Tlist_Auto_Open = 1
"
" You can also open the taglist window on startup using the following command
" line:
"
"               $ vim +Tlist
"
" By default, only the tag name will be displayed in the taglist window. If
" you like to see tag prototypes instead of names, set the
" Tlist_Display_Prototype variable to 1. By default, this variable is set to 0
" and only tag names will be displayed.
"
"               let Tlist_Display_Prototype = 1
"
" The default width of the vertically split taglist window will be 30.  This
" can be changed by modifying the Tlist_WinWidth variable:
"
"               let Tlist_WinWidth = 20
"
" Note that the value of the 'winwidth' option setting determines the minimum
" width of the current window. If you set the 'Tlist_WinWidth' variable to a
" value less than that of the 'winwidth' option setting, then Vim will use the
" value of the 'winwidth' option.
"
" By default, when the width of the window is less than 100 and a new taglist
" window is opened vertically, then the window width will be increased by the
" value set in the Tlist_WinWidth variable to accomodate the new window.  The
" value of this variable is used only if you are using a vertically split
" taglist window.  If your terminal doesn't support changing the window width
" from Vim (older version of xterm running in a Unix system) or if you see any
" weird problems in the screen due to the change in the window width or if you
" prefer not to adjust the window width then set the 'Tlist_Inc_Winwidth'
" variable to 0.  CAUTION: If you are using the MS-Windows version of Vim in a
" MS-DOS command window then you must set this variable to 0, otherwise the
" system may hang due to a Vim limitation (explained in :help win32-problems)
"
"               let Tlist_Inc_Winwidth = 0
"
"
" ****************** Do not modify after this line ************************
if exists('loaded_taglist') || &cp
    finish
endif
let loaded_taglist=1

" Location of the exuberant ctags tool
if !exists('Tlist_Ctags_Cmd')
    let Tlist_Ctags_Cmd = 'ctags'
endif

" Tag listing sort type - 'name' or 'order'
if !exists('Tlist_Sort_Type')
    let Tlist_Sort_Type = 'order'
endif

" Tag listing window split (horizontal/vertical) control
if !exists('Tlist_Use_Horiz_Window')
    let Tlist_Use_Horiz_Window = 0
endif

" Open the vertically split taglist window on the left or on the right side.
" This setting is relevant only if Tlist_Use_Horiz_Window is set to zero (i.e.
" only for vertically split windows)
if !exists('Tlist_Use_Right_Window')
    let Tlist_Use_Right_Window = 0
endif

" Increase Vim window width to display vertically split taglist window.  For
" MS-Windows version of Vim running in a MS-DOS window, this must be set to 0
" otherwise the system may hang due to a Vim limitation.
if !exists('Tlist_Inc_Winwidth')
    if (has('win16') || has('win95')) && !has('gui_running')
        let Tlist_Inc_Winwidth = 0
    else
        let Tlist_Inc_Winwidth = 1
    endif
endif

" Vertically split taglist window width setting
if !exists('Tlist_WinWidth')
    let Tlist_WinWidth = 30
endif

" Automatically open the taglist window on Vim startup
if !exists('Tlist_Auto_Open')
    let Tlist_Auto_Open = 0
endif

" Display tag prototypes or tag names in the taglist window
if !exists('Tlist_Display_Prototype')
    let Tlist_Display_Prototype = 0
endif

" File types supported by taglist
let s:tlist_file_types = 'asm asp awk c cpp cobol eiffel fortran java lisp make pascal perl php python rexx ruby scheme sh slang tcl verilog vim yacc'

" assembly language
let s:tlist_asm_ctags_args = '--language-force=asm --asm-types=dlmt'
let s:tlist_asm_tag_types = 'define label macro type'

" asp language
let s:tlist_asp_ctags_args = '--language-force=asp --asp-types=fs'
let s:tlist_asp_tag_types = 'function sub'

" awk language
let s:tlist_awk_ctags_args = '--language-force=awk --awk-types=f'
let s:tlist_awk_tag_types = 'function'

" c language
let s:tlist_c_ctags_args = '--language-force=c --c-types=dgsutvf'
let s:tlist_c_tag_types = 'macro enum struct union typedef variable function'

" c++ language
let s:tlist_cpp_ctags_args = '--language-force=c++ --c++-types=vdtcgsuf'
let s:tlist_cpp_tag_types = 'macro typedef class enum struct union variable function'

" cobol language
let s:tlist_cobol_ctags_args = '--language-force=cobol --cobol-types=p'
let s:tlist_cobol_tag_types = 'paragraph'

" eiffel language
let s:tlist_eiffel_ctags_args = '--language-force=eiffel --eiffel-types=cf'
let s:tlist_eiffel_tag_types = 'class feature'

" fortran language
let s:tlist_fortran_ctags_args = '--language-force=fortran --fortran-types=bcefiklmnpstv'
let s:tlist_fortran_tag_types = 'block_data common entry function interface type label module namelist program subroutine derived variable'

" java language
let s:tlist_java_ctags_args = '--language-force=java --java-types=pcifm'
let s:tlist_java_tag_types = 'interface package class method field'

" lisp language
let s:tlist_lisp_ctags_args = '--language-force=lisp --lisp-types=f'
let s:tlist_lisp_tag_types = 'function'

" makefiles
let s:tlist_make_ctags_args = '--language-force=make --make-types=m'
let s:tlist_make_tag_types = 'macro'

" pascal language
let s:tlist_pascal_ctags_args = '--language-force=pascal --pascal-types=fp'
let s:tlist_pascal_tag_types = 'function procedure'

" perl language
let s:tlist_perl_ctags_args = '--language-force=perl --perl-types=ps'
let s:tlist_perl_tag_types = 'package subroutine'

" php language
let s:tlist_php_ctags_args = '--language-force=php --php-types=cf'
let s:tlist_php_tag_types = 'class function'

" python language
let s:tlist_python_ctags_args = '--language-force=python --python-types=cf'
let s:tlist_python_tag_types = 'class member function'

" rexx language
let s:tlist_rexx_ctags_args = '--language-force=rexx --rexx-types=c'
let s:tlist_rexx_tag_types = 'subroutine'

" ruby language
let s:tlist_ruby_ctags_args = '--language-force=ruby --ruby-types=cfFm'
let s:tlist_ruby_tag_types = 'mixin class method function singleton_method'

" scheme language
let s:tlist_scheme_ctags_args = '--language-force=scheme --scheme-types=sf'
let s:tlist_scheme_tag_types = 'set function'

" shell language
let s:tlist_sh_ctags_args = '--language-force=sh --sh-types=f'
let s:tlist_sh_tag_types = 'function'

" slang language
let s:tlist_slang_ctags_args = '--language-force=slang --slang-types=nf'
let s:tlist_slang_tag_types = 'namespace function'

" tcl language
let s:tlist_tcl_ctags_args = '--language-force=tcl --tcl-types=p'
let s:tlist_tcl_tag_types = 'procedure'

"verilog language
let s:tlist_verilog_ctags_args = '--language-force=verilog --verilog-types=mPrtwpvf'
let s:tlist_verilog_tag_types = 'module parameter reg task wire port variable function'

" vim language
let s:tlist_vim_ctags_args = '--language-force=vim --vim-types=vf'
let s:tlist_vim_tag_types = 'variable function'

" yacc language
let s:tlist_yacc_ctags_args = '--language-force=yacc --yacc-types=l'
let s:tlist_yacc_tag_types = 'label'

" Tlist_Init()
" Initialize the taglist script local variables for the supported file types
" and tag types
function! s:Tlist_Init()
    " Process each of the supported file types
    let fts = s:tlist_file_types . ' '
    while fts != ''
        let ftype = strpart(fts, 0, stridx(fts, ' '))
        if ftype != ''
            " Get the supported tag types for this file type
            let txt = 's:tlist_' . ftype . '_tag_types'
            if exists(txt)
                " Process each of the supported tag types
                let tts = s:tlist_{ftype}_tag_types . ' '
                let cnt = 0
                while tts != ''
                    " Create the script variable with the tag type name
                    let ttype = strpart(tts, 0, stridx(tts, ' '))
                    if ttype != ''
                        let cnt = cnt + 1
                        let s:tlist_{ftype}_{cnt}_name = ttype
                    endif
                    let tts = strpart(tts, stridx(tts, ' ') + 1)
                endwhile
                " Create the tag type count script local variable
                let s:tlist_{ftype}_count = cnt
            endif
        endif
        let fts = strpart(fts, stridx(fts, ' ') + 1)
    endwhile

    let s:tlist_winsize_chgd = 0
endfunction

" Initialize the script
call s:Tlist_Init()

function! s:Tlist_Show_Help()
    echo 'Keyboard shortcuts for the taglist window'
    echo '-----------------------------------------'
    echo '<Enter> : Jump to the tag definition'
    echo '<Space> : Display the tag prototype'
    echo 'u       : Update the tag list'
    echo 's       : Sort the tag list by ' . 
                            \ (b:tlist_sort_type == 'name' ? 'order' : 'name')
    echo '+       : Open a fold'
    echo '-       : Close a fold'
    echo '*       : Open all folds'
    echo 'q       : Close the taglist window'
endfunction

" An autocommand is used to refresh the taglist window when entering any
" buffer. We don't want to refresh the taglist window if we are entering the
" file window from one of the taglist functions. The 'Tlist_Skip_Refresh'
" variable is used to skip the refresh of the taglist window
let s:Tlist_Skip_Refresh = 0

function! s:Tlist_Warning_Msg(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

" Tlist_Toggle_Window()
" Open or close a taglist window
function! s:Tlist_Toggle_Window(bufnum)
    let curline = line('.')

    " Tag list window name
    let bname = '__Tag_List__'

    " If taglist window is open then close it.
    let winnum = bufwinnr(bname)
    if winnum != -1
        " Goto the taglist window, close it and then come back to the original
        " window
        let curbufnr = bufnr('%')
        exe winnum . 'wincmd w'
        close
        " Need to jump back to the original window only if we are not already
        " in that window
        let winnum = bufwinnr(curbufnr)
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
        return
    endif

    " Open the taglist window
    call s:Tlist_Explore_File(a:bufnum)

    " Highlight the current tag
    call s:Tlist_Highlight_Tag(a:bufnum, curline)

    let s:Tlist_Skip_Refresh = 1
    wincmd p
    let s:Tlist_Skip_Refresh = 0
endfunction

" Tlist_Open_Window
" Create a new taglist window. If it is already open, clear it
function! s:Tlist_Open_Window(bufnum)
    let filename = bufname(a:bufnum)

    " Tag list window name
    let bname = '__Tag_List__'

    " Cleanup the taglist window listing, if the window is open
    let winnum = bufwinnr(bname)
    if winnum != -1
        " Jump to the existing window
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif

        " Set report option to a huge value to prevent informations messages
        " while deleting the lines
        let old_report = &report
        set report=99999

        " Mark the buffer as modifiable
        setlocal modifiable

        " Delete the contents of the buffer to the black-hole register
        silent! %delete _

        " Restore the report option
        let &report = old_report

        " Clean up all the old variables used for the last filetype
        call <SID>Tlist_Cleanup()
    else
        " Create a new window. If user prefers a horizontal window, then open
        " a horizontally split window. Otherwise open a vertically split
        " window
        if g:Tlist_Use_Horiz_Window == 1
            " If a single window is used for all files, then open the tag
            " listing window at the very bottom
            let win_dir = 'botright'
            " Default horizontal window height is 10
            let win_width = 10
        else
            " Increase the window size, if needed, to accomodate the new
            " window
            if g:Tlist_Inc_Winwidth == 1 &&
                        \ &columns < (80 + g:Tlist_WinWidth)
                " one extra column is needed to include the vertical split
                let &columns= &columns + (g:Tlist_WinWidth + 1)
                let s:tlist_winsize_chgd = 1
            else
                let s:tlist_winsize_chgd = 0
            endif

            " Open the window at the leftmost place
            if g:Tlist_Use_Right_Window == 1
                let win_dir = 'botright vertical'
            else
                let win_dir = 'topleft vertical'
            endif
            let win_width = g:Tlist_WinWidth
        endif

        " If the tag listing temporary buffer already exists, then reuse it.
        " Otherwise create a new buffer
        let bufnum = bufnr(bname)
        if bufnum == -1
            " Create a new buffer
            let wcmd = bname
        else
            " Edit the existing buffer
            let wcmd = '+buffer' . bufnum
        endif

        " Create the taglist window
        exe 'silent! ' . win_dir . ' ' . win_width . 'split ' . wcmd
    endif

    " Set the sort type. First time, use the global setting. After that use
    " the previous setting
    let b:tlist_sort_type = getbufvar(a:bufnum, 'tlist_sort_type')
    if b:tlist_sort_type == ''
        let b:tlist_sort_type = g:Tlist_Sort_Type
    endif

    let b:tlist_tag_count = 0
    let b:tlist_bufnum = a:bufnum
    let b:tlist_bufname = fnamemodify(bufname(a:bufnum), ':p')
    let b:tlist_ftype = getbufvar(a:bufnum, '&filetype')

    call append(0, '" Press ? for help')
    call append(1, '" Sorted by ' . b:tlist_sort_type)
    call append(2, '" =' . fnamemodify(filename, ':t') . ' (' . 
                               \ fnamemodify(filename, ':p:h') . ')')

    " Mark the buffer as not modifiable
    setlocal nomodifiable

    " Highlight the comments
    if has('syntax')
        syntax match TagListComment '^" .*'

        " Colors used to highlight the selected tag name
        highlight clear TagName
        if has('gui_running') || &t_Co > 2
            highlight link TagName Search
        else
            highlight TagName term=reverse cterm=reverse
        endif

        " Colors to highlight comments and titles
        highlight clear TagListComment
        highlight link TagListComment Comment
        highlight clear TagListTitle
        highlight link TagListTitle Title
    endif
endfunction

" Tlist_Explore_File()
" List the tags defined in the specified file in a Vim window
function! s:Tlist_Explore_File(bufnum)
    " Get the filename and file type
    let filename = bufname(a:bufnum)
    let ftype = getbufvar(a:bufnum, '&filetype')

    " Open a new taglist window or refresh the existing taglist window
    call s:Tlist_Open_Window(a:bufnum)

    " Check for valid filename and valid filetype
    if filename == '' || !filereadable(filename) || ftype == ''
        return
    endif

    " Translate Vim filetypes to that supported by exuberant ctags
    if ftype == 'aspperl' || ftype == 'aspvbs'
        let ftype = 'asp'
    elseif ftype =~ '\<[cz]\=sh\>'
        let ftype = 'sh'
    endif

    " Make sure the current filetype is supported by exuberant ctags
    if stridx(s:tlist_file_types, ftype) == -1
        return
    endif

    " If the cached ctags output exists for the specified buffer, then use it.
    " Otherwise run ctags to get the output
    let valid_cache = getbufvar(a:bufnum, 'tlist_valid_cache')
    if valid_cache != ''
        " Load the cached processed tags output from the buffer local
        " variables
        let b:tlist_tag_count = getbufvar(a:bufnum, 'tlist_tag_count') + 0
        let i = 1
        while i <= b:tlist_tag_count
            let var_name = 'tlist_tag_' . i
            let b:tlist_tag_{i} =  getbufvar(a:bufnum, var_name)
            let i = i + 1
        endwhile

        let i = 1
        while i <= s:tlist_{ftype}_count
            let ttype = s:tlist_{ftype}_{i}_name
            let var_name = 'tlist_' . ttype . '_start'
            let b:tlist_{ftype}_{ttype}_start = 
                        \ getbufvar(a:bufnum, var_name) + 0
            let var_name = 'tlist_' . ttype . '_count'
            let cnt = getbufvar(a:bufnum, var_name) + 0
            let b:tlist_{ftype}_{ttype}_count = cnt
            let var_name = 'tlist_' . ttype
            let l:tlist_{ftype}_{ttype} = getbufvar(a:bufnum, var_name)
            let j = 1
            while j <= cnt
                let var_name = 'tlist_' . ttype . '_' . j
                let b:tlist_{ftype}_{ttype}_{j} = getbufvar(a:bufnum, var_name)
                let j = j + 1
            endwhile
            let i = i + 1
        endwhile
    else
        " Exuberant ctags arguments to generate a tag list
        let ctags_args = ' -f - --format=2 --excmd=pattern --fields=nKs '

        " Form the ctags argument depending on the sort type 
        if b:tlist_sort_type == 'name'
            let ctags_args = ctags_args . ' --sort=yes '
        else
            let ctags_args = ctags_args . ' --sort=no '
        endif

        " Add the filetype specific arguments
        let ctags_args = ctags_args . ' ' . s:tlist_{ftype}_ctags_args

        " Ctags command to produce output with regexp for locating the tags
        let ctags_cmd = g:Tlist_Ctags_Cmd . ctags_args
        let ctags_cmd = ctags_cmd . ' "' . filename . '"'

        " Run ctags and get the tag list
        let cmd_output = system(ctags_cmd)

        " Cache the ctags output with a buffer local variable
        call setbufvar(a:bufnum, 'tlist_valid_cache', 'Yes')
        call setbufvar(a:bufnum, 'tlist_sort_type', b:tlist_sort_type)

        " Handle errors
        if v:shell_error && cmd_output != ''
            call s:Tlist_Warning_Msg(cmd_output)
            return
        endif

        " No tags for current file
        if cmd_output == ''
            call s:Tlist_Warning_Msg('No tags found for ' . filename)
            return
        endif

        " Initialize variables for the new filetype
        let i = 1
        while i <= s:tlist_{ftype}_count
            let ttype = s:tlist_{ftype}_{i}_name
            let b:tlist_{ftype}_{ttype}_start = 0
            let b:tlist_{ftype}_{ttype}_count = 0
            let l:tlist_{ftype}_{ttype} = ''
            let i = i + 1
        endwhile

        " Process the ctags output one line at a time. Separate the tag output
        " based on the tag type and store it in the tag type variable
        let len = strlen(cmd_output)

        while cmd_output != ''
            let one_line = strpart(cmd_output, 0, stridx(cmd_output, "\n"))

            if one_line == ''
                " Line is not in proper tags format. Remove the line
                let cmd_output = strpart(cmd_output, 
                                        \ stridx(cmd_output, "\n") + 1, len)
                continue
            endif

            " Extract the tag type
            let start = strridx(one_line, '/;"' . "\t") + strlen('/;"' . "\t")
            let end = strridx(one_line, 'line:') - 1
            let ttype = strpart(one_line, start, end - start)

            if ttype == ''
                " Line is not in proper tags format. Remove the line
                let cmd_output = strpart(cmd_output, 
                                        \ stridx(cmd_output, "\n") + 1, len)
                continue
            endif

            " Replace all space characters in the tag type with underscore (_)
            let ttype = substitute(ttype, ' ', '_', 'g')

            " Extract the tag name
            if g:Tlist_Display_Prototype == 0
                let ttxt = '  ' . strpart(one_line, 0, stridx(one_line, "\t"))

                " Add the tag scope, if it is available. Tag scope is the last
                " field after the 'line:<num>\t' field
                let start = strridx(one_line, 'line:')
                let end = strridx(one_line, "\t")
                if end > start
                    let tscope = strpart(one_line, end + 1)
                    let tscope = strpart(tscope, stridx(tscope, ':') + 1)
                    if tscope != ''
                        let ttxt = ttxt . ' [' . tscope . ']'
                    endif
                endif
            else
                let start = stridx(one_line, '/^') + 2
                let end = strridx(one_line, '/;"' . "\t")
                if one_line[end - 1] == '$'
                    let end = end -1
                endif
                let ttxt = strpart(one_line, start, end - start)
            endif

            " Update the count of this tag type
            let cnt = b:tlist_{ftype}_{ttype}_count + 1
            let b:tlist_{ftype}_{ttype}_count = cnt

            " Add this tag to the tag type variable
            let l:tlist_{ftype}_{ttype} = l:tlist_{ftype}_{ttype} . ttxt . "\n"

            " Update the total tag count
            let b:tlist_tag_count = b:tlist_tag_count + 1
            let b:tlist_tag_{b:tlist_tag_count} = cnt . ':' . one_line

            let b:tlist_{ftype}_{ttype}_{cnt} = b:tlist_tag_count

            " Remove the processed line
            let cmd_output = strpart(cmd_output, 
                                    \ stridx(cmd_output, "\n") + 1, len)
        endwhile

        " Cache the processed tags output using buffer local variables
        call setbufvar(a:bufnum, 'tlist_tag_count', b:tlist_tag_count)
        let i = 1
        while i <= b:tlist_tag_count
            let var_name = 'tlist_tag_' . i
            call setbufvar(a:bufnum, var_name, b:tlist_tag_{i})
            let i = i + 1
        endwhile

        let i = 1
        while i <= s:tlist_{ftype}_count
            let ttype = s:tlist_{ftype}_{i}_name
            let var_name = 'tlist_' . ttype . '_start'
            call setbufvar(a:bufnum, var_name, b:tlist_{ftype}_{ttype}_start)
            let cnt = b:tlist_{ftype}_{ttype}_count
            let var_name = 'tlist_' . ttype . '_count'
            call setbufvar(a:bufnum, var_name, cnt)
            let var_name = 'tlist_' . ttype
            call setbufvar(a:bufnum, var_name, l:tlist_{ftype}_{ttype})
            let j = 1
            while j <= cnt
                let var_name = 'tlist_' . ttype . '_' . j
                call setbufvar(a:bufnum, var_name, b:tlist_{ftype}_{ttype}_{j})
                let j = j + 1
            endwhile
            let i = i + 1
        endwhile
    endif

    " Set report option to a huge value to prevent informational messages
    " while adding lines to the taglist window
    let old_report = &report
    set report=99999

    " Mark the buffer as modifiable
    setlocal modifiable

    " Add the tag names grouped by tag type to the buffer with a title
    let i = 1
    while i <= s:tlist_{ftype}_count
        let ttype = s:tlist_{ftype}_{i}_name
        " Add the tag type only if there are tags for that type
        if l:tlist_{ftype}_{ttype} != ''
            let b:tlist_{ftype}_{ttype}_start = line('.') + 1
            silent! put =ttype
            silent! put =l:tlist_{ftype}_{ttype}

            " create a fold for this tag type
            if has('folding')
                let fold_start = b:tlist_{ftype}_{ttype}_start
                let fold_end = fold_start + b:tlist_{ftype}_{ttype}_count
                exe fold_start . ',' . fold_end  . 'fold'
            endif

            " Syntax highlight the tag type names
            if has('syntax')
                exe 'syntax match TagListTitle /\%' . 
                            \ b:tlist_{ftype}_{ttype}_start . 'l.*/'
            endif
            " Separate the tag types with a empty line
            normal! G
            silent! put =''
        endif
        let i = i + 1
    endwhile

    " Mark the buffer as not modifiable
    setlocal nomodifiable

    " Restore the report option
    let &report = old_report

    " Initially open all the folds
    if has('folding')
        silent! %foldopen!
    endif

    " Goto the first line in the buffer
    go

    " In auto refresh mode, go back to the original window
    return
endfunction

" Tlist_Close_Window()
" Close the taglist window and adjust the Vim window width
function! s:Tlist_Close_Window()
    " Remove the autocommands for the taglist window
    silent! autocmd! TagListAutoCmds

    if g:Tlist_Use_Horiz_Window || g:Tlist_Inc_Winwidth == 0 ||
                \ s:tlist_winsize_chgd == 0 ||
                \ &columns < (80 + g:Tlist_WinWidth)
        " No need to adjust window width if horizontally split tag listing
        " window or if columns is less than 101 or if the user chose not to
        " adjust the window width
    else
        " Adjust the Vim window width
        let &columns= &columns - (g:Tlist_WinWidth + 1)
    endif
endfunction

" Tlist_Refresh_Window()
" Refresh the taglist window
function! s:Tlist_Refresh_Window()
    " We are entering the buffer from one of the taglist functions. So no need
    " to refresh the taglist window again
    if s:Tlist_Skip_Refresh == 1
        return
    endif

    let filename = expand('%:p')
    let curline = line('.')

    " No need to refresh taglist window
    if filename =~? '__Tag_List__'
        return
    endif

    " Tag list window name
    let bname = '__Tag_List__'

    " Make sure the taglist window is open. Otherwise, no need to refresh
    let winnum = bufwinnr(bname)
    if winnum == -1
        return
    endif

    let bno = bufnr(bname)

    let cur_bufnr = bufnr('%')

    " If the tag listing for the current window is already present, no need to
    " refresh it
    if getbufvar(bno, 'tlist_bufnum') == cur_bufnr && 
                \ getbufvar(bno, 'tlist_bufname') == filename
        return
    endif

    " Save the current window number
    let cur_winnr = winnr()

    " Update the taglist window
    call s:Tlist_Explore_File(cur_bufnr)

    " Highlight the current tag
    call s:Tlist_Highlight_Tag(cur_bufnr, curline)

    " Refresh the taglist window
    redraw

    " Jump back to the original window
    exe cur_winnr . 'wincmd w'
endfunction

" Tlist_Change_Sort()
" Change the sort order of the tag listing
function! s:Tlist_Change_Sort()
    if !exists('b:tlist_bufnum') || !exists('b:tlist_ftype')
        return
    endif

    let sort_type = getbufvar(b:tlist_bufnum, 'tlist_sort_type')

    " Toggle the sort order from 'name' to 'order' and vice versa
    if sort_type == 'name'
        call setbufvar(b:tlist_bufnum, 'tlist_sort_type', 'order')
    else
        call setbufvar(b:tlist_bufnum, 'tlist_sort_type', 'name')
    endif

    " Save the current line for later restoration
    let curline = '\V\^' . getline('.') . '\$'

    " Clear out the cached taglist information
    call setbufvar(b:tlist_bufnum, 'tlist_valid_cache', '')

    call s:Tlist_Explore_File(b:tlist_bufnum)

    " Go back to the tag line before the list is sorted
    call search(curline, 'w')
endfunction

" Tlist_Update_Window()
" Update the window by regenerating the tag list
function! s:Tlist_Update_Window()
    if !exists('b:tlist_bufnum') || !exists('b:tlist_ftype')
        return
    endif

    " Save the current line for later restoration
    let curline = '\V\^' . getline('.') . '\$'

    " Clear out the cached taglist information
    call setbufvar(b:tlist_bufnum, 'tlist_valid_cache', '')

    " Update the taglist window
    call s:Tlist_Explore_File(b:tlist_bufnum)

    " Go back to the tag line before the list is sorted
    call search(curline, 'w')
endfunction

" Tlist_Cleanup()
" Cleanup all the taglist window variables.
function! s:Tlist_Cleanup()
    if has('syntax')
        silent! syntax clear TagListTitle
    endif
    match none

    if exists('b:tlist_ftype') && b:tlist_ftype != ''
        let count_var_name = 's:tlist_' . b:tlist_ftype . '_count'
        if exists(count_var_name)
            let old_ftype = b:tlist_ftype
            let i = 1
            while i <= s:tlist_{old_ftype}_count
                let ttype = s:tlist_{old_ftype}_{i}_name
                let j = 1
                let var_name = 'b:tlist_' . old_ftype . '_' . ttype . '_count'
                if exists(var_name)
                    let cnt = b:tlist_{old_ftype}_{ttype}_count
                else
                    let cnt = 0
                endif
                while j <= cnt
                    unlet! b:tlist_{old_ftype}_{ttype}_{j}
                    let j = j + 1
                endwhile
                unlet! b:tlist_{old_ftype}_{ttype}_count
                unlet! b:tlist_{old_ftype}_{ttype}_start
                let i = i + 1
            endwhile
        endif
    endif

    " Clean up all the variables containing the tags output
    if exists('b:tlist_tag_count')
        while b:tlist_tag_count > 0
            unlet! b:tlist_tag_{b:tlist_tag_count}
            let b:tlist_tag_count = b:tlist_tag_count - 1
        endwhile
    endif

    unlet! b:tlist_bufnum
    unlet! b:tlist_bufname
    unlet! b:tlist_ftype
endfunction

function! s:Tlist_Init_Window()
    " Folding related settings
    if has('folding')
        setlocal foldenable
        setlocal foldmethod=manual
        setlocal foldcolumn=2
        setlocal foldtext=v:folddashes.getline(v:foldstart)
    endif

    " Mark buffer as scratch
    silent! setlocal buftype=nofile
    silent! setlocal bufhidden=delete
    silent! setlocal noswapfile
    silent! setlocal nowrap
    silent! setlocal buflisted

    " If the 'number' option is set in the source window, it will affect the
    " taglist window. So forcefully disable 'number' option for the taglist
    " window
    silent! setlocal nonumber

    " Create buffer local mappings for jumping to the tags and sorting the list
    nnoremap <buffer> <silent> <CR> :call <SID>Tlist_Jump_To_Tag()<CR>
    nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>Tlist_Jump_To_Tag()<CR>
    nnoremap <buffer> <silent> s :call <SID>Tlist_Change_Sort()<CR>
    nnoremap <buffer> <silent> + :silent! foldopen<CR>
    nnoremap <buffer> <silent> - :silent! foldclose<CR>
    nnoremap <buffer> <silent> * :silent! %foldopen!<CR>
    nnoremap <buffer> <silent> <kPlus> :silent! foldopen<CR>
    nnoremap <buffer> <silent> <kMinus> :silent! foldclose<CR>
    nnoremap <buffer> <silent> <kMultiply> :silent! %foldopen!<CR>
    nnoremap <buffer> <silent> <Space> :call <SID>Tlist_Show_Tag_Prototype()<CR>
    nnoremap <buffer> <silent> u :call <SID>Tlist_Update_Window()<CR>
    nnoremap <buffer> <silent> ? :call <SID>Tlist_Show_Help()<CR>
    nnoremap <buffer> <silent> q :close<CR>

    " Define the autocommand to highlight the current tag
    augroup TagListAutoCmds
        autocmd!
        " Display the tag prototype for the tag under the cursor.
        autocmd CursorHold __Tag_List__ call s:Tlist_Show_Tag_Prototype()
        " Highlight the current tag 
        autocmd CursorHold * silent call <SID>Tlist_Highlight_Tag(bufnr('%'), line('.'))
        " Adjust the Vim window width when taglist window is closed
        autocmd BufDelete __Tag_List__ call <SID>Tlist_Close_Window()
        " Auto refresh the taglisting window
        autocmd BufEnter * call <SID>Tlist_Refresh_Window()
    augroup end
endfunction

" Tlist_Get_Tag_Linenr()
" Return the tag line for the current line
function! s:Tlist_Get_Tag_Linenr()
    if !exists('b:tlist_ftype')
        return 0
    endif

    let lnum = line('.')
    let ftype = b:tlist_ftype

    " Determine to which tag type the current line number belongs to using the
    " tag type start line number and the number of tags in a tag type
    let i = 1
    while i <= s:tlist_{ftype}_count
        let ttype = s:tlist_{ftype}_{i}_name
        let end = b:tlist_{ftype}_{ttype}_start + b:tlist_{ftype}_{ttype}_count
        if lnum >= b:tlist_{ftype}_{ttype}_start && lnum <= end
            break
        endif
        let i = i + 1
    endwhile

    " Current line doesn't belong to any of the displayed tag types
    if i > s:tlist_{ftype}_count
        return 0
    endif

    " Compute the offset into the displayed tags for the tag type
    let offset = lnum - b:tlist_{ftype}_{ttype}_start
    if offset == 0
        return 0
    endif

    " Get the corresponding tag line and return it
    return b:tlist_{ftype}_{ttype}_{offset}
endfunction

function! s:Tlist_Highlight_Tagline()
    " Clear previously selected name
    match none

    " Highlight the current selected name
    if g:Tlist_Display_Prototype == 0
        exe 'match TagName /\%' . line('.') . 'l\s\+\zs.*/'
    else
        exe 'match TagName /\%' . line('.') . 'l.*/'
    endif
endfunction

" Tlist_Jump_To_Tag()
" Jump to the location of the current tag
function! s:Tlist_Jump_To_Tag()
    " Do not process comment lines and empty lines
    let curline = getline('.')
    if curline == '' || curline[0] == '"'
        return
    endif

    " Get the tag output for the current tag
    let lnum = s:Tlist_Get_Tag_Linenr()
    if lnum == 0
        return
    endif

    let mtxt = b:tlist_tag_{lnum}
    let start = stridx(mtxt, '/^') + 2
    let end = strridx(mtxt, '/;"' . "\t")
    if mtxt[end - 1] == '$'
        let end = end - 1
    endif
    let tagpat = '\V\^' . strpart(mtxt, start, end - start) .
                                        \ (mtxt[end] == '$' ? '\$' : '')

    " Highlight the tagline
    call s:Tlist_Highlight_Tagline()

    let s:Tlist_Skip_Refresh = 1

    " Goto the window containing the file.  If the window is not there, open a
    " new window
    let winnum = bufwinnr(b:tlist_bufnum)
    if winnum == -1
        if g:Tlist_Use_Horiz_Window == 1
            exe 'leftabove split #' . b:tlist_bufnum
        else
            " Open the file in a window and skip refreshing the taglist window
            exe 'rightbelow vertical split #' . b:tlist_bufnum
            " Go to the taglist window to change the window size to the user
            " configured value
            wincmd p
            exe 'vertical resize ' . g:Tlist_WinWidth
            " Go back to the file window
            wincmd p
        endif
    else
        exe winnum . 'wincmd w'
    endif

    " Jump to the tag
    silent call search(tagpat, 'w')

    " Bring the line to the middle of the window
    normal! z.

    let s:Tlist_Skip_Refresh = 0
endfunction

" Tlist_Show_Tag_Prototype()
" Display the prototype of the tag under the cursor
function! s:Tlist_Show_Tag_Prototype()
    " If we have already display prototype in the tag window, no need to
    " display it in the status line
    if g:Tlist_Display_Prototype == 1
        return
    endif

    " Clear the previously displayed line
    echo

    " Do not process comment lines and empty lines
    let curline = getline('.')
    if curline == '' || curline[0] == '"'
        return
    endif

    " Get the tag output line for the current tag
    let lnum = s:Tlist_Get_Tag_Linenr()
    if lnum == 0
        return
    endif

    let mtxt = b:tlist_tag_{lnum}

    " Get the tag search pattern and display it
    let start = stridx(mtxt, '/^') + 2
    let end = strridx(mtxt, '/;"' . "\t")
    if mtxt[end - 1] == '$'
        let end = end -1
    endif
    let tag_pat = strpart(mtxt, start, end - start)
    let tag_pat = matchstr(tag_pat, '^\s*\zs.*')

    echo tag_pat
endfunction

" Tlist_Highlight_Tag()
" Do a binary search in the array of tag names and pick a tag entry that
" contains the current line and highlight it.  The idea behind this function
" is taken from the ctags.vim script available at the Vim online website.
function! s:Tlist_Highlight_Tag(bufnum, curline)
    let filename = bufname(a:bufnum)
    if filename == ''
        return
    endif

    " Tag list window name
    let bname = '__Tag_List__'

    " Make sure the taglist window is present
    let winnum = bufwinnr(bname)
    if winnum == -1
        return
    endif

    let bno = bufnr(bname)

    " Make sure we have the tag listing for the current file
    if getbufvar(bno, 'tlist_bufnum') != a:bufnum
        return
    endif

    " If there are no tags for this file, then no need to proceed further
    if getbufvar(bno, 'tlist_tag_count') == 0
        return
    endif

    " Save the original window number
    let org_winnr = winnr()

    if org_winnr == winnum
        let in_taglist_window = 1
    else
        let in_taglist_window = 0
    endif

    " Go to the taglist window
    if !in_taglist_window
        exe winnum . 'wincmd w'
    endif

    " Clear previously selected name
    match none

    let left = 1
    let right = b:tlist_tag_count

    if getbufvar(bno, 'tlist_sort_type') == 'order'
        " Tag list sorted by order, do a binary search comparing the line
        " numbers

        " If the current line is the less than the first tag, then no need to
        " search
        let txt = b:tlist_tag_1
        let start = strridx(txt, 'line:') + strlen('line:')
        let end = strridx(txt, "\t")
        if end < start
            let first_lnum = strpart(txt, start) + 0
        else
            let first_lnum = strpart(txt, start, end - start) + 0
        endif

        if a:curline < first_lnum
            if !in_taglist_window
                let s:Tlist_Skip_Refresh = 1
                exe org_winnr . 'wincmd w'
                let s:Tlist_Skip_Refresh = 0
            endif
            return
        endif

        while left < right
            let middle = (right + left + 1) / 2
            let txt = b:tlist_tag_{middle}

            let start = strridx(txt, 'line:') + strlen('line:')
            let end = strridx(txt, "\t")
            if end < start
                let middle_lnum = strpart(txt, start) + 0
            else
                let middle_lnum = strpart(txt, start, end - start) + 0
            endif

            if middle_lnum == a:curline
                let left = middle
                break
            endif

            if middle_lnum > a:curline
                let right = middle - 1
            else
                let left = middle
            endif
        endwhile
    else
        " sorted by name, brute force method (Dave Eggum)
        let closest_lnum = 0
        let final_left = 0
        while left < right
            let txt = b:tlist_tag_{left}

            let start = strridx(txt, 'line:') + strlen('line:')
            let end = strridx(txt, "\t")
            if end < start
                let lnum = strpart(txt, start) + 0
            else
                let lnum = strpart(txt, start, end - start) + 0
            endif

            if lnum < a:curline && lnum > closest_lnum
                let closest_lnum = lnum
                let final_left = left
            elseif lnum == a:curline
                let closest_lnum = lnum
                break
            else
                let left = left + 1
            endif
        endwhile
        if closest_lnum == 0
            if !in_taglist_window
                let s:Tlist_Skip_Refresh = 1
                exe org_winnr . 'wincmd w'
                let s:Tlist_Skip_Refresh = 0
            endif
            return
        endif
        if left == right
            let left = final_left
        endif
    endif

    let tag_txt = b:tlist_tag_{left}

    " Extract the tag type
    let start = strridx(tag_txt, '/;"' . "\t") + strlen('/;"' . "\t")
    let end = strridx(tag_txt, 'line:') - 1
    let ttype = strpart(tag_txt, start, end - start)
    " Replace all space characters in the tag type with underscore (_)
    let ttype = substitute(ttype, ' ', '_', 'g')

    " Extract the tag offset
    let offset = strpart(tag_txt, 0, stridx(tag_txt, ':')) + 0

    " Compute the line number
    let lnum = b:tlist_{b:tlist_ftype}_{ttype}_start + offset

    " Goto the line containing the tag
    exe lnum

    " Open the fold
    if has('folding')
        silent! .foldopen
    endif

    " Call winline() to make sure the target line is visible in the taglist
    " window. This is a side effect of calling winline(). Don't know of a
    " better way to achieve this.
    call winline()

    " Highlight the tag name
    call s:Tlist_Highlight_Tagline()

    " Go back to the original window
    if !in_taglist_window
        let s:Tlist_Skip_Refresh = 1
        exe org_winnr . 'wincmd w'
        let s:Tlist_Skip_Refresh = 0
    endif

    return
endfunction

" Define tag listing autocommand to automatically open the taglist window on
" Vim startup
if g:Tlist_Auto_Open
    autocmd VimEnter * nested Tlist
endif

autocmd VimLeave * nested call <SID>Tlist_Close_Window()
autocmd BufWinEnter __Tag_List__ call <SID>Tlist_Init_Window()

" Define the 'Tlist' and 'TlistSync' user commands to open/close taglist
" window
command! -nargs=0 Tlist call s:Tlist_Toggle_Window(bufnr('%'))
command! -nargs=0 TlistSync call s:Tlist_Highlight_Tag(bufnr('%'), line('.'))
