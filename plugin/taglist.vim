" File: taglist.vim
" Author: Yegappan Lakshmanan
" Version: l.4
" Last Modified: July 16, 2002
"
" Overview
" --------
" The "Tag List" (taglist.vim) plugin script opens a Vim window with a list of
" tags (functions, structures, variables, classes, etc) defined in the current
" file. When you select a tag name from this window, the cursor will be
" positioned at the definition of the tag in the source file. This script
" will run in both GUI and console/terminal version of Vim.
"
" This script relies on the exuberant ctags utility
" (http://ctags.sourceforge.net) to generate the tag listing.  This script
" will run on all the platforms where the exuberant ctags utility is supported
" (this includes MS-Windows and Unix based systems). You have to use exuberant
" ctags version 5.0 and above
"
" This script supports the following language files: Assembly, ASP, Awk, C,
" C++, Cobol, Eiffel, Fortran, Java, Lisp, Make, Pascal, Perl, PHP, Python,
" Rexx, Ruby, Scheme, Shell, Slang, TCL and Vim.
"
" You can select a tag either by pressing the <Enter> key or by double
" clicking the name using a mouse.
"
" The tag names will grouped by type (variable, function, class, etc) and
" displayed as a tree using the Vim folding support. You can collapse the
" tree using the '-' key or using the Vim zc fold command. You can open
" the tree using the '+' key or using hte Vim zo fold command. You can
" open all the fold using the '*' key or using the Vim zR fold command
"
" The script will automatically highlight the name of the current tag.  The
" tag name will be highlighted after 'updatetime' milliseconds. The default
" value for this Vim option is 4 seconds.  The highlighting will work only if
" the tag list is sorted by order. If the tag listing is sorted by name, the
" tag highlighting will not work.
"
" If you place the cursor on a tag name in the "Tag List" window, then the tag
" prototype will be displayed at the Vim status line after 'updatetime'
" milliseconds. The default value for the 'updatetime' Vim option is 4
" seconds. You can press the space bar to display the prototype of the tag
" under the cursor.
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
" By default, this is set to ctags. Set this variable in your .vimrc file to
" point to the location of the ctags utility in your system
"
"               let Tlist_Ctags_Cmd = 'd:\tools\ctags.exe'
"
" To open the tag list window, you have to press the key defined by the
" Tlist_Key variable. By default, this variable is set to the <F8> key.
" You can modify this to a different key in your .vimrc file:
"
"               let Tlist_Key = '\l'
"
" When the cursor is not moved for a period specified by the 'updatetime' Vim
" option, the script will automatically highlight the tag under the cursor. To
" force the current tag name highlight, you can press the key defined by the
" Tlist_Sync_Key variable. By default, this variable is set to the <F9> key.
" You can modify this to a different key in your .vimrc file:
"
"               let Tlist_Sync_Key = '\h'
"
" By default, the tag names will be listed in the order in
" which they are defined in the file. You can alphabetically sort the tag
" names by pressing the "s" key in the tag list window. You can also
" change the default order by setting the variable Tlist_Sort_Type to
" "name" or "order" in your .vimrc file:
"
"               let Tlist_Sort_Type = "name"
"
" Be default, the tag names will be listed in a vertically split window.  If
" you prefer a horizontally split window, then set the
" 'Tlist_Use_Horiz_Window' variable to 1 in your .vimrc file. If you are
" running MS-Windows version of Vim in a MS-DOS command window, then you
" should use a horizontally split window instead of a vertically split window.
" Also, if you are using an older version of xterm in a Unix system that
" doesn't support changing the xterm window width, you should use a
" horizontally split window.
"
"               let Tlist_Use_Horiz_Window = 1
"
" By default, the vertically split tag listing window will appear on the left
" hand side. If you prefer to open the window on the right hand side, you can
" set the Tlist_Use_Right_Window variable to one:
"
"               let Tlist_Use_Right_Window = 1
"
" By default, the tag names will be listed in only one window. The window will
" be reused for listing tags from different files. If you prefer to open a tag
" list window for each file separately then set the 'Tlist_Use_One_Window'
" variable to 0:
"
"               let Tlist_Use_One_Window = 0
"
" To automatically refresh the tag list window as you switch between buffers,
" set the Tlist_Auto_Refresh variable to 1. By default, this variable is set
" to 0 and the automatic refresh is disabled.
"
"               let Tlist_Auto_Refresh = 1
"
" To automatically open the tag list window, when you start Vim, you can set
" the Tlist_Auto_Open variable to 1. By default, this variable is set to 0 and
" the tag list window will not be opened automatically on Vim startup.
"
"               let Tlist_Auto_Open = 1
"
" By default, only the tag name will be displayed in the tag list window. If
" you like to see tag prototypes instead of names, set the
" Tlist_Display_Prototype variable to 1. By default, this variable is set to 0
" and tag names will be displayed.
"
"               let Tlist_Display_Prototype = 1
"
" By default, when the width of the window is less than 100 and a new tag list
" window is opened vertically, then the window width will be increased by the
" value set in the Tlist_WinWidth variable to accomodate for the new window.
" The value of this variable is used only if you are using a vertically split
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
" The default width of vertically split tag list window will be 20.  This can
" be changed by modifying the Tlist_WinWidth variable:
"
"               let Tlist_WinWidth = 30
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

" Key to open the tag listing window
if !exists('Tlist_Key')
    let Tlist_Key = '<F8>'
endif

" Key to highlight the current tag
if !exists('Tlist_Sync_Key')
    let Tlist_Sync_Key = '<F9>'
endif

" Tag listing sort type
if !exists('Tlist_Sort_Type')
    let Tlist_Sort_Type = 'order'
endif

" Tag listing window split (horizontal/vertical) control
if !exists('Tlist_Use_Horiz_Window')
    let Tlist_Use_Horiz_Window = 0
endif

" Open the vertically split tag listing window on the left or on the right
" side. This setting is relevant only if Tlist_Use_Horiz_Window is set
" to zero (i.e. only for vertically split windows)
if !exists('Tlist_Use_Right_Window')
    let Tlist_Use_Right_Window = 0
endif

" Increase Vim window width to display vertically split tag listing window.
" For MS-Windows version of Vim running in a MS-DOS window, this must be set
" to 0 otherwise the system may hang due to a Vim limitation.
if !exists('Tlist_Inc_Winwidth')
    if (has('win16') || has('win95')) && !has('gui_running')
        let Tlist_Inc_Winwidth = 0
    else
        let Tlist_Inc_Winwidth = 1
    endif
endif

" Use only one window for listing the tags in all the files or use one
" window per file
if !exists('Tlist_Use_One_Window')
    let Tlist_Use_One_Window = 1
endif

" Vertically split tag listing window width setting
if !exists('Tlist_WinWidth')
    let Tlist_WinWidth = 20
endif

" Auto refresh the tag display window
if !exists('Tlist_Auto_Refresh')
    let Tlist_Auto_Refresh = 0
endif

" Automatically open the tag list window on Vim startup
if !exists('Tlist_Auto_Open')
    let Tlist_Auto_Open = 0
endif

" Display tag prototypes or tag names
if !exists('Tlist_Display_Prototype')
    let Tlist_Display_Prototype = 0
endif

" Map the key to open the tag window and to highlight the current tag
exe 'nnoremap <unique> <silent> ' . Tlist_Key . 
            \ " :call <SID>Tlist_Toggle_Window(bufnr('%'))<CR>"
exe 'nnoremap <unique> <silent> ' . Tlist_Sync_Key . 
            \ " :call <SID>Tlist_Highlight_Tag(bufnr('%'), line('.'))<CR>"

" Colors used to highlight the selected tag name
highlight clear TagName
if has('gui_running') || &t_Co> 2
    highlight TagName term=reverse cterm=bold
    highlight TagName ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
else
    highlight TagName term=reverse cterm=reverse
endif

" Colors to highlight comments and titles
if has('syntax')
    highlight default link TagListComment Comment
    highlight default link TagListTitle Title
endif

" File types supported by taglist
let s:tlist_file_types = 'asm asp awk c cpp cobol eiffel fortran java lisp make pascal perl php python rexx ruby scheme sh slang tcl vim yacc'

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
let s:tlist_cpp_tag_types = 'variable macro typedef class enum struct union function'

" cobol language
let s:tlist_cobol_ctags_args = '--language-force=cobol --cobol-types=p'
let s:tlist_cobol_tag_types = 'paragraph'

" eiffel language
let s:tlist_eiffel_ctags_args = '--language-force=eiffel --eiffel-types=cf'
let s:tlist_eiffel_tag_types = 'class feature'

" fortran language
let s:tlist_fortran_ctags_args = '--language-force=fortran --fortran-types=bcefiklmnpstv'
let s:tlist_fortran_tag_types = 'block common entry function interface type label module namelist program subroutine derived module'

" java language
let s:tlist_java_ctags_args = '--language-force=java --java-types=pcifm'
let s:tlist_java_tag_types = 'method class field package interface'

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
let s:tlist_python_tag_types = 'class function'

" rexx language
let s:tlist_rexx_ctags_args = '--language-force=rexx --rexx-types=c'
let s:tlist_rexx_tag_types = 'subroutine'

" ruby language
let s:tlist_ruby_ctags_args = '--language-force=ruby --ruby-types=cf'
let s:tlist_ruby_tag_types = 'class function'

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
endfunction

" Initialize the script
call s:Tlist_Init()

function! s:Tlist_Show_Help()
    echo 'Keyboard shortcuts for the taglist window'
    echo '-----------------------------------------'
    echo '<Enter> : Jump to the tag definition'
    echo '<Space> : Display tag prototype'
    echo 'u : Update the the tag list'
    echo 's : Sort by ' . (w:tlist_sort_type == 'name' ? 'order' : 'name')
    echo '+ : Open a fold'
    echo '- : Close a fold'
    echo '* : Open all folds'
    echo 'q : Close the taglist window'
endfunction

" Get taglist window name
function! s:Tlist_Get_Window_Name(filename)
    " For empty files and for single taglist window cases, the name of the
    " taglist window is __Tag_List__. For all other cases, the name is formed
    " from the filename
    if g:Tlist_Use_One_Window == 1 || a:filename == ''
        return '__Tag_List__'
    else
        return '__' . a:filename . '__Tag_List__'
    endif
endfunction

function! s:Tlist_Warning_Msg(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

" Tlist_Toggle_Window()
" Open or close a tag list window
function! s:Tlist_Toggle_Window(bufnum)
    let filename = bufname(a:bufnum)

    " No need to process tag list windows
    if filename =~? '__Tag_List__'
        return
    endif

    let curline = line('.')

    " Tag list window name
    let winname = s:Tlist_Get_Window_Name(filename)

    " If taglist window is open then close it. Close the window only if the
    " current tag listing is for the current file.
    let winnum = bufwinnr(winname)
    if winnum != -1 && getwinvar(winnum, 'tlist_bufnum') == a:bufnum
        " Goto the tag list window, close it and then come back to the
        " original window
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

    " Open the tag list window
    call s:Tlist_Explore_File(a:bufnum)

    " Highlight the current tag
    call s:Tlist_Highlight_Tag(a:bufnum, curline)
endfunction

" Tlist_Open_Window
" Create a new taglist window. If it is already open, clear it
function! s:Tlist_Open_Window(bufnum)
    let filename = bufname(a:bufnum)

    " Tag list window name
    let winname = s:Tlist_Get_Window_Name(filename)

    " Cleanup the taglist window listing, if the window is open
    let winnum = bufwinnr(winname)
    if winnum != -1
        " Jump to the existing window
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
        " Make the buffer modifiable
        silent! setlocal modifiable

        " Set report option to a huge value to prevent informations messages
        " while deleting the lines
        let old_report = &report
        set report=99999

        " Delete the contents of the buffer to the black-hole register
        silent! %delete _

        " Restore the report option
        let &report = old_report

        " Clean up all the old variables used for the last filetype
        call <SID>Tlist_Cleanup(0)
    else
        " Create a new window. If user prefers a horizontal window, then
        " open a horizontally split window. Otherwise open a vertically
        " split window
        if g:Tlist_Use_Horiz_Window == 1
            if g:Tlist_Use_One_Window == 1
                " If a single window is used for all files, then open the tag
                " listing window at the very bottom
                let win_dir = 'botright'
            else
                " Otherwise, open the window below the current window
                let win_dir = 'rightbelow'
            endif
            " Default horizontal window height is 10
            let win_width = 10
        else
            " Increase the window size, if needed, to accomodate the new
            " window
            if g:Tlist_Inc_Winwidth == 1 && 
                        \ &columns < (80 + g:Tlist_WinWidth)
                " one extra column is needed to include the vertical split
                let &columns= &columns + (g:Tlist_WinWidth + 1)
            endif

            " If only one tag list window should be used, then open the
            " window at the leftmost place. Otherwise open a new vertically
            " split window
            if g:Tlist_Use_One_Window == 1
                if g:Tlist_Use_Right_Window == 1
                    let win_dir = 'botright vertical'
                else
                    let win_dir = 'topleft vertical'
                endif
            else
                if g:Tlist_Use_Right_Window == 1
                    let win_dir = 'rightbelow vertical'
                else
                    let win_dir = 'leftabove vertical'
                endif
            endif
            let win_width = g:Tlist_WinWidth
        endif

        " If the tag listing temporary buffer already exists, then reuse it.
        " Otherwise create a new buffer
        let bufnum = bufnr(winname)
        if bufnum == -1
            " Create a new buffer
            let wcmd = winname
        else
            " Edit the existing buffer
            let wcmd = '+buffer' . bufnum
        endif

        " Create the taglist window
        exe 'silent! ' . win_dir . ' ' . win_width . 'split ' . wcmd
    endif

    " Set the sort type. First time, use the global setting. After that use
    " the previous setting
    if !exists('w:tlist_sort_type')
        let w:tlist_sort_type = g:Tlist_Sort_Type
    endif

    let w:tlist_tag_count = 0
    let w:tlist_bufnum = a:bufnum
    let w:tlist_bufname = fnamemodify(bufname(a:bufnum), ':p')
    let w:tlist_ftype = getbufvar(a:bufnum, '&filetype')

    call append(0, '" Press ? for keyboard shortcuts')
    call append(1, '" Sorted by ' . w:tlist_sort_type)
    call append(2, '" =' . fnamemodify(filename, ':t') . ' (' . 
                               \ fnamemodify(filename, ':p:h') . ')')

    " Highlight the comments
    if has('syntax')
        syntax match TagListComment '^" .*'
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
        if g:Tlist_Auto_Refresh == 1
            wincmd p
        endif
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
        if g:Tlist_Auto_Refresh == 1
            wincmd p
        endif
        return
    endif

    " If the cached ctags output exists for the specified buffer, then use it.
    " Otherwise run ctags to get the output
    let cmd_output = getbufvar(a:bufnum, 'tlist_ctags_output')
    if cmd_output != ''
        " Load the cached processed tags output from the buffer local
        " variables
        let w:tlist_tag_count = getbufvar(a:bufnum, 'tlist_tag_count') + 0
        let i = 1
        while i <= w:tlist_tag_count
            let var_name = 'tlist_tag_' . i
            let w:tlist_tag_{i} =  getbufvar(a:bufnum, var_name)
            let i = i + 1
        endwhile

        let i = 1
        while i <= s:tlist_{ftype}_count
            let ttype = s:tlist_{ftype}_{i}_name
            let var_name = 'tlist_' . ttype . '_start'
            let w:tlist_{ftype}_{ttype}_start = getbufvar(a:bufnum, var_name) + 0
            let var_name = 'tlist_' . ttype . '_count'
            let cnt = getbufvar(a:bufnum, var_name) + 0
            let w:tlist_{ftype}_{ttype}_count = cnt
            let var_name = 'tlist_' . ttype
            let l:tlist_{ftype}_{ttype} = getbufvar(a:bufnum, var_name)
            let j = 1
            while j <= cnt
                let var_name = 'tlist_' . ttype . '_' . j
                let w:tlist_{ftype}_{ttype}_{j} = getbufvar(a:bufnum, var_name)
                let j = j + 1
            endwhile
            let i = i + 1
        endwhile
    else
        " Exuberant ctags arguments to generate a tag list
        let ctags_args = ' -f - --format=2 --excmd=pattern --fields=nK '

        " Form the ctags argument depending on the sort type 
        if w:tlist_sort_type == 'name'
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
        call setbufvar(a:bufnum, 'tlist_ctags_output', cmd_output)

        " Handle errors
        if v:shell_error && cmd_output != ''
            call s:Tlist_Warning_Msg(cmd_output)
            if g:Tlist_Auto_Refresh == 1
                wincmd p
            endif
            return
        endif

        " No tags for current file
        if cmd_output == ''
            call s:Tlist_Warning_Msg('No tags found for ' . filename)
            if g:Tlist_Auto_Refresh == 1
                wincmd p
            endif
            return
        endif

        " Initialize variables for the new filetype
        let i = 1
        while i <= s:tlist_{ftype}_count
            let ttype = s:tlist_{ftype}_{i}_name
            let w:tlist_{ftype}_{ttype}_start = 0
            let w:tlist_{ftype}_{ttype}_count = 0
            let l:tlist_{ftype}_{ttype} = ''
            let i = i + 1
        endwhile

        " Process the ctags output one line at a time. Separate the tag
        " output based on the tag type and store it in the tag type
        " variable
        let len = strlen(cmd_output)

        while cmd_output != ''
            let one_line = strpart(cmd_output, 0, stridx(cmd_output, "\n"))

            " Extract the tag type
            let start = stridx(one_line, '/;"' . "\t") + strlen('/;"' . "\t")
            let end = strridx(one_line, "\t")
            let ttype = strpart(one_line, start, end - start)

            " Extract the tag name
            if g:Tlist_Display_Prototype == 0
                let ttxt = '  ' . strpart(one_line, 0, stridx(one_line, "\t"))
            else
                let start = stridx(one_line, '/^') + 2
                let end = stridx(one_line, '/;"' . "\t")
                if one_line[end - 1] == '$'
                    let end = end -1
                endif
                let ttxt = strpart(one_line, start, end - start)
            endif

            " Update the count of this tag type
            let cnt = w:tlist_{ftype}_{ttype}_count + 1
            let w:tlist_{ftype}_{ttype}_count = cnt

            " Add this tag to the tag type variable
            let l:tlist_{ftype}_{ttype} = l:tlist_{ftype}_{ttype} . ttxt . "\n"

            " Update the total tag count
            let w:tlist_tag_count = w:tlist_tag_count + 1
            let w:tlist_tag_{w:tlist_tag_count} = cnt . ':' . one_line

            let w:tlist_{ftype}_{ttype}_{cnt} = w:tlist_tag_count

            " Remove the processed line
            let cmd_output = strpart(cmd_output, 
                                    \ stridx(cmd_output, "\n") + 1, len)
        endwhile

        " Cache the processed tags output using buffer local variables
        call setbufvar(a:bufnum, 'tlist_tag_count', w:tlist_tag_count)
        let i = 1
        while i <= w:tlist_tag_count
            let var_name = 'tlist_tag_' . i
            call setbufvar(a:bufnum, var_name, w:tlist_tag_{i})
            let i = i + 1
        endwhile

        let i = 1
        while i <= s:tlist_{ftype}_count
            let ttype = s:tlist_{ftype}_{i}_name
            let var_name = 'tlist_' . ttype . '_start'
            call setbufvar(a:bufnum, var_name, w:tlist_{ftype}_{ttype}_start)
            let cnt = w:tlist_{ftype}_{ttype}_count
            let var_name = 'tlist_' . ttype . '_count'
            call setbufvar(a:bufnum, var_name, cnt)
            let var_name = 'tlist_' . ttype
            call setbufvar(a:bufnum, var_name, l:tlist_{ftype}_{ttype})
            let j = 1
            while j <= cnt
                let var_name = 'tlist_' . ttype . '_' . j
                call setbufvar(a:bufnum, var_name, w:tlist_{ftype}_{ttype}_{j})
                let j = j + 1
            endwhile
            let i = i + 1
        endwhile
    endif

    " Set report option to a huge value to prevent informations messages
    " while adding lines to the taglist window
    let old_report = &report
    set report=99999

    " Add the tag names grouped by tag type to the buffer with a title
    let i = 1
    while i <= s:tlist_{ftype}_count
        let ttype = s:tlist_{ftype}_{i}_name
        " Add the tag type only if there are tags for that type
        if l:tlist_{ftype}_{ttype} != ''
            let w:tlist_{ftype}_{ttype}_start = line('.') + 1
            silent! put =ttype
            silent! put =l:tlist_{ftype}_{ttype}

            " create a fold for this tag type
            if has('folding')
                let fold_start = w:tlist_{ftype}_{ttype}_start
                let fold_end = fold_start + w:tlist_{ftype}_{ttype}_count
                exe fold_start . ',' . fold_end  . 'fold'
            endif

            " Syntax highlight the tag type names
            if has('syntax')
                exe 'syntax match TagListTitle /\%' . 
                            \ w:tlist_{ftype}_{ttype}_start . 'l.*/'
            endif
            " Separate the tag types with a empty line
            normal! G
            silent! put =''
        endif
        let i = i + 1
    endwhile

    " Restore the report option
    let &report = old_report

    " Initially open all the folds
    if has('folding')
        %foldopen!
    endif

    " Mark the buffer as not modifiable
    silent! setlocal nomodifiable

    " Goto the first line in the buffer
    go

    " In auto refresh mode, go back to the original window
    if g:Tlist_Auto_Refresh == 1
        wincmd p
    endif
endfunction

" Tlist_Close_Window()
" Close the tag listing window and adjust the Vim window width
function! s:Tlist_Close_Window()
    if g:Tlist_Use_Horiz_Window || 
                \ &columns < (80 + g:Tlist_WinWidth) || 
                \ g:Tlist_Inc_Winwidth == 0
        " No need to adjust window width if horizontally split tag
        " listing window or if columns is less than 101 or if the user chose
        " not to adjust the window width
        return
    endif

    if g:Tlist_Use_One_Window == 1
        " Only one window is used for listing tags and that window is getting
        " closed, so adjust the width
        let &columns= &columns - (g:Tlist_WinWidth + 1)
    else
        " Multiple windows are used for listing tags, adjust only if needed
        let i = 1
        let cnt = 0
        let bufno = winbufnr(i)

        " Make sure no tag listing window is open
        while bufno != -1
            if bufname(bufno) =~ '__Tag_List__'
                let cnt = cnt + 1
            endif
            let i = i + 1
            let bufno = winbufnr(i)
        endwhile

        if cnt > 1
            " Some tag listing window is still open
            return
        endif

        " Adjust the Vim window width
        let &columns= &columns - (g:Tlist_WinWidth + 1)
    endif
endfunction

" Tlist_Refresh_Window()
" Refresh the tag listing window
function! s:Tlist_Refresh_Window()
    " Tag list window will be refreshed only for single window option
    if g:Tlist_Auto_Refresh == 0 || g:Tlist_Use_One_Window == 0
        return
    endif

    let filename = expand('%:p')
    let curline = line('.')

    " No need to refresh tag list windows
    if filename =~? '__Tag_List__'
        return
    endif

    " Tag list window name
    let winname = s:Tlist_Get_Window_Name(filename)

    " Make sure the tag listing window is open. Otherwise, no need to refresh
    let winnum = bufwinnr(winname)
    if winnum == -1
        return
    endif

    let cur_bufnr = bufnr('%')

    " If the tag listing for the current window is already present, no need to
    " refresh it
    if getwinvar(winnum, 'tlist_bufnum') == cur_bufnr && 
                \ getwinvar(winnum, 'tlist_bufname') == filename
        return
    endif

    " Save the current window number
    let cur_winnr = winnr()

    " Update the tag list window
    call s:Tlist_Explore_File(cur_bufnr)

    " Highlight the current tag
    call s:Tlist_Highlight_Tag(cur_bufnr, curline)

    " Refresh the tag list window
    exe winnum . 'wincmd w'
    redraw
    " Jump back to the original window
    exe cur_winnr . 'wincmd w'
endfunction

" Tlist_Change_Sort()
" Change the sort order of the tag listing
function! s:Tlist_Change_Sort()
    if !exists('w:tlist_bufnum') || !exists('w:tlist_ftype')
        return
    endif

    " Toggle the sort order from 'name' to 'order' and vice versa
    if w:tlist_sort_type == 'name'
        let w:tlist_sort_type = 'order'
    else
        let w:tlist_sort_type = 'name'
    endif

    " Save the current line for later restoration
    let curline = '\V\^' . getline('.') . '\$'

    call s:Tlist_Explore_File(w:tlist_bufnum)

    " Go back to the tag line before the list is sorted
    call search(curline, 'w')
endfunction

" Tlist_Update_Window()
" Update the window by regenerating the tag listing
function! s:Tlist_Update_Window()
    if !exists('w:tlist_bufnum') || !exists('w:tlist_ftype')
        return
    endif

    " Save the current line for later restoration
    let curline = '\V\^' . getline('.') . '\$'

    " Clear out the previous ctags output
    call setbufvar(w:tlist_bufnum, 'tlist_ctags_output', '')

    " Update the tag list window
    call s:Tlist_Explore_File(w:tlist_bufnum)

    " Go back to the tag line before the list is sorted
    call search(curline, 'w')
endfunction

" Tlist_Cleanup()
" Cleanup all the tag list window variables.
" 'level' specifies the level of cleanup requested. 1 - complete cleanup
function! s:Tlist_Cleanup(level)
    if a:level != 1
        if has('syntax')
            syntax clear TagListTitle
        endif
    endif
    match none

    if exists('w:tlist_ftype') && w:tlist_ftype != ''
        let count_var_name = 's:tlist_' . w:tlist_ftype . '_count'
        if exists(count_var_name)
            let old_ftype = w:tlist_ftype
            let i = 1
            while i <= s:tlist_{old_ftype}_count
                let ttype = s:tlist_{old_ftype}_{i}_name
                let j = 1
                let var_name = 'w:tlist_' . old_ftype . '_' . ttype . '_count'
                if exists(var_name)
                    let cnt = w:tlist_{old_ftype}_{ttype}_count
                else
                    let cnt = 0
                endif
                while j <= cnt
                    unlet! w:tlist_{old_ftype}_{ttype}_{j}
                    let j = j + 1
                endwhile
                unlet! w:tlist_{old_ftype}_{ttype}_count
                unlet! w:tlist_{old_ftype}_{ttype}_start
                let i = i + 1
            endwhile
        endif
    endif

    " Clean up all the variables containing the tags output
    if exists('w:tlist_tag_count')
        while w:tlist_tag_count > 0
            unlet! w:tlist_tag_{w:tlist_tag_count}
            let w:tlist_tag_count = w:tlist_tag_count - 1
        endwhile
    endif

    unlet! w:tlist_bufnum
    unlet! w:tlist_bufname
    unlet! w:tlist_ftype
    if a:level == 1
        unlet! w:tlist_sort_type
        unlet! w:tlist_tag_count
    endif
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
endfunction

" Tlist_Get_Tag_Linenr()
" Return the tag line for the current line
function! s:Tlist_Get_Tag_Linenr()
    if !exists('w:tlist_ftype')
        return 0
    endif

    let lnum = line('.')
    let ftype = w:tlist_ftype

    " Determine to which tag type the current line number belongs to using
    " the tag type start line number and the number of tags in a tag type
    let i = 1
    while i <= s:tlist_{ftype}_count
        let ttype = s:tlist_{ftype}_{i}_name
        let end = w:tlist_{ftype}_{ttype}_start + w:tlist_{ftype}_{ttype}_count
        if lnum >= w:tlist_{ftype}_{ttype}_start && lnum <= end
            break
        endif
        let i = i + 1
    endwhile

    " Current line doesn't belong to any of the displayed tag types
    if i > s:tlist_{ftype}_count
        return 0
    endif

    " Compute the offset into the displayed tags for the tag type
    let offset = lnum - w:tlist_{ftype}_{ttype}_start
    if offset == 0
        return 0
    endif

    " Get the corresponding tag line and return it
    return w:tlist_{ftype}_{ttype}_{offset}
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

    let mtxt = w:tlist_tag_{lnum}
    let start = stridx(mtxt, '/^') + 2
    let end = stridx(mtxt, '/;"' . "\t")
    if mtxt[end - 1] == '$'
        let end = end - 1
    endif
    let tagpat = '\V\^' . strpart(mtxt, start, end - start) .
                                        \ (mtxt[end] == '$' ? '\$' : '')

    " Clear previously selected name
    match none

    " Highlight the current selected name
    if g:Tlist_Display_Prototype == 0
        exe 'match TagName /\%' . line('.') . 'l\s\+\zs.*/'
    else
        exe 'match TagName /\%' . line('.') . 'l.*/'
    endif

    " Goto the window containing the file.  If the window is not there,
    " open a new window
    let winnum = bufwinnr(w:tlist_bufnum)
    if winnum == -1
        if g:Tlist_Use_Horiz_Window == 1
            exe 'leftabove split #' . w:tlist_bufnum
        else
            exe 'rightbelow vertical split #' . w:tlist_bufnum
            wincmd p
            exe 'vertical resize ' . g:Tlist_WinWidth
            wincmd p
        endif
    else
        exe winnum . 'wincmd w'
    endif

    " Jump to the tag
    silent call search(tagpat, 'w')

    " Bring the line to the middle of the window
    normal! z.
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

    let mtxt = w:tlist_tag_{lnum}

    " Get the tag search pattern and display it
    let start = stridx(mtxt, '/^') + 2
    let end = stridx(mtxt, '/;"' . "\t")
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
    let winname = s:Tlist_Get_Window_Name(filename)

    " Make sure the tag listing window is present
    let winnum = bufwinnr(winname)
    if winnum == -1
        return
    endif

    " Make sure we have the tag listing for the current file
    if getwinvar(winnum, 'tlist_bufnum') != a:bufnum
        return
    endif

    " If the tag listing is sorted by name, do not highlight.
    " We need the tag listing to be sorted by order
    if getwinvar(winnum, 'tlist_sort_type') == 'name'
        return
    endif

    " If there are no tags for this file, then no need to proceed further
    if getwinvar(winnum, 'tlist_tag_count') == 0
        return
    endif

    " Save the original window number
    let org_winnr = winnr()

    " Goto the tag listing window
    exe winnum . 'wincmd w'

    " Clear previously selected name
    match none

    " If the current line is the less than the first tag, then no need to
    " search
    let txt = w:tlist_tag_1
    let first_lnum = strpart(txt, stridx(txt, 'line:') + strlen('line:')) + 0
    if a:curline < first_lnum
        exe org_winnr . 'wincmd w'
        return
    endif

    " Do a binary search comparing the line numbers
    let left = 1
    let right = w:tlist_tag_count

    while left < right
        let middle = (right + left + 1) / 2
        let txt = w:tlist_tag_{middle}
        let middle_lnum = strpart(txt, stridx(txt, 'line:') + 
                                                      \ strlen('line:')) + 0

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

    let tag_txt = w:tlist_tag_{left}

    " Extract the tag type
    let start = stridx(tag_txt, '/;"' . "\t") + strlen('/;"' . "\t")
    let end = strridx(tag_txt, "\t")
    let ttype = strpart(tag_txt, start, end - start)

    " Extract the tag offset
    let offset = strpart(tag_txt, 0, stridx(tag_txt, ':')) + 0

    " Compute the line number
    let lnum = w:tlist_{w:tlist_ftype}_{ttype}_start + offset

    " Goto the line containing the tag
    exe lnum

    " Open the fold
    if has('folding')
        silent! .foldopen
    endif

    " Bring the line to the center of the window
    normal! z.

    " Highlight the tag name
    if g:Tlist_Display_Prototype == 0
        exe 'match TagName /\%' . lnum . 'l\s\+\zs.*/'
    else
        exe 'match TagName /\%' . lnum . 'l.*/'
    endif

    " Go back to the original window
    exe org_winnr . 'wincmd w'

    return
endfunction

" Define tag listing autocommands
augroup TagListAutoCmds
    autocmd!
    " Display the tag prototype for the tag under the cursor.
    autocmd CursorHold *__Tag_List__ call s:Tlist_Show_Tag_Prototype()
    " Highlight the current tag 
    autocmd CursorHold * silent call <SID>Tlist_Highlight_Tag(bufnr('%'), line('.'))
    autocmd BufWinEnter *__Tag_List__ call <SID>Tlist_Init_Window()
    " Adjust the Vim window width when tag listing window is closed
    autocmd BufDelete *__Tag_List__ call <SID>Tlist_Close_Window()
    autocmd BufUnload *__Tag_List__ call <SID>Tlist_Cleanup(1)
    " Auto refresh the taglisting window
    autocmd BufEnter * call <SID>Tlist_Refresh_Window()
    if g:Tlist_Auto_Open
        let g:Tlist_Auto_Refresh = 1
        autocmd VimEnter * nested call <SID>Tlist_Explore_File(bufnr('%'))
        autocmd VimLeave * nested call <SID>Tlist_Close_Window()
    endif
augroup end
