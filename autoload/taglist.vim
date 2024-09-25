" File: taglist.vim
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Version: 5.0
" Last Modified: Aug 6, 2022
"
" Copyright: Copyright (C) 2002-2022 Yegappan Lakshmanan
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            taglist.vim is provided *as is* and comes with no warranty of any
"            kind, either expressed or implied. In no event will the copyright
"            holder be liable for any damages resulting from the use of this
"            software.

" Line continuation used here
if !exists('s:cpo_save')
  " If the taglist plugin is sourced recursively, the 'cpo' setting will be
  " set to the default value.  To avoid this problem, save the cpo setting
  " only when the plugin is loaded for the first time.
  let s:cpo_save = &cpo
endif
set cpo&vim

" Location of the Universal/exuberant ctags tool
if !exists('g:Tlist_Ctags_Cmd')
  " Keep the ctags executable names below sorted by the most commonly used
  " names at the top.
  if has('win32')
    " MS-Windows
    let ctags_exe_names = ['ctags.exe']
  else
    " Unix-like system
    let ctags_exe_names = [
          \ 'ctags',
          \ 'ctags-universal',
          \ 'exuberant-ctags',
          \ 'universal-ctags',
          \ 'exctags',
          \ 'tags'
          \ ]
  endif
  let ctags_found = v:false
  for e in ctags_exe_names
    if executable(e)
      let g:Tlist_Ctags_Cmd = e
      let ctags_found = v:true
      break
    endif
  endfor

  if !ctags_found
    echomsg 'Taglist: Universal ctags (https://ctags.io/) is ' .
          \ 'not found in PATH. Plugin is not loaded.'
    finish
  endif
endif

" Initialize options to default values (if not set by the user)
"
" The options and their default values are:
"   Tlist_Auto_Highlight_Tag = v:true
"     Automatically highlight the current tag.
"   Tlist_Auto_Open = v:false
"     Automatically open the taglist window on Vim startup.
"   Tlist_Auto_Update = v:true
"     Automatically update the taglist window to display tags for newly edited
"     files.
"   Tlist_Close_On_Select = v:false
"     Close the taglist window when a tag is selected.
"   Tlist_Compact_Format = v:false
"     Control whether additional help is displayed as part of the taglist or
"     not.  Also, controls whether empty lines are used to separate the tag
"     tree.
"   Tlist_Display_Prototype = v:false
"     Display tag prototypes or tag names in the taglist window.
"   Tlist_Display_Tag_Scope = v:true
"     Display tag scopes in the taglist window.
"   Tlist_Enable_Fold_Column = v:true
"     Enable fold column to display the folding for the tag tree.
"   Tlist_Exit_OnlyWindow = v:false
"     Exit Vim if only the taglist window is currently open.
"   Tlist_File_Fold_Auto_Close = v:false
"     Automatically close the folds for the non-active files in the taglist
"     window.
"   Tlist_GainFocus_On_ToggleOpen = v:false
"     When the taglist window is toggle opened, move the cursor to the taglist
"     window.
"   Tlist_Highlight_Tag_On_BufEnter = v:true
"     Automatically highlight the current tag on entering a buffer.
"   Tlist_Inc_Winwidth = v:true
"     Increase Vim window width to display vertically split taglist window.
"   Tlist_Max_Submenu_Items = 20
"     Maximum number of tag names to display in a submenu.
"   Tlist_Max_Tag_Length = 10
"     Maximum number of characters in a tag name to display in a menu item.
"   Tlist_Process_File_Always = v:false
"     Process files even when the taglist window is not open.
"   Tlist_Show_Menu = v:false
"     Display the tags in a menu.
"   Tlist_Show_One_File = v:false
"     Display the tags for only one file in the taglist window.
"   Tlist_Sort_Type = 'order'
"     Tag listing sort type - 'name' or chronological 'order'.
"   Tlist_Use_Horiz_Window = v:false
"     Tag listing window split (horizontal/vertical) control.
"   Tlist_Use_Right_Window = v:false
"     Open the vertically split taglist window on the left or on the right
"     side.  This setting is relevant only if Tlist_Use_Horiz_Window is set to
"     v:false (i.e. only for vertically split windows).
"   Tlist_Use_SingleClick = v:false
"     Use single left mouse click to jump to a tag.  Only double click using
"     the mouse will be processed.
"   Tlist_WinWidth = 30
"     Vertically split taglist window width setting.
"   Tlist_WinHeight = 10
"     Horizontally split taglist window height setting.
func! s:OptionsInitDefault()
  let defvalues = [
        \ ['Auto_Highlight_Tag', v:true],
        \ ['Auto_Open', v:false],
        \ ['Auto_Update', v:true],
        \ ['Close_On_Select', v:false],
        \ ['Compact_Format', v:false],
        \ ['Display_Prototype', v:false],
        \ ['Display_Tag_Scope', v:true],
        \ ['Enable_Fold_Column', v:true],
        \ ['Exit_OnlyWindow', v:false],
        \ ['File_Fold_Auto_Close', v:false],
        \ ['GainFocus_On_ToggleOpen', v:false],
        \ ['Highlight_Tag_On_BufEnter', v:true],
        \ ['Inc_Winwidth', v:true],
        \ ['Max_Submenu_Items', 20],
        \ ['Max_Tag_Length', 10],
        \ ['Process_File_Always', v:false],
        \ ['Show_Menu', v:false],
        \ ['Show_One_File', v:false],
        \ ['Sort_Type', 'order'],
        \ ['Use_Horiz_Window', v:false],
        \ ['Use_Right_Window', v:false],
        \ ['Use_SingleClick', v:false],
        \ ['WinHeight', 10],
        \ ['WinWidth', 30]
        \ ]
  for [name, val] in defvalues
    let optname = 'g:Tlist_' . name
    if !exists(optname)
      exe 'let ' . optname . ' = ' . string(val)
    endif
  endfor
endfunc
call s:OptionsInitDefault()

" Name of the taglist buffer/window
let s:TagList_title = '__Tag_List__'

" Taglist debug messages
let s:tlist_msg = []

augroup TaglistBufAutoCmds
  " When the taglist buffer is created when loading a Vim session file,
  " the taglist buffer needs to be initialized. The BufFilePost event
  " is used to handle this case.
  autocmd BufFilePost __Tag_List__ call s:Tlist_Vim_Session_Load()

  " When a buffer is deleted, remove the file from the taglist
  autocmd BufDelete * silent call s:Tlist_Buffer_Removed(expand('<afile>:p'))
augroup END

" Default language specific settings for supported file types and tag types
"
" The dict key is the file type detected by Vim.
"
" Value format:
"
"       <ctags_ftype>;<flag>:<name>;<flag>:<name>;...
"
" ctags_ftype - File type supported by Universal ctags
" flag        - Flag supported by Universal ctags to generate a tag type
" name        - Name of the tag type used in the taglist window to display the
"               tags of this type
"

let s:tlist_lang_def = {}

" Ant
let s:tlist_lang_def['ant'] = 'ant;p:projects;t:targets'

" assembly
let s:tlist_lang_def['asm'] = 'asm;s:section;d:define;l:label;m:macro;t:type'

" aspperl
let s:tlist_lang_def['aspperl'] =
      \ 'asp;c:class;d:constant;v:variable;f:function;s:subroutine'

" aspvbs
let s:tlist_lang_def['aspvbs'] =
      \ 'asp;c:class;d:constant;v:variable;f:function;s:subroutine'

" awk
let s:tlist_lang_def['awk'] = 'awk;f:function'

" basic
let s:tlist_lang_def['basic'] =
      \ 'basic;c:constant;l:label;g:enum;v:variable;t:type;f:function'

" beta
let s:tlist_lang_def['beta'] = 'beta;f:fragment;s:slot;v:pattern'

" c
let s:tlist_lang_def['c'] =
      \ 'c;d:macro;g:enum;s:struct;u:union;t:typedef;v:variable;f:function'

" c++
let s:tlist_lang_def['cpp'] = 'c++;n:namespace;v:variable;d:macro;t:typedef;' .
      \ 'c:class;g:enum;s:struct;u:union;f:function'

" c#
let s:tlist_lang_def['cs'] = 'c#;d:macro;t:typedef;n:namespace;c:class;' .
      \ 'E:event;g:enum;s:struct;i:interface;' .
      \ 'p:properties;m:method'

" cobol
let s:tlist_lang_def['cobol'] = 'cobol;d:data;f:file;g:group;p:paragraph;' .
      \ 'P:program;s:section'

" D programming language
let s:tlist_lang_def['d'] = 'c++;n:namespace;v:variable;t:typedef;' .
      \ 'c:class;g:enum;s:struct;u:union;f:function'

" Dosbatch
let s:tlist_lang_def['dosbatch'] = 'dosbatch;l:labels;v:variables'

" eiffel
let s:tlist_lang_def['eiffel'] = 'eiffel;c:class;f:feature'

" erlang
let s:tlist_lang_def['erlang'] = 'erlang;d:macro;r:record;m:module;f:function'

" expect (same as tcl)
let s:tlist_lang_def['expect'] = 'tcl;c:class;f:method;p:procedure'

" flex
let s:tlist_lang_def['flex'] = 'flex;v:global;c:classes;p:properties;' .
      \ 'm:methods;f:functions;x:mxtags'

" fortran
let s:tlist_lang_def['fortran'] = 'fortran;p:program;b:block data;' .
      \ 'c:common;e:entry;i:interface;k:type;l:label;m:module;' .
      \ 'n:namelist;t:derived;v:variable;f:function;s:subroutine'

" GO
let s:tlist_lang_def['go'] = 'go;p:package;s:struct;i:interface;f:function'

" HTML
let s:tlist_lang_def['html'] = 'html;a:anchor;c:class;C:stylesheet;J:script'

" java
let s:tlist_lang_def['java'] =
      \ 'java;p:package;c:class;i:interface;g:enum;f:field;m:method'

" javascript
let s:tlist_lang_def['javascript'] =
      \ 'javascript;c:class;m:method;v:global;f:function;p:properties'

" kotlin
let s:tlist_lang_def['kotlin'] =
      \ 'kotlin;p:package;i:interface;c:class;o:object;m:method;T:typealias;C:constant;v:variable'

" lisp
let s:tlist_lang_def['lisp'] = 'lisp;f:function'

" lua
let s:tlist_lang_def['lua'] = 'lua;f:function'

" makefiles
let s:tlist_lang_def['make'] = 'make;m:macro;t:target;I:makefiles'

" Matlab
let s:tlist_lang_def['matlab'] = 'matlab;c:class;f:function;v:variable'

" Ocamal
let s:tlist_lang_def['ocamal'] = 'ocamal;M:module;v:global;t:type;' .
      \ 'c:class;f:function;m:method;C:constructor;e:exception'

" pascal
let s:tlist_lang_def['pascal'] = 'pascal;f:function;p:procedure'

" perl
let s:tlist_lang_def['perl'] = 'perl;c:constant;l:label;p:package;s:subroutine'

" php
let s:tlist_lang_def['php'] = 'php;n:namespace;c:class;i:interface;d:constant;' .
      \ 'v:variable;f:function'

" python
let s:tlist_lang_def['python'] = 'python;v:variable;c:class;m:member;f:function'

" cython
let s:tlist_lang_def['pyrex'] = 'python;c:classe;m:memder;f:function'

" rexx
let s:tlist_lang_def['rexx'] = 'rexx;s:subroutine'

" ruby
let s:tlist_lang_def['ruby'] =
      \ 'ruby;c:class;f:method;F:function;m:modules;S:singleton methods'

" scheme
let s:tlist_lang_def['scheme'] = 'scheme;s:set;f:function'

" shell
let s:tlist_lang_def['sh'] = 'sh;a:alias;f:function'

" C shell
let s:tlist_lang_def['csh'] = 'sh;a:alias;f:function'

" Z shell
let s:tlist_lang_def['zsh'] = 'sh;a:alias;f:function'

" slang
let s:tlist_lang_def['slang'] = 'slang;n:namespace;f:function'

" sml
let s:tlist_lang_def['sml'] = 'sml;e:exception;c:functor;s:signature;' .
      \ 'r:structure;t:type;v:value;c:functor;f:function'

" sql
let s:tlist_lang_def['sql'] = 'sql;f:functions;' .
      \ 'P:packages;p:procedures;t:tables;T:triggers;' .
      \ 'v:variables;e:events;U:publications;R:services;' .
      \ 'D:domains;x:MLTableScripts;y:MLConnScripts;z:MLProperties;' .
      \ 'i:indexes;c:cursors;V:views;d:prototypes;' .
      \ 'l:local variables;E:record fields;L:block label;' .
      \ 'r:records;s:subtypes'

" tcl
let s:tlist_lang_def['tcl'] = 'tcl;c:class;f:method;m:method;p:procedure'

" Tex
let s:tlist_lang_def['tex'] = 'tex;c:chapters;s:sections;u:subsections;' .
      \ 'b:subsubsections;p:parts;P:paragraphs;G:subparagraphs'

" vera
let s:tlist_lang_def['vera'] = 'vera;c:class;d:macro;e:enumerator;' .
      \ 'f:function;g:enum;m:member;p:program;' .
      \ 'P:prototype;t:task;T:typedef;v:variable;' .
      \ 'x:externvar'

" verilog
let s:tlist_lang_def['verilog'] = 'verilog;m:module;c:constant;P:parameter;' .
      \ 'e:event;r:register;t:task;w:write;p:port;v:variable;f:function'

" VHDL
let s:tlist_lang_def['vhdl'] = 'vhdl;c:constant;t:type;T:subtype;r:record;' .
      \ 'e:entity;f:function;p:procedure;P:package'

" vim
let s:tlist_lang_def['vim'] =
      \ 'vim;v:variable;a:autocmds;c:commands;m:map;f:function'

" yacc
let s:tlist_lang_def['yacc'] = 'yacc;l:label'

" CMake
let s:tlist_lang_def['cmake'] =
      \ 'cmake;m:macros;f:function;t:target;v:variable;D:option'

" Markdown
let s:tlist_lang_def['markdown'] = 'markdown;c:chapters;s:sections;' .
      \ 'S:subsections;t:subsubsections'

" Rust
let s:tlist_lang_def['rust'] = 'rust;n:module;M:macro;g:enum;s:struct;i:trait;' .
      \ 'c:implementation;P:method;f:function'

" CSS
let s:tlist_lang_def['css'] = 'css;c:class;f:function;v:variable;i:identity'

" KConfig
let s:tlist_lang_def['kconfig'] =
      \ 'kconfig;c:config;m:menu;k:kconfig file;C:choice'

" TypeScript
let s:tlist_lang_def['typescript'] = 'typescript;n:namespace;c:class;' .
      \ 'i:interface;g:enum;v:variable;p:property;f:function'

"------------------- end of language specific options --------------------

" Vim window size is changed by the taglist plugin or not
let s:tlist_winsize_chgd = -1
let s:tlist_pre_winx = 0
let s:tlist_pre_winy = 0
let s:tlist_winx = 0
let s:tlist_winy = 0
" Taglist window is maximized or not
let s:tlist_win_maximized = v:false
" Number of files in the taglist
let s:tlist_file_count = 0
" Are we displaying brief help text
let s:tlist_brief_help = v:true
" List of files removed on user request
let s:tlist_removed_flist = {}
" Index of current file displayed in the taglist window
let s:tlist_cur_file_idx = -1
" Taglist menu is empty or not
let s:tlist_menu_empty = v:true

" files information
let s:files = []
let s:fname2idx = {}

" file type information
let s:ftypes = {}
" For each file type, store the tag types by the user specified order.
let s:ordered_ttypes = {}

" An autocommand is used to refresh the taglist window when entering any
" buffer. We don't want to refresh the taglist window if we are entering the
" file window from one of the taglist functions. The 'Tlist_Skip_Refresh'
" variable is used to skip the refresh of the taglist window and is set
" and cleared appropriately.
let s:tlist_skip_refresh = v:false

" Tlist_Window_Display_Help()
function! s:Tlist_Window_Display_Help() abort
  if s:tlist_brief_help
    " Add the brief help
    call append(0, '" Press <F1> to display help text')
  else
    " Add the extensive help
    call append(0, '" <enter> : Jump to tag definition')
    call append(1, '" o : Jump to tag definition in new window')
    call append(2, '" p : Preview the tag definition')
    call append(3, '" <space> : Display tag prototype')
    call append(4, '" u : Update tag list')
    call append(5, '" s : Select sort field')
    call append(6, '" d : Remove file from taglist')
    call append(7, '" x : Zoom-out/Zoom-in taglist window')
    call append(8, '" + : Open a fold')
    call append(9, '" - : Close a fold')
    call append(10, '" * : Open all folds')
    call append(11, '" = : Close all folds')
    call append(12, '" [[ : Move to the start of previous file')
    call append(13, '" ]] : Move to the start of next file')
    call append(14, '" q : Close the taglist window')
    call append(15, '" <F1> : Remove help text')
  endif
endfunction

" Tlist_Window_Update_Line_Offsets
" Update the line offsets for tags for files starting from start_idx
" and displayed in the taglist window by the specified offset
function! s:Tlist_Window_Update_Line_Offsets(start_idx, increment, offset) abort
  for f in s:files[a:start_idx : ]
    if f.visible
      " Update the start/end line number only if the file is visible
      if a:increment
        let f.start += a:offset
        let f.end += a:offset
      else
        let f.start -= a:offset
        let f.end -= a:offset
      endif
    endif
  endfor
endfunction

" Tlist_Window_Toggle_Help_Text()
" Toggle taglist plugin help text between the full version and the brief
" version
function! s:Tlist_Window_Toggle_Help_Text() abort
  if g:Tlist_Compact_Format
    " In compact display mode, do not display help
    return
  endif

  " Include the empty line displayed after the help text
  let brief_help_size = 1
  let full_help_size = 16

  setlocal modifiable

  " Set report option to a huge value to prevent informational messages
  " while deleting the lines
  let old_report = &report
  set report=99999

  " Remove the currently highlighted tag. Otherwise, the help text
  " might be highlighted by mistake
  match none

  " Toggle between brief and full help text
  if s:tlist_brief_help
    let s:tlist_brief_help = v:false

    " Remove the previous help
    exe '1,' . brief_help_size . ' delete _'

    " Adjust the start/end line numbers for the files
    call s:Tlist_Window_Update_Line_Offsets(0, v:true, full_help_size - brief_help_size)
  else
    let s:tlist_brief_help = v:true

    " Remove the previous help
    exe '1,' . full_help_size . ' delete _'

    " Adjust the start/end line numbers for the files
    call s:Tlist_Window_Update_Line_Offsets(0, v:false, full_help_size - brief_help_size)
  endif

  call s:Tlist_Window_Display_Help()

  " Restore the report option
  let &report = old_report

  setlocal nomodifiable
endfunction

" Tlist_Warning_Msg()
" Display a message using WarningMsg highlight group
function! s:Tlist_Warning_Msg(msg) abort
  echohl WarningMsg
  echomsg a:msg
  echohl None
endfunction

" Taglist debug support
let s:tlist_debug = v:false

" File for storing the debug messages
let s:tlist_debug_file = ''

" Tlist_Debug_Enable
" Enable logging of taglist debug messages.
function! taglist#Tlist_Debug_Enable(...) abort
  let s:tlist_debug = v:true
  let fname = a:1

  " If a file name is supplied for logging messages, then empty the file
  if fname !=# ''
    let s:tlist_debug_file = fnamemodify(fname, ':p')

    " Empty the log file
    try
      call writefile([], s:tlist_debug_file)
    catch
      " not able to write to the log file
      call s:Tlist_Warning_Msg('Taglist: Failed to create ' . s:tlist_debug_file)
      let s:tlist_debug_file = ''
    endtry
  else
    let s:tlist_msg = []
  endif
endfunction

" Tlist_Debug_Disable
" Disable logging of taglist debug messages.
function! taglist#Tlist_Debug_Disable() abort
  let s:tlist_debug = v:false
  let s:tlist_debug_file = ''
endfunction

" Tlist_Debug_Show
" Display the taglist debug messages in a new window
function! taglist#Tlist_Debug_Show() abort
  if empty(s:tlist_msg)
    call s:Tlist_Warning_Msg('Taglist: No debug messages')
    return
  endif

  " Open a new window to display the taglist debug messages
  new taglist_debug.txt
  " Delete all the lines (if the buffer already exists)
  silent! %delete _
  " Add the messages
  call setline(1, s:tlist_msg)
  " Move the cursor to the first line
  normal! gg
  setlocal nomodified
endfunction

" Tlist_Log_Msg
" Log the supplied debug message along with the time
function! s:Tlist_Log_Msg(msg) abort
  if s:tlist_debug
    if s:tlist_debug_file !=# ''
      call writefile([strftime('%H:%M:%S') . ':' . a:msg], s:tlist_debug_file, 'a')
    else
      " Log the message into a variable
      call add(s:tlist_msg, strftime('%H:%M:%S') . ':' . a:msg)
    endif
  endif
endfunction

" Tlist_Refresh_Filename_To_Index
" Refresh the file name to index map
function! s:Tlist_Refresh_Filename_To_Index() abort
  let s:fname2idx = {}
  for i in range(len(s:files))
    let s:fname2idx[s:files[i].filename] = i
  endfor
endfunction

" Tlist_Get_File_Index()
" Return the index of the specified filename
function! s:Tlist_Get_File_Index(fname) abort
  if s:tlist_file_count == 0 || a:fname ==# ''
    return -1
  endif

  " Lookup the file index
  return get(s:fname2idx, a:fname, -1)
endfunction

" Last returned file index for line number lookup.
" Used to speed up file lookup
let s:tlist_file_lnum_idx_cache = -1

" Tlist_Window_Get_File_Index_By_Linenum()
" Return the index of the filename present in the specified line number
" Line number refers to the line number in the taglist window
function! s:Tlist_Window_Get_File_Index_By_Linenum(lnum) abort
  call s:Tlist_Log_Msg('Tlist_Window_Get_File_Index_By_Linenum (' . a:lnum . ')')

  " First try to see whether the new line number is within the range
  " of the last returned file
  if s:tlist_file_lnum_idx_cache != -1 &&
        \ s:tlist_file_lnum_idx_cache < s:tlist_file_count
    if a:lnum >= s:files[s:tlist_file_lnum_idx_cache].start &&
          \ a:lnum <= s:files[s:tlist_file_lnum_idx_cache].end
      return s:tlist_file_lnum_idx_cache
    endif
  endif

  let fidx = -1

  if g:Tlist_Show_One_File
    " Displaying only one file in the taglist window. Check whether
    " the line is within the tags displayed for that file
    if s:tlist_cur_file_idx != -1
      if a:lnum >= s:files[s:tlist_cur_file_idx].start
            \ && a:lnum <= s:files[s:tlist_cur_file_idx].end
        let fidx = s:tlist_cur_file_idx
      endif
    endif
  else
    " Do a binary search in the taglist
    let left = 0
    let right = s:tlist_file_count - 1

    while left < right
      let mid = (left + right) / 2

      if a:lnum >= s:files[mid].start && a:lnum <= s:files[mid].end
        let s:tlist_file_lnum_idx_cache = mid
        return mid
      endif

      if a:lnum < s:files[mid].start
        let right = mid - 1
      else
        let left = mid + 1
      endif
    endwhile

    if left >= 0 && left < s:tlist_file_count
          \ && a:lnum >= s:files[left].start && a:lnum <= s:files[left].end
      let fidx = left
    endif
  endif

  let s:tlist_file_lnum_idx_cache = fidx

  return fidx
endfunction

" Tlist_Exe_Cmd_No_Acmds
" Execute the specified Ex command after disabling autocommands
function! s:Tlist_Exe_Cmd_No_Acmds(cmd) abort
  let old_eventignore = &eventignore
  set eventignore=all
  exe a:cmd
  let &eventignore = old_eventignore
endfunction

" Tlist_Skip_File()
" Check whether tag listing is supported for the specified file
function! s:Tlist_Skip_File(filename, ftype) abort
  " Skip buffers with no names and buffers with filetype not set
  if a:filename ==# '' || a:ftype ==# ''
    return v:true
  endif

  " Skip files which are not supported by Universal ctags
  " First check whether default settings for this filetype are available.
  " If it is not available, then check whether user specified settings are
  " available. If both are not available, then don't list the tags for this
  " filetype
  if !has_key(s:tlist_lang_def, a:ftype)
    let varname = 'g:tlist_' . a:ftype . '_settings'
    if !exists(varname)
      return v:true
    endif
  endif

  " Skip files which are not readable or files which are not yet stored
  " to the disk
  if !filereadable(a:filename)
    return v:true
  endif

  return v:false
endfunction

" Tlist_User_Removed_File
" Returns 1 if a file is removed by a user from the taglist
function! s:Tlist_User_Removed_File(filename) abort
  return has_key(s:tlist_removed_flist, a:filename)
endfunction

" Tlist_Update_Remove_List
" Update the list of user removed files from the taglist
" add == true, add the file to the removed list
" add == false, delete the file from the removed list
function! s:Tlist_Update_Remove_List(filename, add) abort
  if a:add
    let s:tlist_removed_flist[a:filename] = v:true
  else
    if has_key(s:tlist_removed_flist, a:filename)
      call remove(s:tlist_removed_flist, a:filename)
    endif
  endif
endfunction

" Tlist_FileType_Init
" Initialize the ctags arguments and tag variable for the specified
" file type.
" Returns true if successful, otherwise returns false
function! s:Tlist_FileType_Init(ftype) abort
  call s:Tlist_Log_Msg('Tlist_FileType_Init (' . a:ftype . ')')
  " If the user didn't specify any settings, then use the default
  " ctags args. Otherwise, use the settings specified by the user
  let varname = 'g:tlist_' . a:ftype . '_settings'
  if exists(varname)
    " User specified ctags arguments
    let settings = eval(varname)
  else
    " Default ctags arguments
    if !has_key(s:tlist_lang_def, a:ftype)
      " No default settings for this file type. This filetype is
      " not supported
      return v:false
    endif
    let settings = s:tlist_lang_def[a:ftype]
  endif

  let msg = 'Taglist: Invalid ctags option setting - ' . settings

  " Format of the option that specifies the filetype and ctags arugments:
  "
  "       <language_name>;flag1:name1;flag2:name2;flag3:name3
  "

  " Extract the file type to pass to ctags. This may be different from the
  " file type detected by Vim
  let l = split(settings, ';')
  if len(l) < 2
    call s:Tlist_Warning_Msg(msg)
    return v:false
  endif
  let ctags_ftype = l[0]

  " Make sure a valid filetype is supplied. If the user didn't specify a
  " valid filetype, then the ctags option settings may be treated as the
  " filetype
  if ctags_ftype ==# '' || ctags_ftype =~# ':'
    call s:Tlist_Warning_Msg(msg)
    return v:false
  endif

  " Process all the specified ctags flags. The format is
  " flag1:name1;flag2:name2;flag3:name3
  let ctags_flags = ''
  let tagtypes = {}
  let ordered_ttypes = []

  for setting in l[1:]
    " Extract the flag and the tag type name
    let t = split(setting, ':')
    if len(t) != 2
      call s:Tlist_Warning_Msg(msg)
      return v:false
    endif

    let [flag, name] = t
    let tagtypes[flag] = {'fullname': name}
    call add(ordered_ttypes, flag)
    let ctags_flags .= flag
  endfor

  let s:ftypes[a:ftype] = {}
  let s:ftypes[a:ftype].ctags_args = '--language-force=' . ctags_ftype . ' ' .
        \ '--' . ctags_ftype . '-types=' . ctags_flags
  let s:ftypes[a:ftype].ctags_flags = ctags_flags
  let s:ftypes[a:ftype].tagtypes = tagtypes
  let s:ordered_ttypes[a:ftype] = ordered_ttypes

  return v:true
endfunction

" Tlist_Detect_Filetype
" Determine the filetype for the specified file using the filetypedetect
" autocmd.
function! s:Tlist_Detect_Filetype(fname) abort
  " Ignore the filetype autocommands
  let old_eventignore = &eventignore
  set eventignore=FileType

  " Save the 'filetype', as this will be changed temporarily
  let old_filetype = &filetype

  " Run the filetypedetect group of autocommands to determine
  " the filetype
  exe 'doautocmd filetypedetect BufRead ' . a:fname

  " Save the detected filetype
  let ftype = &filetype

  " Restore the previous state
  let &filetype = old_filetype
  let &eventignore = old_eventignore

  return ftype
endfunction

" Tlist_Get_Buffer_Filetype
" Get the filetype for the specified buffer
function! s:Tlist_Get_Buffer_Filetype(bnum) abort
  let buf_ft = getbufvar(a:bnum, '&filetype')

  " Check whether 'filetype' contains multiple file types separated by '.'
  " If it is, then use the first file type
  if buf_ft =~# '\.'
    let buf_ft = matchstr(buf_ft, '[^.]\+')
  endif

  if bufloaded(a:bnum)
    " For loaded buffers, the 'filetype' is already determined
    return buf_ft
  endif

  " For unloaded buffers, if the 'filetype' option is set, return it
  if buf_ft !=# ''
    return buf_ft
  endif

  " Skip non-existent buffers
  if !bufexists(a:bnum)
    return ''
  endif

  " For buffers whose filetype is not yet determined, try to determine
  " the filetype
  let bname = bufname(a:bnum)

  return s:Tlist_Detect_Filetype(bname)
endfunction

" Tlist_Discard_TagInfo
" Discard the stored tag information for a file
function! s:Tlist_Discard_TagInfo(finfo) abort
  call s:Tlist_Log_Msg('Tlist_Discard_TagInfo (' . a:finfo.filename . ')')
  let ftype = a:finfo.filetype

  " Discard information about the tags defined in the file
  let a:finfo.tags = ['']
  let a:finfo.tag_count = 0

  " Discard information about tag type groups
  call map(a:finfo.tagtypes, "{'offset': 0, 'tags': [], 'tagidxs': [-1]}")

  " Discard the stored menu command also
  let a:finfo.menu_cmd = ''
endfunction

" Tlist_Window_Remove_File_From_Display
" Remove the specified file from display
function! s:Tlist_Window_Remove_File_From_Display(fidx) abort
  let finfo = s:files[a:fidx]
  call s:Tlist_Log_Msg('Tlist_Window_Remove_File_From_Display (' . finfo.filename . ')')
  " If the file is not visible then no need to remove it
  if !finfo.visible
    return
  endif

  " Remove the tags displayed for the specified file from the window
  let start = finfo.start
  " Include the empty line after the last line also
  if g:Tlist_Compact_Format
    let end = finfo.end
  else
    let end = finfo.end + 1
  endif

  setlocal modifiable
  exe 'silent! ' . start . ',' . end . 'delete _'
  setlocal nomodifiable

  " Correct the start and end line offsets for all the files following
  " this file, as the tags for this file are removed
  call s:Tlist_Window_Update_Line_Offsets(a:fidx + 1, v:false, end - start + 1)
endfunction

" Tlist_Remove_File
" Remove the file under the cursor or the specified file index
" user_request - User requested to remove the file from taglist
function! s:Tlist_Remove_File(file_idx, user_request) abort
  let fidx = a:file_idx
  if fidx == -1
    " Invoked by the user to remove a file in the taglist window
    let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(line('.'))
    if fidx == -1
      return
    endif
  endif
  let finfo = s:files[fidx]
  call s:Tlist_Log_Msg('Tlist_Remove_File (' . finfo.filename . ',' . a:user_request. ')')

  let save_winnr = winnr()
  let winnum = bufwinnr(s:TagList_title)
  if winnum != -1
    " Taglist window is open, remove the file from display

    if save_winnr != winnum
      let old_eventignore = &eventignore
      set eventignore=all
      exe winnum . 'wincmd w'
    endif

    call s:Tlist_Window_Remove_File_From_Display(fidx)

    if save_winnr != winnum
      exe save_winnr . 'wincmd w'
      let &eventignore = old_eventignore
    endif
  endif

  let fname = finfo.filename

  if a:user_request
    " As the user requested to remove the file from taglist,
    " add it to the removed list
    call s:Tlist_Update_Remove_List(fname, v:true)
  endif

  if g:Tlist_Show_One_File && s:tlist_cur_file_idx != -1
    " If only one file is displayed in the taglist window, when removing a
    " file from the taglist, the current file index may become invalid.
    " Need to get the correct index after the file list is updated.
    let save_filename = s:files[s:tlist_cur_file_idx].filename
  endif

  " Remove the file information
  call remove(s:files, fidx)

  " Update the filename to index mapping for all the files
  call s:Tlist_Refresh_Filename_To_Index()

  " Reduce the number of files displayed
  let s:tlist_file_count -= 1

  if g:Tlist_Show_One_File
    let s:tlist_cur_file_idx = s:Tlist_Get_File_Index(save_filename)
  endif
endfunction

" Tlist_Window_Goto_Window
" Go to the taglist window
function! s:Tlist_Window_Goto_Window() abort
  let winnum = bufwinnr(s:TagList_title)
  if winnum != -1
    if winnr() != winnum
      call s:Tlist_Exe_Cmd_No_Acmds(winnum . 'wincmd w')
    endif
  endif
endfunction

" Tlist_Window_Init
" Set the default options for the taglist window
function! s:Tlist_Window_Init() abort
  call s:Tlist_Log_Msg('Tlist_Window_Init()')

  " The 'readonly' option should not be set for the taglist buffer.
  " If Vim is started as "view/gview" or if the ":view" command is
  " used, then the 'readonly' option is set for all the buffers.
  " Unset it for the taglist buffer
  setlocal noreadonly

  " Set the taglist buffer filetype to taglist
  setlocal filetype=taglist

  " Define taglist window element highlighting
  syntax match TagListComment '^" .*'
  syntax match TagListFileName '^[^" ].*$'
  syntax match TagListTitle '^  \S.*$'
  syntax match TagListTagScope  '\s\[.\{-\}\]$'

  " Define the highlighting only if colors are supported
  if has('gui_running') || str2nr(&t_Co) > 2
    " Colors to highlight various taglist window elements
    " If user defined highlighting group exists, then use them.
    " Otherwise, use default highlight groups.
    highlight clear TagListTagName
    highlight clear TagListComment
    highlight clear TagListTitle
    highlight clear TagListFileName
    highlight clear TagListTagScope
    if hlexists('MyTagListTagName')
      highlight link TagListTagName MyTagListTagName
    else
      highlight default link TagListTagName Search
    endif
    " Colors to highlight comments and titles
    if hlexists('MyTagListComment')
      highlight link TagListComment MyTagListComment
    else
      highlight clear TagListComment
      highlight default link TagListComment Comment
    endif
    if hlexists('MyTagListTitle')
      highlight link TagListTitle MyTagListTitle
    else
      highlight clear TagListTitle
      highlight default link TagListTitle Title
    endif
    if hlexists('MyTagListFileName')
      highlight link TagListFileName MyTagListFileName
    else
      highlight clear TagListFileName
      highlight default TagListFileName guibg=Grey ctermbg=darkgray guifg=white ctermfg=white
    endif
    if hlexists('MyTagListTagScope')
      highlight link TagListTagScope MyTagListTagScope
    else
      highlight clear TagListTagScope
      highlight default link TagListTagScope Identifier
    endif
  else
    highlight default TagListTagName term=reverse cterm=reverse
  endif

  " Folding related settings
  setlocal foldenable
  setlocal foldminlines=0
  setlocal foldmethod=manual
  setlocal foldlevel=9999
  if g:Tlist_Enable_Fold_Column
    setlocal foldcolumn=3
  else
    setlocal foldcolumn=0
  endif
  setlocal foldtext=v:folddashes.getline(v:foldstart)

  " Mark buffer as scratch
  silent! setlocal buftype=nofile
  silent! setlocal bufhidden=delete
  silent! setlocal noswapfile
  silent! setlocal nobuflisted

  silent! setlocal nowrap

  " If the 'number' option is set in the source window, it will affect the
  " taglist window. So forcefully disable 'number' option for the taglist
  " window
  silent! setlocal nonumber
  silent! setlocal norelativenumber

  " Use fixed height when horizontally split window is used
  if g:Tlist_Use_Horiz_Window
    set winfixheight
  endif
  if !g:Tlist_Use_Horiz_Window
    set winfixwidth
  endif

  " Setup balloon evaluation to display tag prototype
  if has('balloon_eval')
    setlocal balloonexpr=Tlist_Balloon_Expr()
    set ballooneval
  endif

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " Create buffer local mappings for jumping to the tags and sorting the list
  nnoremap <buffer> <silent> <CR> :call <SID>Tlist_Window_Jump_To_Tag('useopen')<CR>
  nnoremap <buffer> <silent> o :call <SID>Tlist_Window_Jump_To_Tag('newwin')<CR>
  nnoremap <buffer> <silent> p :call <SID>Tlist_Window_Jump_To_Tag('preview')<CR>
  nnoremap <buffer> <silent> P :call <SID>Tlist_Window_Jump_To_Tag('prevwin')<CR>
  nnoremap <buffer> <silent> t :call <SID>Tlist_Window_Jump_To_Tag('checktab')<CR>
  nnoremap <buffer> <silent> <C-t> :call <SID>Tlist_Window_Jump_To_Tag('newtab')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>Tlist_Window_Jump_To_Tag('useopen')<CR>
  nnoremap <buffer> <silent> s :call <SID>Tlist_Change_Sort('cmd', 'toggle', '')<CR>
  nnoremap <buffer> <silent> + :silent! foldopen<CR>
  nnoremap <buffer> <silent> - :silent! foldclose<CR>
  nnoremap <buffer> <silent> * :silent! %foldopen!<CR>
  nnoremap <buffer> <silent> = :silent! %foldclose<CR>
  nnoremap <buffer> <silent> <kPlus> :silent! foldopen<CR>
  nnoremap <buffer> <silent> <kMinus> :silent! foldclose<CR>
  nnoremap <buffer> <silent> <kMultiply> :silent! %foldopen!<CR>
  nnoremap <buffer> <silent> <Space> :call <SID>Tlist_Window_Show_Info()<CR>
  nnoremap <buffer> <silent> u :call <SID>Tlist_Window_Update_File()<CR>
  nnoremap <buffer> <silent> d :call <SID>Tlist_Remove_File(-1, 1)<CR>
  nnoremap <buffer> <silent> x :call <SID>Tlist_Window_Zoom()<CR>
  nnoremap <buffer> <silent> [[ :call <SID>Tlist_Window_Move_To_File(-1)<CR>
  nnoremap <buffer> <silent> <BS> :call <SID>Tlist_Window_Move_To_File(-1)<CR>
  nnoremap <buffer> <silent> ]] :call <SID>Tlist_Window_Move_To_File(1)<CR>
  nnoremap <buffer> <silent> <Tab> :call <SID>Tlist_Window_Move_To_File(1)<CR>
  nnoremap <buffer> <silent> <F1> :call <SID>Tlist_Window_Toggle_Help_Text()<CR>
  nnoremap <buffer> <silent> q :close<CR>

  " Insert mode mappings
  inoremap <buffer> <silent> <CR> <C-o>:call <SID>Tlist_Window_Jump_To_Tag('useopen')<CR>
  " Windows needs return
  inoremap <buffer> <silent> <Return> <C-o>:call <SID>Tlist_Window_Jump_To_Tag('useopen')<CR>
  inoremap <buffer> <silent> o <C-o>:call <SID>Tlist_Window_Jump_To_Tag('newwin')<CR>
  inoremap <buffer> <silent> p <C-o>:call <SID>Tlist_Window_Jump_To_Tag('preview')<CR>
  inoremap <buffer> <silent> P <C-o>:call <SID>Tlist_Window_Jump_To_Tag('prevwin')<CR>
  inoremap <buffer> <silent> t <C-o>:call <SID>Tlist_Window_Jump_To_Tag('checktab')<CR>
  inoremap <buffer> <silent> <C-t> <C-o>:call <SID>Tlist_Window_Jump_To_Tag('newtab')<CR>
  inoremap <buffer> <silent> <2-LeftMouse> <C-o>:call <SID>Tlist_Window_Jump_To_Tag('useopen')<CR>
  inoremap <buffer> <silent> s <C-o>:call <SID>Tlist_Change_Sort('cmd', 'toggle', '')<CR>
  inoremap <buffer> <silent> +             <C-o>:silent! foldopen<CR>
  inoremap <buffer> <silent> -             <C-o>:silent! foldclose<CR>
  inoremap <buffer> <silent> *             <C-o>:silent! %foldopen!<CR>
  inoremap <buffer> <silent> =             <C-o>:silent! %foldclose<CR>
  inoremap <buffer> <silent> <kPlus>       <C-o>:silent! foldopen<CR>
  inoremap <buffer> <silent> <kMinus>      <C-o>:silent! foldclose<CR>
  inoremap <buffer> <silent> <kMultiply>   <C-o>:silent! %foldopen!<CR>
  inoremap <buffer> <silent> <Space>       <C-o>:call <SID>Tlist_Window_Show_Info()<CR>
  inoremap <buffer> <silent> u <C-o>:call <SID>Tlist_Window_Update_File()<CR>
  inoremap <buffer> <silent> d    <C-o>:call <SID>Tlist_Remove_File(-1, 1)<CR>
  inoremap <buffer> <silent> x    <C-o>:call <SID>Tlist_Window_Zoom()<CR>
  inoremap <buffer> <silent> [[   <C-o>:call <SID>Tlist_Window_Move_To_File(-1)<CR>
  inoremap <buffer> <silent> <BS> <C-o>:call <SID>Tlist_Window_Move_To_File(-1)<CR>
  inoremap <buffer> <silent> ]]   <C-o>:call <SID>Tlist_Window_Move_To_File(1)<CR>
  inoremap <buffer> <silent> <Tab> <C-o>:call <SID>Tlist_Window_Move_To_File(1)<CR>
  inoremap <buffer> <silent> <F1>  <C-o>:call <SID>Tlist_Window_Toggle_Help_Text()<CR>
  inoremap <buffer> <silent> q    <C-o>:close<CR>

  " Map single left mouse click if the user wants this functionality
  if g:Tlist_Use_SingleClick
    " Contributed by Bindu Wavell
    " attempt to perform single click mapping, it would be much
    " nicer if we could nnoremap <buffer> ... however vim does
    " not fire the <buffer> <leftmouse> when you use the mouse
    " to enter a buffer.
    let clickmap = ':if bufname("%") =~ "__Tag_List__" <bar> ' .
          \ 'call <SID>Tlist_Window_Jump_To_Tag("useopen") ' .
          \ '<bar> endif <CR>'
    if maparg('<leftmouse>', 'n') ==# ''
      " no mapping for leftmouse
      exe ':nnoremap <silent> <leftmouse> <leftmouse>' . clickmap
    else
      " we have a mapping
      let mapcmd = ':nnoremap <silent> <leftmouse> <leftmouse>'
      let mapcmd = mapcmd . substitute(substitute(
            \ maparg('<leftmouse>', 'n'), '|', '<bar>', 'g'),
            \ '\c^<leftmouse>', '', '')
      let mapcmd = mapcmd . clickmap
      exe mapcmd
    endif
  endif

  " Define the taglist autocommands
  augroup TagListWinAutoCmds
    autocmd!
    " Display the tag prototype for the tag under the cursor.
    autocmd CursorHold __Tag_List__ call s:Tlist_Window_Show_Info()
    " Highlight the current tag periodically
    autocmd CursorHold * silent call taglist#Tlist_Window_Highlight_Tag(fnamemodify(bufname('%'), ':p'), line('.'), 1, 0)

    " Adjust the Vim window width when taglist window is closed
    autocmd BufUnload __Tag_List__ call s:Tlist_Post_Close_Cleanup()
    " Close the fold for this buffer when leaving the buffer
    if g:Tlist_File_Fold_Auto_Close
      autocmd BufEnter * silent call s:Tlist_Window_Open_File_Fold(expand('<abuf>'))
    endif
    " Exit Vim itself if only the taglist window is present (optional)
    if g:Tlist_Exit_OnlyWindow
      autocmd BufEnter __Tag_List__ nested call s:Tlist_Window_Exit_Only_Window()
    endif
    if !g:Tlist_Process_File_Always &&
          \ (!has('gui_running') || !g:Tlist_Show_Menu)
      " Auto refresh the taglist window
      autocmd BufEnter * call taglist#Tlist_Refresh()
    endif

    autocmd TabEnter * silent call s:Tlist_Refresh_Folds()
  augroup end

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions
endfunction

" Tlist_Window_Create
" Create a new taglist window. If it is already open, jump to it
function! s:Tlist_Window_Create() abort
  call s:Tlist_Log_Msg('Tlist_Window_Create()')
  " If the window is open, jump to it
  let winnum = bufwinnr(s:TagList_title)
  if winnum != -1
    " Jump to the existing window
    exe winnum . 'wincmd w'
    return
  endif

  " Create a new window. If user prefers a horizontal window, then open
  " a horizontally split window. Otherwise open a vertically split
  " window
  if g:Tlist_Use_Horiz_Window
    " Open a horizontally split window
    let win_dir = 'botright'
    " Horizontal window height
    let win_size = g:Tlist_WinHeight
  else
    if s:tlist_winsize_chgd == -1
      " Open a vertically split window. Increase the window size, if
      " needed, to accommodate the new window
      if g:Tlist_Inc_Winwidth && &columns < (80 + g:Tlist_WinWidth)
        " Save the original window position
        let s:tlist_pre_winx = getwinposx()
        let s:tlist_pre_winy = getwinposy()

        " one extra column is needed to include the vertical split
        let &columns = &columns + g:Tlist_WinWidth + 1

        let s:tlist_winsize_chgd = 1
      else
        let s:tlist_winsize_chgd = 0
      endif
    endif

    if g:Tlist_Use_Right_Window
      " Open the window at the rightmost place
      let win_dir = 'botright vertical'
    else
      " Open the window at the leftmost place
      let win_dir = 'topleft vertical'
    endif
    let win_size = g:Tlist_WinWidth
  endif

  " If the tag listing temporary buffer already exists, then reuse it.
  " Otherwise create a new buffer
  let bufnum = bufnr(s:TagList_title)
  if bufnum == -1
    " Create a new buffer
    let wcmd = s:TagList_title
  else
    " Edit the existing buffer
    let wcmd = '+buffer\ ' . bufnum
  endif

  " Create the taglist window
  " Preserve the alternate file
  exe 'silent! keepalt ' . win_dir . ' ' . win_size . ' split ' . wcmd

  " Save the new window position
  let s:tlist_winx = getwinposx()
  let s:tlist_winy = getwinposy()

  " Initialize the taglist window
  call s:Tlist_Window_Init()
endfunction

" Tlist_Window_Zoom
" Zoom (maximize/minimize) the taglist window
function! s:Tlist_Window_Zoom() abort
  if s:tlist_win_maximized
    " Restore the window back to the previous size
    if g:Tlist_Use_Horiz_Window
      exe 'resize ' . g:Tlist_WinHeight
    else
      exe 'vert resize ' . g:Tlist_WinWidth
    endif
    let s:tlist_win_maximized = v:false
  else
    " Set the window size to the maximum possible without closing other
    " windows
    if g:Tlist_Use_Horiz_Window
      resize
    else
      vert resize
    endif
    let s:tlist_win_maximized = v:true
  endif
endfunction

" Tlist_Window_Get_Tag_Type_By_Linenum()
" Return the tag type index for the specified line in the taglist window
function! s:Tlist_Window_Get_Tag_Type_By_Linenum(finfo, lnum) abort
  let ftype = a:finfo.filetype
  let ttype = ''

  " Determine to which tag type the current line number belongs to using the
  " tag type start line number and the number of tags in a tag type
  for [k, v] in items(a:finfo.tagtypes)
    if v.offset == 0
      " Skip tag types without any tags
      continue
    endif
    let start_lnum = a:finfo.start + v.offset
    let end =  start_lnum + len(v.tagidxs) - 1
    if a:lnum >= start_lnum && a:lnum <= end
      let ttype = k
      break
    endif
  endfor

  return ttype
endfunction

" Tlist_Window_Get_Tag_Index()
" Return the tag index for the specified line in the taglist window
function! s:Tlist_Window_Get_Tag_Index(finfo, lnum) abort
  let ttype = s:Tlist_Window_Get_Tag_Type_By_Linenum(a:finfo, a:lnum)

  " Current line doesn't belong to any of the displayed tag types
  if ttype ==# ''
    return 0
  endif

  let ttinfo = a:finfo.tagtypes[ttype]

  " Compute the index into the displayed tags for the tag type
  let ttype_lnum = a:finfo.start + ttinfo.offset
  let tidx = a:lnum - ttype_lnum
  if tidx == 0
    return 0
  endif

  " Get the corresponding tag line and return it
  return ttinfo.tagidxs[tidx]
endfunction

" Tlist_Get_Tag_Prototype
function! s:Tlist_Get_Tag_Prototype(tag) abort
  " Already parsed and have the tag prototype
  if has_key(a:tag, 'proto')
    return a:tag.proto
  endif

  " Parse and extract the tag prototype
  let tag_line = a:tag.tagline
  let start = stridx(tag_line, '/^') + 2
  let end = stridx(tag_line, '/;"' . "\t")
  if tag_line[end - 1] ==# '$'
    let end -= 1
  endif
  let proto = strpart(tag_line, start, end - start)
  let proto = substitute(proto, '\s*', '', '')
  let a:tag.proto = proto

  return proto
endfunction

" Tlist_Get_Tag_SearchPat
function! s:Tlist_Get_Tag_SearchPat(tag) abort
  " Already parsed and have the tag search pattern
  if has_key(a:tag, 'searchpat')
    return a:tag.searchpat
  endif

  " Parse and extract the tag search pattern
  let tag_line = a:tag.tagline
  let start = stridx(tag_line, '/^') + 2
  let end = stridx(tag_line, '/;"' . "\t")
  if tag_line[end - 1] ==# '$'
    let end -= 1
  endif
  let pat = '\V\^' . strpart(tag_line, start, end - start) .
        \ (tag_line[end] ==# '$' ? '\$' : '')
  let a:tag.searchpat = pat

  return pat
endfunction

" Tlist_Extract_Tagtype
" Extract the tag type from the tag text
function! s:Tlist_Extract_Tagtype(tag_line) abort
  " The tag type is after the tag prototype field. The prototype field
  " ends with the /;"\t string. We add 4 at the end to skip the characters
  " in this special string.
  let start = strridx(a:tag_line, '/;"' . "\t") + 4
  let end = strridx(a:tag_line, 'line:') - 1
  return strpart(a:tag_line, start, end - start)
endfunction

" Tlist_Get_Tag_Type
" Return the tag type for the specified tag
function! s:Tlist_Get_Tag_Type(tag) abort
  " Already parsed and have the tag name
  if has_key(a:tag, 'tagtype')
    return a:tag.tagtype
  endif

  let ttype = s:Tlist_Extract_Tagtype(a:tag.tagline)
  let a:tag.tagtype = ttype

  return ttype
endfunction

" Tlist_Get_Tag_Scope
" Get the scope (e.g. C++ class) of a tag
"
" Tag scope is the last field after the 'line:<num>\t' field
function! s:Tlist_Get_Tag_Scope(tag) abort
  " Already parsed and have the tag scope
  if has_key(a:tag, 'scope')
    return a:tag.scope
  endif

  " Parse and extract the tag scope
  let scope = s:Tlist_Extract_Tag_Scope(a:tag.tagline)
  let a:tag.scope = scope

  return scope
endfunction

" Tlist_Get_Tag_Linenum
" Return the line number of a tag.
" Line number is the field starting with the 'line:' prefix.
function! s:Tlist_Get_Tag_Linenum(tag) abort
  " Already parsed and have the tag line number
  if has_key(a:tag, 'linenum')
    return a:tag.linenum
  endif

  " Parse and extract the tag line number
  let tag_line = a:tag.tagline
  let lnum = 1
  let start = strridx(tag_line, 'line:') + 5
  let end = strridx(tag_line, "\t")
  if end < start
    let lnum = str2nr(strpart(tag_line, start))
  else
    let lnum = str2nr(strpart(tag_line, start, end - start))
  endif

  let a:tag.linenum = lnum

  return lnum
endfunction

" Tlist_Balloon_Expr
" When the mouse cursor is over a tag in the taglist window, display the
" tag prototype (balloon)
function! Tlist_Balloon_Expr() abort
  " Get the file index
  let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(v:beval_lnum)
  if fidx == -1
    return ''
  endif

  let finfo = s:files[fidx]

  " Get the tag output line for the current tag
  let tidx = s:Tlist_Window_Get_Tag_Index(finfo, v:beval_lnum)
  if tidx == 0
    return ''
  endif

  " Get the tag search pattern and display it
  return s:Tlist_Get_Tag_Prototype(finfo.tags[tidx])
endfunction

" Tlist_Exit_Only_Window_Callback
" Timer callback function to exit Vim or to close a tab page if the taglist
" window is the only window present.
function! s:Tlist_Exit_Only_Window_Callback(timer_id)
  " Before quitting Vim, delete the taglist buffer so that the '0 mark is
  " correctly set to the previous buffer.
  if winbufnr(2) == -1 && winbufnr(1) == bufnr(s:TagList_title)
    if tabpagenr('$') == 1
      " Only one tabpage is present.
      "
      " When deleting the taglist buffer, autocommands cannot be disabled. If
      " autocommands are disabled, then on exiting Vim, the window size will
      " not be restored back to the original size.
      bdelete
      quit
    else
      " More than one tab page is present. Close only the current tab page
      close
    endif
  endif
endfunc

" Tlist_Window_Exit_Only_Window
" If the 'Tlist_Exit_OnlyWindow' option is set, then exit Vim if only the
" taglist window is present.
function! s:Tlist_Window_Exit_Only_Window() abort
  " This is called from the BufEnter autocmd.  Closing windows is not allowed
  " from an autocmd event, so start a timer to make the changes.
  call timer_start(0, function('s:Tlist_Exit_Only_Window_Callback'))
endfunction

function! s:Tlist_Menu_Add_Base_Menu() abort
  call s:Tlist_Log_Msg('Adding the base menu')

  " Add the menu
  anoremenu <silent> T&ags.Refresh\ menu :call <SID>Tlist_Menu_Refresh()<CR>
  anoremenu <silent> T&ags.Sort\ menu\ by.Name
        \ :call <SID>Tlist_Change_Sort('menu', 'set', 'name')<CR>
  anoremenu <silent> T&ags.Sort\ menu\ by.Order
        \ :call <SID>Tlist_Change_Sort('menu', 'set', 'order')<CR>
  anoremenu T&ags.-SEP1-           :

  if &mousemodel =~# 'popup'
    anoremenu <silent> PopUp.T&ags.Refresh\ menu
          \ :call <SID>Tlist_Menu_Refresh()<CR>
    anoremenu <silent> PopUp.T&ags.Sort\ menu\ by.Name
          \ :call <SID>Tlist_Change_Sort('menu', 'set', 'name')<CR>
    anoremenu <silent> PopUp.T&ags.Sort\ menu\ by.Order
          \ :call <SID>Tlist_Change_Sort('menu', 'set', 'order')<CR>
    anoremenu PopUp.T&ags.-SEP1-           :
  endif
endfunction

" Tlist_Menu_Remove_File
" Remove the tags displayed in the tags menu
function! s:Tlist_Menu_Remove_File() abort
  if (!has('gui_running') && !exists('g:Tlist_Test')) || s:tlist_menu_empty
    return
  endif

  call s:Tlist_Log_Msg('Removing the tags menu for a file')

  " Cleanup the Tags menu
  silent! unmenu T&ags
  if &mousemodel =~# 'popup'
    silent! unmenu PopUp.T&ags
  endif

  " Add a dummy menu item to retain teared off menu
  noremenu T&ags.Dummy l

  silent! unmenu! T&ags
  if &mousemodel =~# 'popup'
    silent! unmenu! PopUp.T&ags
  endif

  call s:Tlist_Menu_Add_Base_Menu()

  " Remove the dummy menu item
  unmenu T&ags.Dummy

  let s:tlist_menu_empty = v:true
endfunction

" Tlist_Menu_Refresh
" Refresh the taglist menu
function! s:Tlist_Menu_Refresh() abort
  call s:Tlist_Log_Msg('Refreshing the tags menu')
  let fidx = s:Tlist_Get_File_Index(fnamemodify(bufname('%'), ':p'))
  if fidx != -1
    " Invalidate the cached menu command
    let s:files[fidx].menu_cmd = ''
  endif

  " Update the taglist, menu and window
  call taglist#Tlist_Update_Current_File()
endfunction

" Tlist_Menu_Jump_To_Tag
" Jump to the selected tag
function! s:Tlist_Menu_Jump_To_Tag(tidx) abort
  let fidx = s:Tlist_Get_File_Index(fnamemodify(bufname('%'), ':p'))
  if fidx == -1
    return
  endif

  let tagpat = s:Tlist_Get_Tag_SearchPat(s:files[fidx].tags[a:tidx])
  if tagpat ==# ''
    return
  endif

  " Add the current cursor position to the jump list, so that user can
  " jump back using the ' and ` marks.
  mark '

  call search(tagpat, 'w')

  " Bring the line to the middle of the window
  normal! z.

  " If the line is inside a fold, open the fold
  if foldclosed('.') != -1
    .foldopen
  endif
endfunction

" Tlist_Menu_Init
" Initialize the taglist menu
function! taglist#Tlist_Menu_Init() abort
  call s:Tlist_Menu_Add_Base_Menu()

  " Automatically add the tags defined in the current file to the menu
  augroup TagListMenuCmds
    autocmd!

    if !g:Tlist_Process_File_Always
      autocmd BufEnter * call taglist#Tlist_Refresh()
    endif
    autocmd BufLeave * call s:Tlist_Menu_Remove_File()
  augroup end

  call s:Tlist_Menu_Update_File(0)
endfunction

" Tlist_Init_File
" Initialize the variables for a new file
function! s:Tlist_Init_File(filename, ftype) abort
  call s:Tlist_Log_Msg('Tlist_Init_File (' . a:filename . ')')
  " Add new files at the end of the list
  call add(s:files, {})
  let fidx = len(s:files) - 1
  let s:tlist_file_count += 1
  let finfo = s:files[fidx]

  " Add the file name to index mapping
  let s:fname2idx[a:filename] = fidx

  " Initialize the file variables
  call extend(finfo, {'filename': a:filename,
        \  'sort_type': g:Tlist_Sort_Type,
        \  'filetype': a:ftype,
        \  'mtime': -1,
        \  'start': 0,
        \  'end': 0,
        \  'valid': v:false,
        \  'visible': v:false,
        \  'tag_count': 0,
        \  'menu_cmd': '',
        \  'tags': [''],
        \  'tagtypes': {}})

  " Initialize the tag type variables
  let finfo.tagtypes = map(deepcopy(s:ftypes[a:ftype].tagtypes),
        \ "{'offset': 0, 'tags': [], 'tagidxs': [-1]}")

  return fidx
endfunction

" Tlist_Parse_Tagline
" Parse a tag line from the ctags output. Separate the tag output based on the
" tag type and store it in the tag type variable.
" The format of each line in the ctags output is:
"
"     tag_name<TAB>file_name<TAB>ex_cmd;"<TAB>extension_fields
"
function! s:Tlist_Parse_Tagline(ftype, finfo, tag_line) abort
  if a:tag_line ==# ''
    " Skip empty lines
    return ''
  endif

  " Extract the tag type
  let ttype = s:Tlist_Extract_Tagtype(a:tag_line)

  " Make sure the tag type is a valid and supported one
  if ttype ==# '' || stridx(s:ftypes[a:ftype].ctags_flags, ttype) == -1
    " Line is not in proper tags format or tag type is not supported
    return ''
  endif

  let ttinfo = a:finfo.tagtypes[ttype]

  " Store the ctags output for this tag
  call add(a:finfo.tags, {'tagline': a:tag_line})
  let tidx = len(a:finfo.tags) - 1
  let tinfo = a:finfo.tags[-1]

  " Store the tag index and the tag type index (back pointers)
  call add(ttinfo.tagidxs, tidx)
  let ttype_idx = len(ttinfo.tagidxs) - 1
  let tinfo.ttype_idx = ttype_idx

  " Extract the tag name
  let tag_name = strpart(a:tag_line, 0, stridx(a:tag_line, "\t"))

  " Extract the tag scope/prototype
  if g:Tlist_Display_Prototype
    let ttxt = '    ' . s:Tlist_Get_Tag_Prototype(tinfo)
  else
    let ttxt = '    ' . tag_name

    " Add the tag scope, if it is available and is configured. Tag
    " scope is the last field after the 'line:<num>\t' field
    if g:Tlist_Display_Tag_Scope
      let tag_scope = s:Tlist_Get_Tag_Scope(tinfo)
      if tag_scope !=# ''
        let ttxt = ttxt . ' [' . tag_scope . ']'
      endif
    endif
  endif

  " Add this tag to the tag type variable
  call add(ttinfo.tags, ttxt)

  " Save the tag name
  let tinfo.name = tag_name

  return ''
endfunction

" Tlist_Process_File
" Get the list of tags defined in the specified file and store them
" in Vim variables.  Returns the file index where the tags are stored.
function! s:Tlist_Process_File(filename, ftype) abort
  call s:Tlist_Log_Msg('Tlist_Process_File (' . a:filename . ', ' . a:ftype . ')')
  " Check whether this file is supported
  if s:Tlist_Skip_File(a:filename, a:ftype)
    return -1
  endif

  " If the tag types for this filetype are not yet created, then create
  " them now
  if !has_key(s:ftypes, a:ftype)
    if !s:Tlist_FileType_Init(a:ftype)
      return -1
    endif
  endif

  " If this file is already processed, then use the cached values
  let fidx = s:Tlist_Get_File_Index(a:filename)
  if fidx == -1
    " First time, this file is loaded
    let fidx = s:Tlist_Init_File(a:filename, a:ftype)
  else
    " File was previously processed. Discard the tag information
    call s:Tlist_Discard_TagInfo(s:files[fidx])
  endif

  let finfo = s:files[fidx]

  let finfo.valid = v:true

  " Universal ctags arguments to generate a tag list
  let ctags_args = ' -f - --format=2 --excmd=pattern --fields=nks '

  " Form the ctags argument depending on the sort type
  if finfo.sort_type ==# 'name'
    let ctags_args .= '--sort=yes'
  else
    let ctags_args .= '--sort=no'
  endif

  " Add the filetype specific arguments
  let ctags_args .= ' ' . s:ftypes[a:ftype].ctags_args

  " Ctags command to produce output with regexp for locating the tags
  let ctags_cmd = g:Tlist_Ctags_Cmd . ctags_args
  let ctags_cmd .= ' "' . a:filename . '"'

  if has('win32') && !has('win32unix') && (&shell =~# 'cmd.exe')
    " Windows does not correctly deal with commands that have more than one
    " set of double quotes.  It will strip them all resulting in: 'C:\Program'
    " is not recognized as an internal or external command operable program or
    " batch file.  To work around this, place the command inside a batch file
    " and call the batch file.  Do this only on MS-Windows.
    " Contributed by: David Fishburn.
    let taglist_tempfile = fnamemodify(tempname(), ':h') . '\taglist.cmd'
    call writefile([ctags_cmd], taglist_tempfile, 'b')

    call s:Tlist_Log_Msg('Cmd inside batch file: ' . ctags_cmd)
    let ctags_cmd = '"' . taglist_tempfile . '"'
  elseif &shellxquote ==# '"'
    " Double-quotes within double-quotes will not work in the
    " command-line.  If the 'shellxquote' option is set to double-quotes,
    " then escape the double-quotes in the ctags command-line.
    let ctags_cmd = escape(ctags_cmd, '"')
  endif

  call s:Tlist_Log_Msg('Cmd: ' . ctags_cmd)

  " Run ctags and get the tag list
  let cmd_output = system(ctags_cmd)

  if exists('taglist_tempfile')
    " Delete the temporary cmd file created on MS-Windows
    call delete(taglist_tempfile)
  endif

  " Handle errors
  if v:shell_error
    call s:Tlist_Warning_Msg('Taglist: Failed to generate tags for ' . a:filename)
    if cmd_output !=# ''
      call s:Tlist_Warning_Msg(cmd_output)
    endif
    return fidx
  endif

  " Store the modification time for the file
  let finfo.mtime = getftime(a:filename)

  " No tags for current file
  if cmd_output ==# ''
    call s:Tlist_Log_Msg('No tags defined in ' . a:filename)
    return fidx
  endif

  call s:Tlist_Log_Msg('Generated tags information for ' . a:filename)

  " Process the ctags output one line at a time.
  for l in split(cmd_output, "\n")
    call s:Tlist_Parse_Tagline(a:ftype, finfo, l)
  endfor

  " Save the number of tags for this file
  " The first entry in finfo.tags is an empty string. Skip it.
  let finfo.tag_count = len(finfo.tags) - 1

  call s:Tlist_Log_Msg('Processed ' . finfo.tag_count . ' tags in ' . a:filename)

  return fidx
endfunction

" Update the taglist menu with the tags for the specified file
function! s:Tlist_Menu_File_Refresh(finfo) abort
  call s:Tlist_Log_Msg('Refreshing the tag menu for ' . a:finfo.filename)
  " The 'B' flag is needed in the 'cpoptions' option
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  exe a:finfo.menu_cmd

  " Update the popup menu (if enabled)
  if &mousemodel =~# 'popup'
    let cmd = substitute(a:finfo.menu_cmd, ' T\\&ags\.',
          \ ' PopUp.T\\\&ags.', 'g')
    exe cmd
  endif

  " The taglist menu is not empty now
  let s:tlist_menu_empty = v:false

  " Restore the 'cpoptions' settings
  let &cpoptions = old_cpoptions
endfunction

let s:menu_char_prefix =
      \ '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

" Tlist_Menu_Get_Tag_Type_Cmd
" Get the menu command for the specified tag type
" fidx - File type index
" ftype - File Type
" ttype - Tag type
" add_ttype_name - To add or not to add the tag type name to the menu entries
function! s:Tlist_Menu_Get_Tag_Type_Cmd(finfo, ftype, ttype, add_ttype_name) abort
  if a:add_ttype_name
    " If the tag type name contains space characters, escape it. This
    " will be used to create the menu entries.
    let ttype_fullname = escape(s:ftypes[a:ftype].tagtypes[a:ttype].fullname, ' ')
  endif

  " Number of tag entries for this tag type
  let tcnt = len(a:finfo.tagtypes[a:ttype].tagidxs) - 1
  if tcnt == 0              " No entries for this tag type
    return ''
  endif

  let mcmd = ''

  " Create the menu items for the tags.
  " Depending on the number of tags of this type, split the menu into
  " multiple sub-menus, if needed.
  if tcnt > g:Tlist_Max_Submenu_Items
    let j = 1
    while j <= tcnt
      let final_index = j + g:Tlist_Max_Submenu_Items - 1
      if final_index > tcnt
        let final_index = tcnt
      endif

      " Extract the first and last tag name and form the
      " sub-menu name
      let tidx = a:finfo.tagtypes[a:ttype].tagidxs[j]
      let first_tag = a:finfo.tags[tidx].name

      let tidx = a:finfo.tagtypes[a:ttype].tagidxs[final_index]
      let last_tag = a:finfo.tags[tidx].name

      " Truncate the names, if they are greater than the
      " max length
      let first_tag = strpart(first_tag, 0, g:Tlist_Max_Tag_Length)
      let last_tag = strpart(last_tag, 0, g:Tlist_Max_Tag_Length)

      " Form the menu command prefix
      let m_prefix = 'anoremenu <silent> T\&ags.'
      if a:add_ttype_name
        let m_prefix = m_prefix . ttype_fullname . '.'
      endif
      let m_prefix = m_prefix . first_tag . '\.\.\.' . last_tag . '.'

      " Character prefix used to number the menu items (hotkey)
      let m_prefix_idx = 0

      while j <= final_index
        let tidx = a:finfo.tagtypes[a:ttype].tagidxs[j]

        let tname = a:finfo.tags[tidx].name

        let mcmd = mcmd . m_prefix . '\&' .
              \ s:menu_char_prefix[m_prefix_idx] . '\.' .
              \ tname . ' :call <SID>Tlist_Menu_Jump_To_Tag(' .
              \ tidx . ')<CR>|'

        let m_prefix_idx += 1
        let j += 1
      endwhile
    endwhile
  else
    " Character prefix used to number the menu items (hotkey)
    let m_prefix_idx = 0

    let m_prefix = 'anoremenu <silent> T\&ags.'
    if a:add_ttype_name
      let m_prefix = m_prefix . ttype_fullname . '.'
    endif
    for j in range(1, tcnt)
      let tidx = a:finfo.tagtypes[a:ttype].tagidxs[j]

      let tname = a:finfo.tags[tidx].name

      let mcmd = mcmd . m_prefix . '\&' .
            \ s:menu_char_prefix[m_prefix_idx] . '\.' .
            \ tname . ' :call <SID>Tlist_Menu_Jump_To_Tag(' . tidx
            \ . ')<CR>|'

      let m_prefix_idx += 1
    endfor
  endif

  return mcmd
endfunction

" Tlist_Menu_Update_File
" Add the taglist menu
function! s:Tlist_Menu_Update_File(clear_menu) abort
  if !has('gui_running') && !exists('g:Tlist_Test')
    " Not running in GUI mode
    return
  endif

  call s:Tlist_Log_Msg('Updating the tag menu, clear_menu = ' . a:clear_menu)

  " Remove the tags menu
  if a:clear_menu
    call s:Tlist_Menu_Remove_File()
  endif

  " Skip buffers with 'buftype' set to nofile, nowrite, quickfix or help
  if &buftype !=# ''
    return
  endif

  let filename = fnamemodify(bufname('%'), ':p')
  let ftype = s:Tlist_Get_Buffer_Filetype('%')

  " If the file doesn't support tag listing, skip it
  if s:Tlist_Skip_File(filename, ftype)
    return
  endif

  let fidx = s:Tlist_Get_File_Index(filename)
  if fidx == -1 || !s:files[fidx].valid
    " Check whether this file is removed based on user request
    " If it is, then don't display the tags for this file
    if s:Tlist_User_Removed_File(filename)
      return
    endif

    " Process the tags for the file
    let fidx = s:Tlist_Process_File(filename, ftype)
    if fidx == -1
      return
    endif
  endif

  let fname = escape(fnamemodify(bufname('%'), ':t'), '.')
  if fname !=# ''
    exe 'anoremenu T&ags.' . fname . ' <Nop>'
    anoremenu T&ags.-SEP2-           :
    let s:tlist_menu_empty = v:false
  endif

  let finfo = s:files[fidx]

  if !finfo.tag_count
    return
  endif

  if finfo.menu_cmd !=# ''
    " Update the menu with the cached command
    call s:Tlist_Menu_File_Refresh(finfo)
    return
  endif

  " We are going to add entries to the tags menu, so the menu won't be
  " empty
  let s:tlist_menu_empty = v:false

  let cmd = ''

  " Determine whether the tag type name needs to be added to the menu.
  " If more than one type of tag is in a file, then add the tag type name.
  let add_ttype_name = -1
  for ttype in keys(finfo.tagtypes)
    if !empty(finfo.tagtypes[ttype].tags)
      let add_ttype_name += 1
    endif
    if add_ttype_name >= 1
      break
    endif
  endfor

  " Process the tags by the tag type and get the menu command
  for ttype in s:ordered_ttypes[ftype]
    let mcmd = s:Tlist_Menu_Get_Tag_Type_Cmd(finfo, ftype, ttype, add_ttype_name)
    if mcmd !=# ''
      let cmd = cmd . mcmd
    endif
  endfor

  " Cache the menu command for reuse
  let finfo.menu_cmd = cmd

  " Update the menu
  call s:Tlist_Menu_File_Refresh(finfo)
endfunction

" Tlist_Create_Folds_For_File
" Create the folds in the taglist window for the specified file
function! s:Tlist_Create_Folds_For_File(finfo) abort
  let ftype = a:finfo.filetype

  " Create the folds for each tag type in a file
  for ttype in keys(s:ftypes[ftype].tagtypes)
    if len(a:finfo.tagtypes[ttype].tagidxs) > 1
      let s = a:finfo.start + a:finfo.tagtypes[ttype].offset
      let e = s + len(a:finfo.tagtypes[ttype].tagidxs) - 1
      exe s . ',' . e . 'fold'
    endif
  endfor

  exe a:finfo.start . ',' . a:finfo.end . 'fold'
  exe a:finfo.start . ',' . a:finfo.end . 'foldopen!'
endfunction

" Tlist_Window_Refresh_File()
" List the tags defined in the specified file in a Vim window
function! s:Tlist_Window_Refresh_File(filename, ftype) abort
  call s:Tlist_Log_Msg('Tlist_Window_Refresh_File (' . a:filename . ')')
  " First check whether the file already exists
  let fidx = s:Tlist_Get_File_Index(a:filename)
  if fidx != -1
    let file_listed = v:true
  else
    let file_listed = v:false
  endif

  if !file_listed
    " Check whether this file is removed based on user request
    " If it is, then don't display the tags for this file
    if s:Tlist_User_Removed_File(a:filename)
      return
    endif
  endif

  if file_listed && s:files[fidx].visible
    " Check whether the file tags are currently valid
    if s:files[fidx].valid
      " Go to the first line in the file
      call cursor(s:files[fidx].start, 1)

      " If the line is inside a fold, open the fold
      if foldclosed('.') != -1
        exe s:files[fidx].start . ',' . s:files[fidx].end . 'foldopen!'
      endif
      return
    endif

    " Discard and remove the tags for this file from display
    call s:Tlist_Discard_TagInfo(s:files[fidx])
    call s:Tlist_Window_Remove_File_From_Display(fidx)
  endif

  " Process and generate a list of tags defined in the file
  if !file_listed || !s:files[fidx].valid
    let ret_fidx = s:Tlist_Process_File(a:filename, a:ftype)
    if ret_fidx == -1
      return
    endif
    let fidx = ret_fidx
  endif

  " Set report option to a huge value to prevent informational messages
  " while adding lines to the taglist window
  let old_report = &report
  set report=99999

  if g:Tlist_Show_One_File
    " Remove the previous file
    if s:tlist_cur_file_idx != -1
      call s:Tlist_Window_Remove_File_From_Display(s:tlist_cur_file_idx)
      let s:files[s:tlist_cur_file_idx].visible = v:false
      let s:files[s:tlist_cur_file_idx].start = 0
      let s:files[s:tlist_cur_file_idx].end = 0
    endif
    let s:tlist_cur_file_idx = fidx
  endif

  " Mark the buffer as modifiable
  setlocal modifiable

  " Add new files to the end of the window. For existing files, add them at
  " the same line where they were previously present. If the file is not
  " visible, then add it at the end
  if s:files[fidx].start == 0 || !s:files[fidx].visible
    if g:Tlist_Compact_Format
      let s:files[fidx].start = line('$')
    else
      let s:files[fidx].start = line('$') + 1
    endif
  endif

  let s:files[fidx].visible = v:true

  " Go to the line where this file should be placed
  if g:Tlist_Compact_Format
    call cursor(s:files[fidx].start, 1)
  else
    call cursor(s:files[fidx].start - 1, 1)
  endif

  let txt = fnamemodify(s:files[fidx].filename, ':t') . ' (' .
        \ fnamemodify(s:files[fidx].filename, ':p:h') . ')'
  if !g:Tlist_Compact_Format
    silent! put =txt
  else
    silent! put! =txt
    " Move to the next line
    call cursor(line('.') + 1, 1)
  endif
  let file_start = s:files[fidx].start

  " Add the tag names grouped by tag type to the buffer with a title
  for ttype in s:ordered_ttypes[a:ftype]
    let info = s:ftypes[a:ftype].tagtypes[ttype]

    let fidx_ttype = s:files[fidx].tagtypes[ttype]

    " Add the tag type only if there are tags for that type
    if len(fidx_ttype.tagidxs) > 1
      let txt = '  ' . info.fullname

      if !g:Tlist_Compact_Format
        let ttype_start_lnum = line('.') + 1
        silent! put =txt
      else
        let ttype_start_lnum = line('.')
        silent! put! =txt
      endif
      silent! put =fidx_ttype.tags

      let fidx_ttype.offset = ttype_start_lnum - file_start

      " Adjust the cursor position
      if !g:Tlist_Compact_Format
        call cursor(ttype_start_lnum + len(fidx_ttype.tagidxs) - 1, 1)
      else
        call cursor(ttype_start_lnum + len(fidx_ttype.tagidxs), 1)
      endif

      if !g:Tlist_Compact_Format
        " Separate the tag types by a empty line
        silent! put =''
      endif
    endif
  endfor

  if s:files[fidx].tag_count == 0
    if !g:Tlist_Compact_Format
      silent! put =''
    endif
  endif

  let s:files[fidx].end = line('.') - 1

  call s:Tlist_Create_Folds_For_File(s:files[fidx])

  " Go to the starting line for this file,
  call cursor(s:files[fidx].start, 1)

  " Mark the buffer as not modifiable
  setlocal nomodifiable

  " Restore the report option
  let &report = old_report

  " Update the start and end line numbers for all the files following this
  " file
  let start = s:files[fidx].start
  " include the empty line after the last line
  if g:Tlist_Compact_Format
    let end = s:files[fidx].end
  else
    let end = s:files[fidx].end + 1
  endif
  call s:Tlist_Window_Update_Line_Offsets(fidx + 1, v:true, end - start + 1)

  " Now that we have updated the taglist window, update the tags
  " menu (if present)
  if g:Tlist_Show_Menu
    call s:Tlist_Menu_Update_File(1)
  endif
endfunction

" Tlist_Window_Update_File()
" Update the tags displayed in the taglist window
function! s:Tlist_Window_Update_File() abort
  call s:Tlist_Log_Msg('Tlist_Window_Update_File()')
  let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(line('.'))
  if fidx == -1
    return
  endif

  let finfo = s:files[fidx]

  " Remove the previous highlighting
  match none

  " Save the current line for later restoration
  let curline = '\V\^' . escape(getline('.'), "\\") . '\$'

  let finfo.valid = v:false

  " Update the taglist window
  call s:Tlist_Window_Refresh_File(finfo.filename, finfo.filetype)

  exe finfo.start . ',' . finfo.end . 'foldopen!'

  " Go back to the tag line before the list is updated
  call search(curline, 'w')
endfunction

" Tlist_Update_Current_File()
" Update taglist for the current buffer by regenerating the tag list
" Contributed by WEN Guopeng.
function! taglist#Tlist_Update_Current_File() abort
  call s:Tlist_Log_Msg('Tlist_Update_Current_File()')
  if winnr() == bufwinnr(s:TagList_title)
    " In the taglist window. Update the current file
    call s:Tlist_Window_Update_File()
  else
    " Not in the taglist window. Update the current buffer
    let filename = fnamemodify(bufname('%'), ':p')
    let fidx = s:Tlist_Get_File_Index(filename)
    if fidx != -1
      let s:files[fidx].valid = v:false
    endif
    let ft = s:Tlist_Get_Buffer_Filetype('%')
    call taglist#Tlist_Update_File_Tags(filename, ft)
  endif
endfunction

" Tlist_Window_Refresh
" Display the tags for all the files in the taglist window
function! s:Tlist_Window_Refresh() abort
  call s:Tlist_Log_Msg('Tlist_Window_Refresh()')
  " Set report option to a huge value to prevent informational messages
  " while deleting the lines
  let old_report = &report
  set report=99999

  " Mark the buffer as modifiable
  setlocal modifiable

  " Delete the contents of the buffer to the black-hole register
  silent! %delete _

  " As we have cleared the taglist window, mark all the files
  " as not visible
  for f in s:files
    let f.visible = v:false
  endfor

  if !g:Tlist_Compact_Format
    " Display help in non-compact mode
    call s:Tlist_Window_Display_Help()
  endif

  " Mark the buffer as not modifiable
  setlocal nomodifiable

  " Restore the report option
  let &report = old_report

  " If the tags for only one file should be displayed in the taglist
  " window, then no need to add the tags here. The bufenter autocommand
  " will add the tags for that file.
  if g:Tlist_Show_One_File
    return
  endif

  " List all the tags for the previously processed files
  " Do this only if taglist is configured to display tags for more than
  " one file. Otherwise, when Tlist_Show_One_File is configured,
  " tags for the wrong file will be displayed.
  for f in s:files
    call s:Tlist_Window_Refresh_File(f.filename, f.filetype)
  endfor

  if g:Tlist_Auto_Update
    " Add and list the tags for all buffers in the Vim buffer list
    for i in range(1, bufnr('$'))
      if !buflisted(i)
        continue
      endif
      let fname = fnamemodify(bufname(i), ':p')
      let ftype = s:Tlist_Get_Buffer_Filetype(i)
      " If the file doesn't support tag listing, skip it
      if !s:Tlist_Skip_File(fname, ftype)
        call s:Tlist_Window_Refresh_File(fname, ftype)
      endif
    endfor
  endif

  " If Tlist_File_Fold_Auto_Close option is set, then close all the folds
  if g:Tlist_File_Fold_Auto_Close
    " Close all the folds
    silent! %foldclose
  endif

  " Move the cursor to the top of the taglist window
  normal! gg
endfunction

" Tlist_Post_Close_Cleanup()
" Close the taglist window and adjust the Vim window width
function! s:Tlist_Post_Close_Cleanup() abort
  call s:Tlist_Log_Msg('Tlist_Post_Close_Cleanup()')
  " Mark all the files as not visible
  for f in s:files
    let f.visible = v:false
  endfor

  " Remove the taglist autocommands
  augroup TagListWinAutoCmds
    au!
  augroup END
  silent! autocmd! TagListWinAutoCmds

  " Clear all the highlights
  match none

  silent! syntax clear TagListTitle
  silent! syntax clear TagListComment
  silent! syntax clear TagListTagScope

  " Remove the left mouse click mapping if it was setup initially
  if g:Tlist_Use_SingleClick
    if hasmapto('<LeftMouse>')
      nunmap <LeftMouse>
    endif
  endif

  if g:Tlist_Use_Horiz_Window || !g:Tlist_Inc_Winwidth ||
        \ s:tlist_winsize_chgd != 1 ||
        \ &columns < (80 + g:Tlist_WinWidth)
    " No need to adjust window width if using horizontally split taglist
    " window or if columns is less than 101 or if the user chose not to
    " adjust the window width
  else
    " If the user didn't manually move the window, then restore the window
    " position to the pre-taglist position
    if s:tlist_pre_winx != -1 && s:tlist_pre_winy != -1 &&
          \ getwinposx() == s:tlist_winx &&
          \ getwinposy() == s:tlist_winy
      exe 'winpos ' . s:tlist_pre_winx . ' ' . s:tlist_pre_winy
    endif

    " Adjust the Vim window width
    let &columns = &columns - (g:Tlist_WinWidth + 1)
  endif

  let s:tlist_winsize_chgd = -1
endfunction

" Tlist_Update_File
" Update the tags for a file (if needed)
function! taglist#Tlist_Update_File_Tags(filename, ftype) abort
  call s:Tlist_Log_Msg('Tlist_Update_File_Tags (' . a:filename . ')')
  " If the file doesn't support tag listing, skip it
  if s:Tlist_Skip_File(a:filename, a:ftype)
    return
  endif

  " Convert the file name to a full path
  let fname = fnamemodify(a:filename, ':p')

  " First check whether the file already exists
  let fidx = s:Tlist_Get_File_Index(fname)

  if fidx != -1 && s:files[fidx].valid
    " File exists and the tags are valid
    " Check whether the file was modified after the last tags update
    " If it is modified, then update the tags
    if s:files[fidx].mtime == getftime(fname)
      return
    endif
  else
    " If the tags were removed previously based on a user request,
    " as we are going to update the tags (based on the user request),
    " remove the filename from the deleted list
    call s:Tlist_Update_Remove_List(fname, v:false)
  endif

  " If the taglist window is opened, update it
  let winnum = bufwinnr(s:TagList_title)
  if winnum == -1
    " Taglist window is not present. Just update the taglist
    " and return
    call s:Tlist_Process_File(fname, a:ftype)
  else
    if g:Tlist_Show_One_File && s:tlist_cur_file_idx != -1
      " If tags for only one file are displayed and we are not
      " updating the tags for that file, then no need to
      " refresh the taglist window. Otherwise, the taglist
      " window should be updated.
      if s:files[s:tlist_cur_file_idx].filename != fname
        call s:Tlist_Process_File(fname, a:ftype)
        return
      endif
    endif

    " Save the current window number
    let save_winnr = winnr()

    " Go to the taglist window
    call s:Tlist_Window_Goto_Window()

    " Save the cursor position
    let save_line = line('.')
    let save_col = col('.')

    " Update the taglist window
    call s:Tlist_Window_Refresh_File(fname, a:ftype)

    " Restore the cursor position
    call cursor(save_line, save_col)

    if winnr() != save_winnr
      " Go back to the original window
      call s:Tlist_Exe_Cmd_No_Acmds(save_winnr . 'wincmd w')
    endif
  endif

  " Update the taglist menu
  if g:Tlist_Show_Menu
    call s:Tlist_Menu_Update_File(1)
  endif
endfunction

" Tlist_Window_Close
" Close the taglist window
function! taglist#Tlist_Window_Close() abort
  call s:Tlist_Log_Msg('Tlist_Window_Close()')
  " Make sure the taglist window exists
  let winnum = bufwinnr(s:TagList_title)
  if winnum == -1
    call s:Tlist_Warning_Msg('Error: Taglist window is not open')
    return
  endif

  if winnr() == winnum
    " Already in the taglist window. Close it and return
    if winbufnr(2) != -1
      " If a window other than the taglist window is open,
      " then only close the taglist window.
      close
    endif
  else
    " Go to the taglist window, close it and then come back to the
    " original window
    let curbufnr = bufnr('%')
    exe winnum . 'wincmd w'
    close
    " Need to jump back to the original window only if we are not
    " already in that window
    let winnum = bufwinnr(curbufnr)
    if winnr() != winnum
      exe winnum . 'wincmd w'
    endif
  endif
endfunction

" Tlist_Window_Mark_File_Window
" Mark the current window as the file window to use when jumping to a tag.
" Only if the current window is a non-plugin, non-preview and non-taglist
" window
function! s:Tlist_Window_Mark_File_Window() abort
  if getbufvar('%', '&buftype') ==# '' && !&previewwindow
    let w:tlist_file_window = 'yes'
  endif
endfunction

" Tlist_Find_Nearest_Tag_Idx
" Find the tag idx nearest to the supplied line number
" Returns -1, if a tag couldn't be found for the specified line number
function! s:Tlist_Find_Nearest_Tag_Idx(finfo, linenum) abort
  let sort_type = a:finfo.sort_type

  let left = 1
  let right = a:finfo.tag_count

  if sort_type ==# 'order'
    " Tags sorted by order, use a binary search.
    " The idea behind this function is taken from the ctags.vim script (by
    " Alexey Marinichev) available at the Vim online website.

    " If the current line is the less than the first tag, then no need to
    " search
    let first_lnum = s:Tlist_Get_Tag_Linenum(a:finfo.tags[1])

    if a:linenum < first_lnum
      return -1
    endif

    while left < right
      let middle = (right + left + 1) / 2
      let middle_lnum = s:Tlist_Get_Tag_Linenum(a:finfo.tags[middle])

      if middle_lnum == a:linenum
        let left = middle
        break
      endif

      if middle_lnum > a:linenum
        let right = middle - 1
      else
        let left = middle
      endif
    endwhile
  else
    " Tags sorted by name, use a linear search. (contributed by Dave Eggum).
    " Look for a tag with a line number less than or equal to the supplied
    " line number. If multiple tags are found, then use the tag with the line
    " number closest to the supplied line number. IOW, use the tag with the
    " highest line number.
    let closest_lnum = 0
    let final_left = 0
    while left <= right
      let lnum = s:Tlist_Get_Tag_Linenum(a:finfo.tags[left])

      if lnum < a:linenum && lnum > closest_lnum
        let closest_lnum = lnum
        let final_left = left
      elseif lnum == a:linenum
        let closest_lnum = lnum
        let final_left = left
        break
      else
        let left += 1
      endif
    endwhile
    if closest_lnum == 0
      return -1
    endif
    if left >= right
      let left = final_left
    endif
  endif

  return left
endfunction

" Tlist_Window_Highlight_Line
" Highlight the current line
function! s:Tlist_Window_Highlight_Line() abort
  " Clear previously selected name
  match none

  " Highlight the current line
  if !g:Tlist_Display_Prototype
    let pat = '/\%' . line('.') . 'l\s\+\zs.*/'
  else
    let pat = '/\%' . line('.') . 'l.*/'
  endif

  exe 'match TagListTagName ' . pat
endfunction

" Tlist_Window_Highlight_Tag()
" Highlight the current tag
" cntx == 1, Called by the taglist plugin itself
" cntx == 2, Forced by the user through the TlistHighlightTag command
" center = 1, move the tag line to the center of the taglist window
function! taglist#Tlist_Window_Highlight_Tag(filename, cur_lnum, cntx, center) abort
  " Highlight the current tag only if the user configured the
  " taglist plugin to do so or if the user explicitly invoked the
  " command to highlight the current tag.
  if !g:Tlist_Auto_Highlight_Tag && a:cntx == 1
    return
  endif

  if a:filename ==# ''
    return
  endif

  " Make sure the taglist window is present
  let winnum = bufwinnr(s:TagList_title)
  if winnum == -1
    call s:Tlist_Warning_Msg('Error: Taglist window is not open')
    return
  endif

  let fidx = s:Tlist_Get_File_Index(a:filename)
  if fidx == -1
    return
  endif
  let finfo = s:files[fidx]

  " If the file is currently not displayed in the taglist window, then return
  if !finfo.visible
    return
  endif

  " If there are no tags for this file, then no need to proceed further
  if finfo.tag_count == 0
    return
  endif

  " Ignore all autocommands
  let old_ei = &eventignore
  set eventignore=all

  " Save the original window number
  let org_winnr = winnr()

  let in_taglist_window = 0
  if org_winnr == winnum
    let in_taglist_window = 1
  endif

  " Go to the taglist window
  if !in_taglist_window
    exe winnum . 'wincmd w'
  endif

  " Clear previously selected name
  match none

  let tidx = s:Tlist_Find_Nearest_Tag_Idx(finfo, a:cur_lnum)
  if tidx == -1
    " Make sure the current tag line is visible in the taglist window.
    " Calling the winline() function makes the line visible.  Don't know
    " of a better way to achieve this.
    let lnum = line('.')

    if lnum < finfo.start || lnum > finfo.end
      " Move the cursor to the beginning of the file
      call cursor(finfo.start, 1)
    endif

    if foldclosed('.') != -1
      .foldopen
    endif

    call winline()

    if !in_taglist_window
      exe org_winnr . 'wincmd w'
    endif

    " Restore the autocommands
    let &eventignore = old_ei
    return
  endif

  " Extract the tag type
  let ttype = s:Tlist_Get_Tag_Type(finfo.tags[tidx])

  " Compute the line number
  " Start of file + Start of tag type + offset
  let lnum = finfo.start + finfo.tagtypes[ttype].offset +
        \ finfo.tags[tidx].ttype_idx

  " Go to the line containing the tag
  call cursor(lnum, 1)

  " Open the fold
  if foldclosed('.') != -1
    .foldopen
  endif

  if a:center
    " Move the tag line to the center of the taglist window
    normal! z.
  else
    " Make sure the current tag line is visible in the taglist window.
    " Calling the winline() function makes the line visible.  Don't know
    " of a better way to achieve this.
    call winline()
  endif

  " Highlight the tag name
  call s:Tlist_Window_Highlight_Line()

  " Go back to the original window
  if !in_taglist_window
    exe org_winnr . 'wincmd w'
  endif

  " Restore the autocommands
  let &eventignore = old_ei
endfunction

" Tlist_Window_Open
" Open and refresh the taglist window
function! taglist#Tlist_Window_Open() abort
  call s:Tlist_Log_Msg('Tlist_Window_Open()')
  " If the window is open, jump to it
  let winnum = bufwinnr(s:TagList_title)
  if winnum != -1
    " Jump to the existing window
    if winnr() != winnum
      exe winnum . 'wincmd w'
    endif
    return
  endif

  " Get the filename and filetype for the specified buffer
  let curbuf_name = fnamemodify(bufname('%'), ':p')
  let curbuf_ftype = s:Tlist_Get_Buffer_Filetype('%')
  let cur_lnum = line('.')

  " Mark the current window as the desired window to open a file when a tag
  " is selected.
  call s:Tlist_Window_Mark_File_Window()

  let tlist_win_refresh = v:true
  if len(win_findbuf(bufnr(s:TagList_title))) > 0
    let tlist_win_refresh = v:false
  endif

  " Open the taglist window
  call s:Tlist_Window_Create()

  if tlist_win_refresh
    " If the taglist buffer is already present in a taglist window, then don't
    " refresh it again (as it will change the contents of the other window)
    call s:Tlist_Window_Refresh()
  endif

  if g:Tlist_Show_One_File
    " Add only the current buffer and file
    "
    " If the file doesn't support tag listing, skip it
    if !s:Tlist_Skip_File(curbuf_name, curbuf_ftype)
      call s:Tlist_Window_Refresh_File(curbuf_name, curbuf_ftype)
    endif
  endif

  if g:Tlist_File_Fold_Auto_Close
    " Open the fold for the current file, as all the folds in
    " the taglist window are closed
    let fidx = s:Tlist_Get_File_Index(curbuf_name)
    if fidx != -1
      exe s:files[fidx].start . ',' . s:files[fidx].end . 'foldopen!'
    endif
  endif

  " Highlight the current tag
  call taglist#Tlist_Window_Highlight_Tag(curbuf_name, cur_lnum, 1, 1)
endfunction

" Tlist_Window_Toggle()
" Open or close a taglist window
function! taglist#Tlist_Window_Toggle() abort
  call s:Tlist_Log_Msg('Tlist_Window_Toggle()')
  " If taglist window is open then close it.
  let winnum = bufwinnr(s:TagList_title)
  if winnum != -1
    call taglist#Tlist_Window_Close()
    return
  endif

  call taglist#Tlist_Window_Open()

  " Go back to the original window, if Tlist_GainFocus_On_ToggleOpen is not
  " set
  if !g:Tlist_GainFocus_On_ToggleOpen
    call s:Tlist_Exe_Cmd_No_Acmds('wincmd p')
  endif

  " Update the taglist menu
  if g:Tlist_Show_Menu
    call s:Tlist_Menu_Update_File(0)
  endif
endfunction

" Tlist_Process_Filelist
" Process multiple files. Each filename is separated by "\n"
" Returns the number of processed files
function! s:Tlist_Process_Filelist(filenames) abort
  " Enable lazy screen updates
  let old_lazyredraw = &lazyredraw
  set lazyredraw

  " Keep track of the number of processed files
  let fcnt = 0

  " Process one file at a time
  for f in a:filenames
    " Skip directories
    if isdirectory(f)
      continue
    endif

    let ftype = s:Tlist_Detect_Filetype(f)

    " If the file doesn't support tag listing, skip it
    if s:Tlist_Skip_File(f, ftype)
      continue
    endif

    echon "\r                                                              "
    echon "\rProcessing tags for " . fnamemodify(f, ':p:t')

    let fcnt += 1

    call taglist#Tlist_Update_File_Tags(f, ftype)
  endfor

  " Clear the displayed informational messages
  echon "\r                                                            "

  " Restore the previous state
  let &lazyredraw = old_lazyredraw

  return fcnt
endfunction

" Tlist_Process_Dir
" Process the files in a directory matching the specified pattern
function! s:Tlist_Process_Dir(dir_name, pat) abort
  let flist = glob(a:dir_name . a:pat, v:false, v:true)

  let fcnt = s:Tlist_Process_Filelist(flist)

  let len = strlen(a:dir_name)
  if a:dir_name[len - 1] ==# '\' || a:dir_name[len - 1] ==# '/'
    let glob_expr = a:dir_name . '*'
  else
    let glob_expr = a:dir_name . '/*'
  endif
  let all_files = glob(glob_expr, v:false, v:true)

  for f in all_files
    " Skip non-directory names
    if !isdirectory(f)
      continue
    endif

    echon "\r                                                              "
    echon "\rProcessing files in directory " . fnamemodify(f, ':t')
    let fcnt += s:Tlist_Process_Dir(f . '/', a:pat)
  endfor

  return fcnt
endfunction

" Tlist_Add_Files_Recursive
" Add files recursively from a directory
function! taglist#Tlist_Add_Files_Recursive(dir, ...) abort
  if a:0 > 0
    let pat = a:1
  else
    let pat = '*'
  endif

  let dir_name = fnamemodify(a:dir, ':p')
  if !isdirectory(dir_name)
    call s:Tlist_Warning_Msg('Error: ' . dir_name . ' is not a directory')
    return
  endif

  echon "\r                                                              "
  echon "\rProcessing files in directory " . fnamemodify(dir_name, ':t')
  let fcnt = s:Tlist_Process_Dir(dir_name, pat)

  echon "\rAdded " . fcnt . ' files to the taglist'
endfunction

" Tlist_Add_Files
" Add the specified list of files to the taglist
function! taglist#Tlist_Add_Files(...) abort
  let flist_str = ''
  let i = 1
  let filenames = []

  " Get all the files matching the file patterns supplied as argument
  for f in a:000
    call extend(filenames, glob(f, v:false, v:true))
  endfor

  if empty(filenames)
    call s:Tlist_Warning_Msg('Error: No matching files are found')
    return
  endif

  let fcnt = s:Tlist_Process_Filelist(filenames)
  echon "\rAdded " . fcnt . ' files to the taglist'
endfunction

" Tlist_Extract_Tag_Scope
" Extract the tag scope from the tag text
function! s:Tlist_Extract_Tag_Scope(tag_line) abort
  let start = strridx(a:tag_line, 'line:')
  let end = strridx(a:tag_line, "\t")
  if end <= start
    return ''
  endif

  let tag_scope = strpart(a:tag_line, end + 1)
  let tag_scope = strpart(tag_scope, stridx(tag_scope, ':') + 1)

  return tag_scope
endfunction

" Tlist_Refresh()
" Refresh the taglist
function! taglist#Tlist_Refresh() abort
  call s:Tlist_Log_Msg('Tlist_Refresh (Skip_Refresh = ' .
        \ s:tlist_skip_refresh . ', ' . bufname('%') . ')')
  " If we are entering the buffer from one of the taglist functions, then
  " no need to refresh the taglist window again.
  if s:tlist_skip_refresh
    " We still need to update the taglist menu
    if g:Tlist_Show_Menu
      call s:Tlist_Menu_Update_File(0)
    endif
    return
  endif

  " Skip buffers with 'buftype' set to nofile, nowrite, quickfix or help
  if &buftype !=# ''
    return
  endif

  let filename = fnamemodify(bufname('%'), ':p')
  let ftype = s:Tlist_Get_Buffer_Filetype('%')

  " If the file doesn't support tag listing, skip it
  if s:Tlist_Skip_File(filename, ftype)
    return
  endif

  let tlist_win = bufwinnr(s:TagList_title)

  " If the taglist window is not opened and not configured to process
  " tags always and not displaying the tags menu, then return
  if tlist_win == -1 && !g:Tlist_Process_File_Always && !g:Tlist_Show_Menu
    return
  endif

  let fidx = s:Tlist_Get_File_Index(filename)
  if fidx == -1
    " Check whether this file is removed based on user request
    " If it is, then don't display the tags for this file
    if s:Tlist_User_Removed_File(filename)
      return
    endif

    " If the taglist should not be auto updated, then return
    if !g:Tlist_Auto_Update
      return
    endif
  endif

  let cur_lnum = line('.')

  if fidx == -1
    " Update the tags for the file
    let fidx = s:Tlist_Process_File(filename, ftype)
  else
    let mtime = getftime(filename)
    let finfo = s:files[fidx]
    if finfo.mtime != mtime
      " Invalidate the tags listed for this file
      let finfo.valid = v:false

      " Update the taglist and the window
      call taglist#Tlist_Update_File_Tags(filename, ftype)

      " Store the new file modification time
      let finfo.mtime = mtime
    endif
  endif

  " Update the taglist window
  if tlist_win != -1
    " Disable screen updates
    let old_lazyredraw = &lazyredraw
    set nolazyredraw

    " Save the current window number
    let save_winnr = winnr()

    " Go to the taglist window
    call s:Tlist_Window_Goto_Window()

    if !g:Tlist_Auto_Highlight_Tag || !g:Tlist_Highlight_Tag_On_BufEnter
      " Save the cursor position
      let save_line = line('.')
      let save_col = col('.')
    endif

    " Update the taglist window
    call s:Tlist_Window_Refresh_File(filename, ftype)

    " Open the fold for the file
    exe ':' . s:files[fidx].start . ',' . s:files[fidx].end . 'foldopen!'

    if g:Tlist_Highlight_Tag_On_BufEnter && g:Tlist_Auto_Highlight_Tag
      let center_tag_line = 0
      if g:Tlist_Show_One_File && s:tlist_cur_file_idx != fidx
        " If displaying tags for only one file in the taglist
        " window and about to display the tags for a new file,
        " then center the current tag line for the new file
        let center_tag_line = 1
      endif

      " Highlight the current tag
      call taglist#Tlist_Window_Highlight_Tag(filename, cur_lnum, 1, center_tag_line)
    else
      " Restore the cursor position
      call cursor(save_line, save_col)
    endif

    " Jump back to the original window
    if save_winnr != winnr()
      call s:Tlist_Exe_Cmd_No_Acmds(save_winnr . 'wincmd w')
    endif

    " Restore screen updates
    let &lazyredraw = old_lazyredraw
  endif

  " Update the taglist menu
  if g:Tlist_Show_Menu
    call s:Tlist_Menu_Update_File(0)
  endif
endfunction

" Tlist_Change_Sort()
" Change the sort order of the tag listing
" caller == 'cmd', command used in the taglist window
" caller == 'menu', taglist menu
" action == 'toggle', toggle sort from name to order and vice versa
" action == 'set', set the sort order to sort_type
function! s:Tlist_Change_Sort(caller, action, sort_type_arg) abort
  call s:Tlist_Log_Msg('Tlist_Change_Sort (caller = ' . a:caller .
        \ ', action = ' . a:action . ', sort_type = ' . a:sort_type_arg . ')')
  if a:caller ==# 'cmd'
    let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(line('.'))
    if fidx == -1
      return
    endif

    " Remove the previous highlighting
    match none
  elseif a:caller ==# 'menu'
    let fidx = s:Tlist_Get_File_Index(fnamemodify(bufname('%'), ':p'))
    if fidx == -1
      return
    endif
  endif

  let finfo = s:files[fidx]
  if a:action ==# 'toggle'
    let sort_type = finfo.sort_type

    " Toggle the sort order from 'name' to 'order' and vice versa
    if sort_type ==# 'name'
      let finfo.sort_type = 'order'
    else
      let finfo.sort_type = 'name'
    endif
  else
    let finfo.sort_type = a:sort_type_arg
  endif

  " Invalidate the tags listed for this file
  let finfo.valid = v:false

  if a:caller  ==# 'cmd'
    " Save the current line for later restoration
    let curline = '\V\^' . escape(getline('.'), "\\") . '\$'

    call s:Tlist_Window_Refresh_File(finfo.filename, finfo.filetype)

    exe finfo.start . ',' . finfo.end . 'foldopen!'

    " Go back to the cursor line before the tag list is sorted
    call search(curline, 'w')

    call s:Tlist_Menu_Update_File(1)
  else
    call s:Tlist_Menu_Remove_File()

    call taglist#Tlist_Refresh()
  endif
endfunction

" Tlist_Window_Open_File
" Open the specified file in either a new window or an existing window
" and place the cursor at the specified tag pattern
function! s:Tlist_Window_Open_File(win_ctrl, filename, tagpat) abort
  call s:Tlist_Log_Msg('Tlist_Window_Open_File (' . a:filename . ', ' . a:win_ctrl . ')')
  let save_tlist_skip_refresh = s:tlist_skip_refresh
  let s:tlist_skip_refresh = v:true

  if a:win_ctrl ==# 'newtab'
    " Create a new tab
    exe 'tabnew ' . escape(a:filename, ' ')
    " Open the taglist window in the new tab
    call taglist#Tlist_Window_Open()
  endif

  if a:win_ctrl ==# 'checktab'
    " Check whether the file is present in any of the tabs.
    " If the file is present in the current tab, then use the
    " current tab.
    let file_present_in_tab = 0
    if bufwinnr(a:filename) != -1
      let file_present_in_tab = 1
      let i = tabpagenr()
    else
      let bnum = bufnr(a:filename)
      let file_present_in_tab = 0
      for i in range(1, tabpagenr('$'))
        if index(tabpagebuflist(i), bnum) != -1
          let file_present_in_tab = 1
          break
        endif
      endfor
    endif

    if file_present_in_tab
      " Go to the tab containing the file
      exe 'tabnext ' . i
    else
      " Open a new tab
      exe 'tabnew ' . escape(a:filename, ' ')

      " Open the taglist window
      call taglist#Tlist_Window_Open()
    endif
  endif

  let winnum = -1
  if a:win_ctrl ==# 'prevwin'
    " Open the file in the previous window, if it is usable
    let cur_win = winnr()
    wincmd p
    if &buftype ==# '' && !&previewwindow
      exe 'edit ' . escape(a:filename, ' ')
      let winnum = winnr()
    else
      " Previous window is not usable
      exe cur_win . 'wincmd w'
    endif
  endif

  " Go to the window containing the file.  If the window is not there, open a
  " new window
  if winnum == -1
    let winnum = bufwinnr(a:filename)
  endif

  if winnum == -1
    " Locate the previously used window for opening a file
    let fwin_num = 0
    let first_usable_win = 0

    for wnum in range(1, winnr('$'))
      let bnum = winbufnr(wnum)
      if getwinvar(wnum, 'tlist_file_window') ==# 'yes'
        let fwin_num = wnum
        break
      endif
      if first_usable_win == 0 &&
            \ getbufvar(bnum, '&buftype') ==# '' &&
            \ !getwinvar(wnum, '&previewwindow')
        " First non-taglist, non-plugin and non-preview window
        let first_usable_win = wnum
      endif
    endfor

    " If a previously used window is not found, then use the first
    " non-taglist window
    if fwin_num == 0
      let fwin_num = first_usable_win
    endif

    if fwin_num != 0
      " Jump to the file window
      exe fwin_num . 'wincmd w'

      " If the user asked to jump to the tag in a new window, then split
      " the existing window into two.
      if a:win_ctrl ==# 'newwin'
        split
      endif
      exe 'edit ' . escape(a:filename, ' ')
    else
      " Open a new window
      if g:Tlist_Use_Horiz_Window
        exe 'keepalt leftabove split ' . escape(a:filename, ' ')
      else
        if winbufnr(2) == -1
          " Only the taglist window is present
          if g:Tlist_Use_Right_Window
            exe 'keepalt leftabove vertical split ' .
                  \ escape(a:filename, ' ')
          else
            exe 'keepalt rightbelow vertical split ' .
                  \ escape(a:filename, ' ')
          endif

          " Go to the taglist window to change the window size to
          " the user configured value
          call s:Tlist_Exe_Cmd_No_Acmds('wincmd p')
          if g:Tlist_Use_Horiz_Window
            exe 'resize ' . g:Tlist_WinHeight
          else
            exe 'vertical resize ' . g:Tlist_WinWidth
          endif
          " Go back to the file window
          call s:Tlist_Exe_Cmd_No_Acmds('wincmd p')
        else
          " A plugin or help window is also present
          wincmd w
          exe 'keepalt leftabove split ' . escape(a:filename, ' ')
        endif
      endif
    endif
    " Mark the window, so that it can be reused.
    call s:Tlist_Window_Mark_File_Window()
  else
    " If the file is opened in more than one window, then check
    " whether the last accessed window has the selected file.
    " If it does, then use that window.
    let lastwin_bufnum = winbufnr(winnr('#'))
    if bufnr(a:filename) == lastwin_bufnum
      let winnum = winnr('#')
    endif
    exe winnum . 'wincmd w'

    " If the user asked to jump to the tag in a new window, then split the
    " existing window into two.
    if a:win_ctrl ==# 'newwin'
      split
    endif
  endif

  " Jump to the tag
  if a:tagpat !=# ''
    " Add the current cursor position to the jump list, so that user can
    " jump back using the ' and ` marks.
    mark '
    silent call search(a:tagpat, 'w')

    " Bring the line to the middle of the window
    normal! z.

    " If the line is inside a fold, open the fold
    if foldclosed('.') != -1
      .foldopen
    endif
  endif

  " If the user selects to preview the tag then jump back to the
  " taglist window
  if a:win_ctrl ==# 'preview'
    " Go back to the taglist window
    let winnum = bufwinnr(s:TagList_title)
    exe winnum . 'wincmd w'
  else
    " If the user has selected to close the taglist window, when a
    " tag is selected, close the taglist  window
    if g:Tlist_Close_On_Select
      call s:Tlist_Window_Goto_Window()
      close

      " Go back to the window displaying the selected file
      let wnum = bufwinnr(a:filename)
      if wnum != -1 && wnum != winnr()
        call s:Tlist_Exe_Cmd_No_Acmds(wnum . 'wincmd w')
      endif
    endif
  endif

  let s:tlist_skip_refresh = save_tlist_skip_refresh
endfunction

" Tlist_Window_Jump_To_Tag()
" Jump to the location of the current tag
" win_ctrl == useopen - Reuse the existing file window
" win_ctrl == newwin - Open a new window
" win_ctrl == preview - Preview the tag
" win_ctrl == prevwin - Open in previous window
" win_ctrl == newtab - Open in new tab
function! s:Tlist_Window_Jump_To_Tag(win_ctrl) abort
  call s:Tlist_Log_Msg('Tlist_Window_Jump_To_Tag(' . a:win_ctrl . ')')
  " Do not process comment lines and empty lines
  let curline = getline('.')
  if curline =~# '^\s*$' || curline[0] ==# '"'
    return
  endif

  " If inside a closed fold, then use the first line of the fold
  " and jump to the file.
  let lnum = foldclosed('.')
  if lnum == -1
    " Jump to the selected tag or file
    let lnum = line('.')
  else
    " Open the closed fold
    .foldopen!
  endif

  let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(lnum)
  if fidx == -1
    return
  endif
  let finfo = s:files[fidx]

  " Get the tag output for the current tag
  let tidx = s:Tlist_Window_Get_Tag_Index(finfo, lnum)
  if tidx != 0
    let tagpat = s:Tlist_Get_Tag_SearchPat(finfo.tags[tidx])

    " Highlight the tagline
    call s:Tlist_Window_Highlight_Line()
  else
    " Selected a line which is not a tag name. Just edit the file
    let tagpat = ''
  endif

  call s:Tlist_Window_Open_File(a:win_ctrl, finfo.filename, tagpat)
endfunction

" Tlist_Window_Show_Info()
" Display information about the entry under the cursor
function! s:Tlist_Window_Show_Info() abort
  call s:Tlist_Log_Msg('Tlist_Window_Show_Info()')

  " Clear the previously displayed line
  echo

  " Do not process comment lines and empty lines
  let curline = getline('.')
  if curline =~# '^\s*$' || curline[0] ==# '"'
    return
  endif

  " If inside a fold, then don't display the prototype
  if foldclosed('.') != -1
    return
  endif

  let lnum = line('.')

  " Get the file index
  let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(lnum)
  if fidx == -1
    return
  endif

  let finfo = s:files[fidx]

  if lnum == finfo.start
    " Cursor is on a file name
    let fname = finfo.filename
    if strlen(fname) > 50
      let fname = fnamemodify(fname, ':t')
    endif
    echo fname . ', Filetype=' . finfo.filetype . ', Tag count=' . finfo.tag_count
    return
  endif

  " Get the tag output line for the current tag
  let tidx = s:Tlist_Window_Get_Tag_Index(finfo, lnum)
  if tidx == 0
    " Cursor is on a tag type
    let ttype = s:Tlist_Window_Get_Tag_Type_By_Linenum(finfo, lnum)
    if ttype ==# ''
      return
    endif

    let ttype_name = s:ftypes[finfo.filetype].tagtypes[ttype].fullname

    echo 'Tag type=' . ttype_name . ', Tag count=' . (len(finfo.tagtypes[ttype].tagidxs) - 1)
    return
  endif

  " Get the tag search pattern and display it
  let proto = s:Tlist_Get_Tag_Prototype(finfo.tags[tidx])
  echo strpart(proto, 0, &columns - 1)
endfunction

" Tlist_Jump_Highlight_Tag()
" Update the highlighted tag, called from Tlist_Jump_Next_Tag() &
" Tlist_Jump_Prev_Tag(). It is a lighter version of
" Tlist_Window_Highlight_Tag() because we don't need to recalculate the tag
" index. Instead it is passed as an argument
" Contributed by Mansour Alharthi
function! s:Tlist_Jump_Highlight_Tag(finfo, tidx) abort
  " Dont highlight if the user dont want to
  if !g:Tlist_Auto_Highlight_Tag
    return
  endif

  " Make sure the taglist window is present
  let winnum = bufwinnr(s:TagList_title)
  if winnum == -1
    return
  endif

  " If the file is currently not displayed in the taglist window, then return
  if !a:finfo.visible
    return
  endif

  " If there are no tags for this file, then no need to proceed further
  if a:finfo.tag_count == 0
    return
  endif

  " Ignore all autocommands
  let old_ei = &eventignore
  set eventignore=all

  " Save the original window number
  let org_winnr = winnr()

  let in_taglist_window = 0
  if org_winnr == winnum
    let in_taglist_window = 1
  endif

  " Go to the taglist window
  if !in_taglist_window
    exe winnum . 'wincmd w'
  endif

  " Clear previously selected name
  match none

  if a:tidx == -1
    " Make sure the current tag line is visible in the taglist window.
    " Calling the winline() function makes the line visible.  Don't know
    " of a better way to achieve this.
    let lnum = line('.')

    if lnum < a:finfo.start || lnum > a:finfo.end
      " Move the cursor to the beginning of the file
      call cursor(a:finfo.start, 1)
    endif

    if foldclosed('.') != -1
      .foldopen
    endif

    call winline()

    if !in_taglist_window
      exe org_winnr . 'wincmd w'
    endif

    " Restore the autocommands
    let &eventignore = old_ei
    return
  endif

  " Extract the tag type
  let ttype = s:Tlist_Get_Tag_Type(a:finfo.tags[a:tidx])

  " Compute the line number
  " Start of file + Start of tag type + offset
  let lnum = a:finfo.start + a:finfo.tagtypes[ttype].offset +
                \ a:finfo.tags[a:tidx].ttype_idx

  " Go to the line containing the tag
  call cursor(lnum, 1)

  " Open the fold
  if foldclosed('.') != -1
    .foldopen
  endif

  " Make sure the current tag line is visible in the taglist window.
  " Calling the winline() function makes the line visible.  Don't know
  " of a better way to achieve this.
  call winline()

  " Highlight the tag name
  call s:Tlist_Window_Highlight_Line()

  " Go back to the original window
  if !in_taglist_window
    exe org_winnr . 'wincmd w'
  endif

  " Restore the autocommands
  let &eventignore = old_ei
endfunction

" Tlist_Jump_Prev_Tag()
" Jumps to the previous of the current tag.
" Contributed by Mansour Alharthi
function! taglist#Tlist_Jump_Prev_Tag() abort
  let fidx = s:Tlist_Get_File_Index(fnamemodify(bufname('%'), ':p'))
  " File was not supported probably, just jump to line#1
  " No tags in the file, jump to line#1
  if fidx == -1 || s:files[fidx].tag_count == 0
    call cursor(1, 1)
    return
  endif

  let finfo = s:files[fidx]

  let lnum = line('.')

  " We are before the first tag, jump to line#1, remove hi
  let tidx = s:Tlist_Find_Nearest_Tag_Idx(finfo, lnum)
  if tidx == -1
    call cursor(1, 1)
    call s:Tlist_Jump_Highlight_Tag(finfo, -1)
    return
  endif

  " Jump to the top of the current tag if below, update hi, don't middle
  " screen
  let clnum = s:Tlist_Get_Tag_Linenum(finfo.tags[tidx])
  if clnum < lnum
    call cursor(clnum, 1)
    call s:Tlist_Jump_Highlight_Tag(finfo, tidx)
    return
  endif

  " No tag before, jump to line#1, remove hi
  let ptidx = tidx - 1
  if ptidx < 1
    call cursor(1, 1)
    call s:Tlist_Jump_Highlight_Tag(finfo, -1)
    return
  endif

  " There is a tag before, go there!, update hi, middle screen
  let plnum = s:Tlist_Get_Tag_Linenum(finfo.tags[ptidx])
  call cursor(plnum, 1)
  call s:Tlist_Jump_Highlight_Tag(finfo, ptidx)
  normal! z.
endfunction

" Tlist_Jump_Next_Tag()
" Jumps to the Next of the current tag.
" Contributed by Mansour Alharthi
function! taglist#Tlist_Jump_Next_Tag() abort
  let fidx = s:Tlist_Get_File_Index(fnamemodify(bufname('%'), ':p'))
  " File was not supported probably, just jump to bottom
  " No tags in the file, jump to bottom
  if fidx == -1 || s:files[fidx].tag_count == 0
    call cursor(line('$'), 1)
    return
  endif
  let finfo = s:files[fidx]

  " We are before the first tag, jump to the first tag, update hi, middle
  " screen
  let lnum = line('.')
  let flnum = s:Tlist_Get_Tag_Linenum(finfo.tags[1])
  if flnum > lnum
    call cursor(flnum, 1)
    call s:Tlist_Jump_Highlight_Tag(finfo, 1)
    normal! z.
    return
  endif

  " I suppose this would never equal -1; we are after the first tag so first
  " tag will be returned at least, but here is check for that
  let tidx = s:Tlist_Find_Nearest_Tag_Idx(finfo, lnum)
  if tidx == -1
    call s:Tlist_Jump_Highlight_Tag(finfo, -1)
    return
  endif

  " No tag after, jump to bottom, update hi, don't middle screen
  let ntidx = tidx + 1
  if ntidx > finfo.tag_count
    call cursor(line('$'), 1)
    call s:Tlist_Jump_Highlight_Tag(finfo, tidx)
    return
  endif

  " Jump to next tag, update hi, middle screen
  let nlnum = s:Tlist_Get_Tag_Linenum(finfo.tags[ntidx])
  call s:Tlist_Jump_Highlight_Tag(finfo, ntidx)
  call cursor(nlnum, 1)
  normal! z.
endfunction

" Tlist_Get_Tag_Prototype_By_Line
" Get the prototype for the tag on or before the specified line number in the
" current buffer
function! taglist#Tlist_Get_Tag_Prototype_By_Line(...) abort
  if a:0 == 0
    " Arguments are not supplied. Use the current buffer name
    " and line number
    let filename = bufname('%')
    let linenr = line('.')
  elseif a:0 == 2
    " Filename and line number are specified
    let filename = a:1
    let linenr = str2nr(a:2)
  else
    " Sufficient arguments are not supplied
    let msg =  'Usage: Tlist_Get_Tag_Prototype_By_Line <filename> ' .
          \ '<line_number>'
    call s:Tlist_Warning_Msg(msg)
    return ''
  endif

  " Expand the file to a fully qualified name
  let filename = fnamemodify(filename, ':p')
  if filename ==# ''
    return ''
  endif

  let fidx = s:Tlist_Get_File_Index(filename)
  if fidx == -1
    return ''
  endif

  let finfo = s:files[fidx]

  " If there are no tags for this file, then no need to proceed further
  if finfo.tag_count == 0
    return ''
  endif

  " Get the tag text using the line number
  let tidx = s:Tlist_Find_Nearest_Tag_Idx(finfo, linenr)
  if tidx == -1
    return ''
  endif

  return s:Tlist_Get_Tag_Prototype(finfo.tags[tidx])
endfunction

" Tlist_Get_Tagname_By_Line
" Get the tag name on or before the specified line number in the
" current buffer
function! taglist#Tlist_Get_Tagname_By_Line(...) abort
  if a:0 == 0
    " Arguments are not supplied. Use the current buffer name
    " and line number
    let filename = bufname('%')
    let linenr = line('.')
  elseif a:0 == 2
    " Filename and line number are specified
    let filename = a:1
    let linenr = str2nr(a:2)
  else
    " Sufficient arguments are not supplied
    let msg =  'Usage: Tlist_Get_Tagname_By_Line <filename> <line_number>'
    call s:Tlist_Warning_Msg(msg)
    return ''
  endif

  " Make sure the current file has a name
  let filename = fnamemodify(filename, ':p')
  if filename ==# ''
    return ''
  endif

  let fidx = s:Tlist_Get_File_Index(filename)
  if fidx == -1
    return ''
  endif

  let finfo = s:files[fidx]

  " If there are no tags for this file, then no need to proceed further
  if finfo.tag_count == 0
    return ''
  endif

  " Get the tag name using the line number
  let tidx = s:Tlist_Find_Nearest_Tag_Idx(finfo, linenr)
  if tidx == -1
    return ''
  endif

  let name = finfo.tags[tidx].name

  if g:Tlist_Display_Tag_Scope
    " Add the scope of the tag
    let tag_scope = finfo.tags[tidx].scope
    if tag_scope !=# ''
      let name = name . ' [' . tag_scope . ']'
    endif
  endif

  return name
endfunction

" Tlist_Get_Filenames
" Return the list of file names in the taglist. The names are returns in a
" List.
function! g:Tlist_Get_Filenames() abort
  let l = []
  for f in s:files
    call add(l, f.filename)
  endfor
  return l
endfunction

" Tlist_Window_Move_To_File
" Move the cursor to the beginning of the current file or the next file
" or the previous file in the taglist window
" dir == -1, move to start of current or previous function
" dir == 1, move to start of next function
function! s:Tlist_Window_Move_To_File(dir) abort
  if foldlevel('.') == 0
    " Cursor is on a non-folded line (it is not in any of the files)
    " Move it to a folded line
    if a:dir == -1
      normal! zk
    else
      " While moving down to the start of the next fold,
      " no need to do go to the start of the next file.
      normal! zj
      return
    endif
  endif

  let fidx = s:Tlist_Window_Get_File_Index_By_Linenum(line('.'))
  if fidx == -1
    return
  endif

  let finfo = s:files[fidx]

  let cur_lnum = line('.')

  if a:dir == -1
    if cur_lnum > finfo.start
      " Move to the beginning of the current file
      call cursor(finfo.start, 1)
      return
    endif

    if fidx >= 1
      " Move to the beginning of the previous file
      let fidx -= 1
    else
      " Cursor is at the first file, wrap around to the last file
      let fidx = s:tlist_file_count - 1
    endif

    call cursor(s:files[fidx].start, 1)
    return
  else
    " Move to the beginning of the next file
    let fidx += 1

    if fidx >= s:tlist_file_count
      " Cursor is at the last file, wrap around to the first file
      let fidx = 0
    endif

    let finfo = s:files[fidx]
    if finfo.start != 0
      call cursor(finfo.start, 1)
    endif
    return
  endif
endfunction

" Tlist_Session_Load
" Load a taglist session (information about all the displayed files
" and the tags) from the specified file
function! taglist#Tlist_Session_Load(sessionfile) abort
  if a:sessionfile ==# ''
    call s:Tlist_Warning_Msg('Usage: TlistSessionLoad <filename>')
    return
  endif

  if !filereadable(a:sessionfile)
    let msg = 'Taglist: Error - Unable to open file ' . a:sessionfile
    call s:Tlist_Warning_Msg(msg)
    return
  endif

  " Mark the current window as the file window
  call s:Tlist_Window_Mark_File_Window()

  let l = readfile(a:sessionfile)
  if len(l) < 3
    call s:Tlist_Warning_Msg('Taglist: Error - Corrupted session file ' . a:sessionfile)
    return
  endif

  let newtags = json_decode(l[2])
  for f in newtags
    if !has_key(s:ftypes, f.filetype)
      if !s:Tlist_FileType_Init(f.filetype)
        continue
      endif
    endif

    let fidx = s:Tlist_Get_File_Index(f.filename)
    if fidx != -1
      " This file is already present in the taglist
      let s:files[fidx].visible = v:false
      continue
    endif

    " As we are loading the tags from the session file, if this
    " file was previously deleted by the user, now we need to
    " add it back. So remove the file from the deleted list.
    call s:Tlist_Update_Remove_List(f.filename, v:false)

    let fidx = s:Tlist_Init_File(f.filename, f.filetype)
    let finfo = s:files[fidx]
    let finfo.mtime = getftime(f.filename)
    let finfo.valid = v:true
    let finfo.tagtypes = deepcopy(f.tagtypes)
    let finfo.tags = deepcopy(f.tags)
    let finfo.tag_count = len(finfo.tags) - 1
  endfor

  call s:Tlist_Refresh_Filename_To_Index()
  let s:tlist_file_count = len(s:files)

  " If the taglist window is open, then update it
  let winnum = bufwinnr(s:TagList_title)
  if winnum != -1
    let save_winnr = winnr()

    " Go to the taglist window
    call s:Tlist_Window_Goto_Window()

    " Refresh the taglist window
    call s:Tlist_Window_Refresh()

    " Go back to the original window
    if save_winnr != winnr()
      call s:Tlist_Exe_Cmd_No_Acmds('wincmd p')
    endif
  endif
endfunction

" Tlist_Session_Save
" Save a taglist session (information about all the displayed files
" and the tags) into the specified file
function! taglist#Tlist_Session_Save(sessionfile) abort
  if a:sessionfile ==# ''
    call s:Tlist_Warning_Msg('Usage: TlistSessionSave <filename>')
    return
  endif

  if s:tlist_file_count == 0
    " There is nothing to save
    call s:Tlist_Warning_Msg('Warning: Taglist is empty. Nothing to save.')
    return
  endif

  if filereadable(a:sessionfile)
    let ans = input('Do you want to overwrite ' . a:sessionfile . ' (y/n)?')
    if ans !=? 'y'
      return
    endif

    echo "\n"
  endif

  let l = []

  call add(l, '# Taglist session file.  This file is auto-generated.')
  call add(l, '# File information')
  call add(l, json_encode(s:files))

  call writefile(l, a:sessionfile)
endfunction

" Tlist_Buffer_Removed
" A buffer is removed from the Vim buffer list. Remove the tags defined
" for that file
function! s:Tlist_Buffer_Removed(filename) abort
  call s:Tlist_Log_Msg('Tlist_Buffer_Removed (' . a:filename . ')')

  " Make sure a valid filename is supplied
  if a:filename ==# ''
    return
  endif

  " Get tag list index of the specified file
  let fidx = s:Tlist_Get_File_Index(a:filename)
  if fidx == -1
    " File not present in the taglist
    return
  endif

  " Remove the file from the list
  call s:Tlist_Remove_File(fidx, 0)
endfunction

" Tlist_Window_Open_File_Fold
" Open the fold for the specified file and close the fold for all the
" other files
function! s:Tlist_Window_Open_File_Fold(acmd_bufnr) abort
  call s:Tlist_Log_Msg('Tlist_Window_Open_File_Fold (' . a:acmd_bufnr . ')')

  " Make sure the taglist window is present
  let winnum = bufwinnr(s:TagList_title)
  if winnum == -1
    return
  endif

  " Save the original window number
  let org_winnr = winnr()
  let in_taglist_window = 0
  if org_winnr == winnum
    let in_taglist_window = 1
  endif

  if in_taglist_window
    " When entering the taglist window, no need to update the folds
    return
  endif

  " Go to the taglist window
  if !in_taglist_window
    call s:Tlist_Exe_Cmd_No_Acmds(winnum . 'wincmd w')
  endif

  " Close all the folds
  silent! %foldclose

  " Get tag list index of the specified file
  let fname = fnamemodify(bufname(str2nr(a:acmd_bufnr)), ':p')
  if filereadable(fname)
    let fidx = s:Tlist_Get_File_Index(fname)
    if fidx != -1
      " Open the fold for the file
      exe s:files[fidx].start . ',' . s:files[fidx].end . 'foldopen!'
    endif
  endif

  " Go back to the original window
  if !in_taglist_window
    call s:Tlist_Exe_Cmd_No_Acmds(org_winnr . 'wincmd w')
  endif
endfunction

" Tlist_Window_Check_Auto_Open
" Open the taglist window automatically on Vim startup.
" Open the window only when files present in any of the Vim windows support
" tags.
function! taglist#Tlist_Window_Check_Auto_Open() abort
  let open_window = 0

  for bufnum in range(1, winbufnr('$'))
    let filename = fnamemodify(bufname(bufnum), ':p')
    let ft = s:Tlist_Get_Buffer_Filetype(bufnum)
    if !s:Tlist_Skip_File(filename, ft)
      let open_window = 1
      break
    endif
  endfor

  if open_window
    call taglist#Tlist_Window_Toggle()
  endif
endfunction

" Tlist_Refresh_Folds
" Remove and create the folds for all the files displayed in the taglist
" window. Used after entering a tab. If this is not done, then the folds
" are not properly created for taglist windows displayed in multiple tabs.
function! s:Tlist_Refresh_Folds() abort
  let winnum = bufwinnr(s:TagList_title)
  if winnum == -1
    return
  endif

  let save_winnum = winnr()
  exe winnum . 'wincmd w'

  " First remove all the existing folds
  normal! zE

  if g:Tlist_Show_One_File
    " If only one file is displayed in the taglist window, then there
    " is no need to refresh the folds for the tags as the tags for the
    " current file will be removed anyway.
  else
    " Create the folds for each file in the tag list
    for fidx in range(s:tlist_file_count)
      call s:Tlist_Create_Folds_For_File(s:files[fidx])
    endfor
  endif

  exe save_winnum . 'wincmd w'
endfunction

" Tlist_Vim_Session_Load
" Initialize the taglist window/buffer, which is created when loading
" a Vim session file.
function! s:Tlist_Vim_Session_Load() abort
  call s:Tlist_Log_Msg('Tlist_Vim_Session_Load')

  " Initialize the taglist window
  call s:Tlist_Window_Init()

  " Refresh the taglist window
  call s:Tlist_Window_Refresh()
endfunction

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: shiftwidth=2 sts=2 expandtab
