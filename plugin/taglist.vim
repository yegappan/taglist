" File: taglist.vim
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Version: 6.0
" Last Modified: July 27, 2022
" Copyright: Copyright (C) 2002-2022 Yegappan Lakshmanan
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            taglist.vim is provided *as is* and comes with no warranty of any
"            kind, either expressed or implied. In no event will the copyright
"            holder be liable for any damamges resulting from the use of this
"            software.
"
" The "Tag List" plugin is a source code browser plugin for Vim and provides
" an overview of the structure of the programming language files and allows
" you to efficiently browse through source code files for different
" programming languages.
"
" The github page for this plugin is at
"
"       https://github.com/yegappan/taglist
"
" You can visit the taglist plugin home page for more information:
"
"       http://vim-taglist.sourceforge.net
"
" For more information about using this plugin, after installing the
" taglist plugin, use the ":help taglist" command.
"
" Installation
" ------------
" 1. Download the taglist.zip file and unzip the files to the $HOME/.vim
"    or the $HOME/vimfiles or the $VIM/vimfiles directory. This should
"    unzip the following two files (the directory structure should be
"    preserved):
"
"       plugin/taglist.vim - main taglist plugin file
"       doc/taglist.txt    - documentation (help) file
"
"    Refer to the 'add-plugin', 'add-global-plugin' and 'runtimepath'
"    Vim help pages for more details about installing Vim plugins.
" 2. Change to the $HOME/.vim/doc or $HOME/vimfiles/doc or
"    $VIM/vimfiles/doc directory, start Vim and run the ":helptags ."
"    command to process the taglist help file.
" 3. If the exuberant ctags utility is not present in your PATH, then set the
"    Tlist_Ctags_Cmd variable to point to the location of the exuberant ctags
"    utility (not to the directory) in the .vimrc file.
" 4. If you are running a terminal/console version of Vim and the
"    terminal doesn't support changing the window width then set the
"    'Tlist_Inc_Winwidth' variable to 0 in the .vimrc file.
" 5. Restart Vim.
" 6. You can now use the ":TlistToggle" command to open/close the taglist
"    window. You can use the ":help taglist" command to get more
"    information about using the taglist plugin.

" Need atleast Vim version 7.4 and above.
if v:version < 704 || exists('g:loaded_taglist')
  finish
endif

" Line continuation used here
if !exists('s:cpo_save')
  " If the taglist plugin is sourced recursively, the 'cpo' setting will be
  " set to the default value.  To avoid this problem, save the cpo setting
  " only when the plugin is loaded for the first time.
  let s:cpo_save = &cpo
endif
set cpo&vim

" The taglist plugin requires the built-in Vim system() function. If this
" function is not available, then don't load the plugin.
if !exists('*system')
  echomsg 'Taglist: Vim system() built-in function is not available. ' .
        \ 'Plugin is not loaded.'
  let loaded_taglist = 'no'
  let &cpo = s:cpo_save
  finish
endif

" Location of the exuberant ctags tool
if !exists('g:Tlist_Ctags_Cmd')
  if executable('exuberant-ctags')
    " On Debian Linux, exuberant ctags is installed as exuberant-ctags
    let g:Tlist_Ctags_Cmd = 'exuberant-ctags'
  elseif executable('exctags')
    " On Free-BSD, exuberant ctags is installed as exctags
    let g:Tlist_Ctags_Cmd = 'exctags'
  elseif executable('ctags')
    let g:Tlist_Ctags_Cmd = 'ctags'
  elseif executable('ctags.exe')
    let g:Tlist_Ctags_Cmd = 'ctags.exe'
  elseif executable('tags')
    let g:Tlist_Ctags_Cmd = 'tags'
  else
    echomsg 'Taglist: Exuberant ctags (http://ctags.sf.net) ' .
          \ 'not found in PATH. Plugin is not loaded.'
    " Skip loading the plugin
    let loaded_taglist = 'no'
    let &cpo = s:cpo_save
    finish
  endif
endif

" Automatically open the taglist window on Vim startup
if !exists('g:Tlist_Auto_Open')
  let g:Tlist_Auto_Open = 0
endif

if !exists('g:Tlist_Show_Menu')
  let g:Tlist_Show_Menu = 0
endif

" Process files even when the taglist window is not open
if !exists('g:Tlist_Process_File_Always')
  let g:Tlist_Process_File_Always = 0
endif

" Define the taglist autocommand to automatically open the taglist window
" on Vim startup
augroup TaglistAutoCmds
  au!
  if g:Tlist_Auto_Open
    autocmd VimEnter * ++nested call taglist#Tlist_Window_Check_Auto_Open()
  endif

  " Refresh the taglist
  if g:Tlist_Process_File_Always
    autocmd BufEnter * call taglist#Tlist_Refresh()
  endif

  if g:Tlist_Show_Menu
    autocmd GUIEnter * call taglist#Tlist_Menu_Init()
  endif
augroup END

" Define the user commands to manage the taglist window
command! -nargs=0 -bar TlistToggle call taglist#Tlist_Window_Toggle()
command! -nargs=0 -bar TlistOpen call taglist#Tlist_Window_Open()
" For backwards compatiblity define the Tlist command
command! -nargs=0 -bar Tlist TlistToggle
command! -nargs=+ -complete=file TlistAddFiles
      \  call taglist#Tlist_Add_Files(<f-args>)
command! -nargs=+ -complete=dir TlistAddFilesRecursive
      \ call taglist#Tlist_Add_Files_Recursive(<f-args>)
command! -nargs=0 -bar TlistClose call taglist#Tlist_Window_Close()
command! -nargs=0 -bar TlistUpdate call taglist#Tlist_Update_Current_File()
command! -nargs=0 -bar TlistHighlightTag
      \ call taglist#Tlist_Window_Highlight_Tag(
      \ fnamemodify(bufname('%'), ':p'), line('.'), 2, 1)
" For backwards compatiblity define the TlistSync command
command! -nargs=0 -bar TlistSync TlistHighlightTag
command! -nargs=* -complete=buffer TlistShowPrototype
      \ echo taglist#Tlist_Get_Tag_Prototype_By_Line(<f-args>)
command! -nargs=* -complete=buffer TlistShowTag
      \ echo taglist#Tlist_Get_Tagname_By_Line(<f-args>)
command! -nargs=* -complete=file TlistSessionLoad
      \ call taglist#Tlist_Session_Load(<q-args>)
command! -nargs=* -complete=file TlistSessionSave
      \ call taglist#Tlist_Session_Save(<q-args>)
command! -bar TlistLock let g:Tlist_Auto_Update = v:false
command! -bar TlistUnlock let g:Tlist_Auto_Update = v:true

" Commands for enabling/disabling debug and to display debug messages
command! -nargs=? -complete=file -bar TlistDebug
      \ call taglist#Tlist_Debug_Enable(<q-args>)
command! -nargs=0 -bar TlistUndebug  call taglist#Tlist_Debug_Disable()
command! -nargs=0 -bar TlistMessages call taglist#Tlist_Debug_Show()

nnoremap <silent> <plug>(TlistJumpTagUp)    :<C-u>call taglist#Tlist_Jump_Prev_Tag()<CR>
nnoremap <silent> <plug>(TlistJumpTagDown)  :<C-u>call taglist#Tlist_Jump_Next_Tag()<CR>

if g:Tlist_Show_Menu && (has('gui_running') || g:Tlist_Test)
  call taglist#Tlist_Menu_Init()
endif

" Taglist plugin functionality is available
let loaded_taglist = 'available'

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: shiftwidth=2 sts=2 expandtab
