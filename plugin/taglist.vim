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

" Need atleast Vim version 7.4.1304 and above.
if v:version < 704 || !has('patch-7.4.1304') || exists('g:loaded_taglist')
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

" Define the taglist autocommand to automatically open the taglist window
" on Vim startup
augroup TaglistAutoCmds
  au!
  if exists('g:Tlist_Auto_Open') && g:Tlist_Auto_Open
    autocmd VimEnter * nested call taglist#Tlist_Window_Check_Auto_Open()
  endif

  " Refresh the taglist
  if exists('g:Tlist_Process_File_Always') && g:Tlist_Process_File_Always
    autocmd BufEnter * call taglist#Tlist_Refresh()
  endif

  if exists('g:Tlist_Show_Menu') && g:Tlist_Show_Menu
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

if exists('g:Tlist_Show_Menu') && g:Tlist_Show_Menu
      \ && (has('gui_running') || exists('g:Tlist_Test'))
  call taglist#Tlist_Menu_Init()
endif

" Taglist plugin functionality is available
let loaded_taglist = 'available'

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: shiftwidth=2 sts=2 expandtab
