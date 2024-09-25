" Unit tests for the Taglist plugin

if has('win32') && !executable('ctags.exe')
  echomsg "Error: ctags.exe is not found"
  finish
endif

syntax on
filetype on
filetype plugin on
set nohidden
" for popup menu testing, set 'mousemodel'
set mousemodel=popup

" Set the $TAGLIST_PROFILE environment variable to profile the taglist plugin
let do_profile = v:false
if exists('$TAGLIST_PROFILE')
  echomsg "Profiling is enabled"
  let do_profile = v:true
endif

if do_profile
  " profile the taglist plugin
  profile start taglist_profile.txt
  profile! file */taglist/*
endif

let g:Tlist_Show_Menu=1
let g:Tlist_Test=1
set rtp+=..
source ../plugin/taglist.vim

let s:save_cpo = &cpo
set cpo&vim

" Test for opening and closing a vertically split left taglist window
func Test_left_vert_tlist_window()
  Tlist
  call assert_equal(2, winnr('$'))
  call assert_equal('__Tag_List__', bufname(winbufnr(1)))
  call assert_equal(g:Tlist_WinWidth, winwidth(1))
  call assert_equal(['" Press <F1> to display help text', ''],
	\ getbufline(winbufnr(1), 1, '$'))
  call assert_equal(2, winnr())
  TlistClose
  call assert_equal(1, winnr('$'))
endfunc

" Test for opening and closing a vertically split right taglist window
func Test_right_vert_tlist_window()
  let g:Tlist_Use_Right_Window=1
  Tlist
  call assert_equal(2, winnr('$'))
  call assert_equal('__Tag_List__', bufname(winbufnr(2)))
  call assert_equal(g:Tlist_WinWidth, winwidth(2))
  call assert_equal(['" Press <F1> to display help text', ''],
	\ getbufline(winbufnr(2), 1, '$'))
  call assert_equal(1, winnr())
  TlistClose
  call assert_equal(1, winnr('$'))
  let g:Tlist_Use_Right_Window=0
endfunc

" Test for opening and closing a horizontally split taglist window
func Test_horz_tlist_window()
  let g:Tlist_Use_Horiz_Window=1
  Tlist
  call assert_equal(2, winnr('$'))
  call assert_equal('__Tag_List__', bufname(winbufnr(2)))
  call assert_equal(g:Tlist_WinHeight, winheight(2))
  call assert_equal(['" Press <F1> to display help text', ''],
	\ getbufline(winbufnr(2), 1, '$'))
  call assert_equal(1, winnr())
  TlistClose
  call assert_equal(1, winnr('$'))
  let g:Tlist_Use_Horiz_Window=0
endfunc

" Test for listing tags in a file
func Test_list_tags()
  edit Xtest1.c
  Tlist
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[2])
  let expected = [
	\   'Xtest1.c',
	\   '  function',
	\   '    xyz',
	\   '    abc',
	\   ''
	\ ]
  call assert_equal(expected[1:], r[3:])
  TlistClose
  bw!
endfunc

" Test for highlighting the current tag
func Test_tag_highlight()
  edit Xtest1.c
  Tlist
  call cursor(9, 1)
  TlistHighlightTag
  1wincmd w
  let m = getmatches()
  call assert_equal('\%6l\s\+\zs.*', m[0].pattern)
  2wincmd w
  call cursor(1, 1)
  TlistHighlightTag
  1wincmd w
  let m = getmatches()
  call assert_equal([], m)
  TlistClose
  redir => info
    TlistHighlightTag
  redir END
  call assert_equal('Error: Taglist window is not open', split(info, "\n")[0])
  bw!
endfunc

" Test for the CursorHold autocmd to highlight the current tag
func Test_CursorHold_tag_highlight()
  edit Xtest1.c
  Tlist
  call cursor(9, 1)
  redir => info
    doautocmd TagListWinAutoCmds CursorHold
  redir END
  1wincmd w
  let m = getmatches()
  call assert_equal('\%6l\s\+\zs.*', m[0].pattern)
  TlistClose
  bw!
endfunc

" Test for getting the current tag name and prototype
func Test_current_tag_show()
  edit Xtest1.c
  Tlist

  call cursor(9, 1)
  redir => l
     TlistShowTag
  redir END
  let l = split(l, "\n")
  call assert_equal(['abc'], l)

  redir => l
     TlistShowPrototype
  redir END
  let l = split(l, "\n")
  call assert_equal(['void abc()'], l)

  call cursor(1, 1)
  redir => l
     TlistShowTag
  redir END
  let l = split(l, "\n")
  call assert_equal([], l)

  redir => l
     TlistShowPrototype
  redir END
  let l = split(l, "\n")
  call assert_equal([], l)

  redir => l
     TlistShowTag Xtest1.c 9
  redir END
  let l = split(l, "\n")
  call assert_equal(['abc'], l)

  redir => l
     TlistShowTag Xtest1.c 1
  redir END
  let l = split(l, "\n")
  call assert_equal([], l)

  redir => l
     TlistShowTag Xtest2.c 10
  redir END
  let l = split(l, "\n")
  call assert_equal([], l)

  redir => l
     TlistShowPrototype Xtest1.c 9
  redir END
  let l = split(l, "\n")
  call assert_equal(['void abc()'], l)

  redir => l
     TlistShowPrototype Xtest1.c 1
  redir END
  let l = split(l, "\n")
  call assert_equal([], l)

  redir => l
     TlistShowPrototype Xtest2.c 10
  redir END
  call assert_equal([], split(l, "\n"))

  " file with no tags
  call writefile([], 'Xfile3.py')
  edit Xfile3.py
  redir => l
     TlistShowTag
  redir END
  call assert_equal([], split(l, "\n"))
  redir => l
     TlistShowPrototype
  redir END
  call assert_equal([], split(l, "\n"))

  " tag with a scope
  let l = [
	\  'class Car():',
	\  '  def __init__(self):',
	\  '    pass'
	\ ]
  call setline(1, l)
  write
  TlistUpdate
  call cursor(3, 1)
  redir => l
     TlistShowTag
  redir END
  call assert_equal(['__init__ [Car]'], split(l, "\n"))

  " invalid number of arguments
  redir => l
     TlistShowTag Xtest2.c
  redir END
  let l = split(l, "\n")
  call assert_equal(['Usage: Tlist_Get_Tagname_By_Line <filename> <line_number>'], l)

  redir => l
     TlistShowPrototype Xtest2.c
  redir END
  call assert_equal(['Usage: Tlist_Get_Tag_Prototype_By_Line <filename> <line_number>'], split(l, "\n"))
  TlistClose
  bw!
  call delete('Xfile3.py')
endfunc

" Test for showing information about current tag in the taglist window
func Test_tlist_window_show_info()
  edit Xtest1.c
  Tlist
  1wincmd w
  call cursor(3, 1)
  redir => info
    call feedkeys("\<Space>", 'xt')
  redir END
  call assert_match('.*Xtest1.c, Filetype=c, Tag count=2', split(info, "\n")[0])
  call cursor(4, 1)
  redir => info
    call feedkeys("\<Space>", 'xt')
  redir END
  call assert_equal(['Tag type=function, Tag count=2'], split(info, "\n"))
  call cursor(6, 1)
  redir => info
    call feedkeys("\<Space>", 'xt')
  redir END
  call assert_equal(['void abc()'], split(info, "\n"))
  call cursor(7, 1)
  redir => info
    call feedkeys("\<Space>", 'xt')
  redir END
  call assert_equal([], split(info, "\n"))
  TlistClose
  bw!
endfunc

" Test for the CursorHold autocmd in the taglist window
func Test_tlist_window_CursorHold_autocmd()
  edit Xtest1.c
  Tlist
  1wincmd w
  call cursor(4, 1)
  redir => info
    doautocmd TagListWinAutoCmds CursorHold
  redir END
  call assert_equal(['Tag type=function, Tag count=2'], split(info, "\n"))
  TlistClose
  bw!
endfunc

" Test for jumping to a tag from the taglist window
func Test_tlist_window_jump_to_tag()
  edit Xtest1.c
  Tlist
  1wincmd w
  " select a function name in the taglist window
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(3, line('.'))
  " select another function name in the taglist window
  1wincmd w
  call cursor(6, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(7, line('.'))
  " select a file name in the taglist window
  call cursor(6, 1)
  1wincmd w
  call cursor(3, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(6, line('.'))
  TlistClose
  bw!
endfunc

" Test for Tlist_Compact_Format
func Test_tlist_window_compact_format()
  edit Xtest1.c
  let g:Tlist_Compact_Format=1
  Tlist
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[0])
  let expected = [
	\  'Xtest1.c',
	\  '  function',
	\  '    xyz',
	\  '    abc',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[1:])
  TlistClose
  bw!
  let g:Tlist_Compact_Format=0
endfunc

" Test for showing two files in the taglist window
func Test_tlist_window_two_files()
  %bw!
  Tlist
  edit Xtest1.c
  edit Xtest2.vim
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[2])
  call assert_match('Xtest2.vim (.*)', r[7])
  let expected = [
	\   'Xtest1.c',
	\   '  function',
	\   '    xyz',
	\   '    abc',
	\   ''
	\ ]
  call assert_equal(expected[1:], r[3:6])
  let expected = [
	\  'Xtest2.vim',
	\  '  variable',
	\  '    s:State',
	\  '',
	\  '  function',
	\  '    Func1',
	\  '    Func2',
	\ ''
	\ ]
  call assert_equal(expected[1:], r[8:])

  TlistClose
  %bw!
endfunc

" Test for the folds in the taglist window
func Test_tlist_window_fold()
  %bw!
  Tlist
  edit Xtest1.c
  edit Xtest2.vim

  " check the folds in the taglist window
  1wincmd w

  call assert_equal([0, 0, 1, 2, 2, 2, 0, 1, 2, 2, 1, 2, 2, 2, 0],
	\ map(range(1, line('$')), "foldlevel(v:val)"))

  TlistClose
  %bw!
endfunc

" Test for jumping to the next/previous tags
func Test_tlist_jump_next_prev_tag()
  %bw!
  Tlist
  edit Xtest1.c
  nmap [t <plug>(TlistJumpTagUp)
  nmap ]t <plug>(TlistJumpTagDown)

  call cursor(1, 1)
  normal ]t
  call assert_equal(3, line('.'))
  normal ]t
  call assert_equal(7, line('.'))
  normal ]t
  call assert_equal(10, line('.'))
  normal [t
  call assert_equal(7, line('.'))
  normal [t
  call assert_equal(3, line('.'))
  normal [t
  call assert_equal(1, line('.'))
  call cursor(2, 1)
  normal [t
  call assert_equal(1, line('.'))

  " if there are no tags in a file, should jump to the start and end of the
  " file.
  enew
  call setline(1, ['one', 'two', 'three'])
  call cursor(2, 1)
  normal [t
  call assert_equal(1, line('.'))
  call cursor(2, 1)
  normal ]t
  call assert_equal(3, line('.'))

  nunmap [t
  nunmap ]t
  TlistClose
  %bw!
endfunc

" Test for jumping to the tags in different files
func Test_jump_to_tags_in_files()
  %bw!
  edit Xtest1.c
  Tlist
  edit Xtest2.vim
  enew
  1wincmd w
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(3, line('.'))
  1wincmd w
  call cursor(14, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest2.vim', bufname(''))
  call assert_equal(7, line('.'))
  TlistClose
  %bw!
endfunc

" Test for adding and removing tags from a file.
func Test_modify_tags_in_file()
  %bw!
  let g:Tlist_Compact_Format=1

  " empty buffer
  edit Xtest3.c
  write
  Tlist
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest3.c (.*)', r[0])
  call assert_equal([''], r[1:])

  " Add some tags
  let l = [
	\  '#include <stdio.h>',
	\  '',
	\  'int crawl()',
	\  '{',
	\  '    return 0;',
	\  '}',
	\  '',
	\  'int walk()',
	\  '{',
	\  '    return 0;',
	\  '}',
	\  '',
	\  'int run()',
	\  '{',
	\  '    return 0;',
	\  '}'
	\ ]
  call setline(1, l)
  update
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  let l = [
	\  'Xtest3.c',
	\  '  function',
	\  '    crawl',
	\  '    walk',
	\  '    run',
	\  ''
	\ ]
  call assert_equal(l[1:], r[1:])

  " delete some tags
  8,12delete _
  update
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  let l = [
	\  'Xtest3.c',
	\  '  function',
	\  '    crawl',
	\  '    run',
	\  ''
	\ ]
  call assert_equal(l[1:], r[1:])

  " jump to a tag
  1wincmd w
  call cursor(4, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest3.c', bufname(''))
  call assert_equal(8, line('.'))

  " delete all the contents
  %delete _
  update
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_equal([''], r[1:])

  TlistClose
  call delete('Xtest3.c')
  %bw!
  let g:Tlist_Compact_Format=0
endfunc

" Test for deleting a file in the taglist window.
func Test_tlist_window_delete_file()
  %bw!
  edit Xtest1.c
  Tlist
  edit Xtest2.vim
  enew
  1wincmd w
  call cursor(1, 1)
  normal d
  call cursor(3, 1)
  normal d
  let l = [
	\  'Xtest2.vim',
	\  '  variable',
	\  '    s:State',
	\  '',
	\  '  function',
	\  '    Func1',
	\  '    Func2',
	\  ''
	\ ]
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_equal(l[1:], r[3:])

  " jump to a tag in the other file
  1wincmd w
  call cursor(8, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest2.vim', bufname(''))
  call assert_equal(3, line('.'))

  " editing the deleted file again should not add it to the taglist
  edit Xtest1.c
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_equal(l[1:], r[3:])

  " manually updating the taglist should add the file back
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  let l = [
	\  'Xtest1.c',
	\  '  function',
	\  '    xyz',
	\  '    abc',
	\  ''
	\ ]
  call assert_equal(l[1:], r[11:])

  TlistClose
  %bw!
endfunc

" Test for jumping to the next/previous files in the taglist window
func Test_tlist_window_jump_next_prev()
  edit Xtest1.c
  Tlist
  edit Xtest2.vim
  enew
  1wincmd w
  call cursor(1, 1)
  normal ]]
  call assert_equal(3, line('.'))
  normal ]]
  call assert_equal(8, line('.'))
  normal ]]
  call assert_equal(3, line('.'))
  normal [[
  call assert_equal(8, line('.'))
  normal [[
  call assert_equal(3, line('.'))
  call cursor(11, 1)
  normal [[
  call assert_equal(8, line('.'))
  call cursor(11, 1)
  normal ]]
  call assert_equal(3, line('.'))
  TlistClose
  %bw!
endfunc

" Test for opening the folds in the taglist window when opening a file
func Test_tlist_window_open_fold()
  edit Xtest1.c
  Tlist
  edit Xtest2.vim
  enew
  1wincmd w
  normal zM
  call assert_equal([0, 0, 1, 2, 2, 2, 0, 1, 2, 2, 1, 2, 2, 2, 0],
	\ map(range(1, line('$')), "foldlevel(v:val)"))
  call assert_equal([-1, -1, 3, 3, 3, 3, -1, 8, 8, 8, 8, 8, 8, 8, -1],
	\ map(range(1, line('$')), "foldclosed(v:val)"))

  " Edit one file and check the taglist window folds are opened
  2wincmd w
  edit Xtest1.c
  1wincmd w
  call assert_equal([-1, -1, -1, -1, -1, -1, -1, 8, 8, 8, 8, 8, 8, 8, -1],
	\ map(range(1, line('$')), "foldclosed(v:val)"))

  " Edit another file and check the taglist window folds are opened
  2wincmd w
  enew
  1wincmd w
  normal zM
  2wincmd w
  edit Xtest2.vim
  1wincmd w
  call assert_equal([-1, -1, 3, 3, 3, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1],
	\ map(range(1, line('$')), "foldclosed(v:val)"))

  TlistClose
  %bw!
endfunc

" Test for changing the tag sort order in the taglist window
func Test_tlist_window_change_sort()
  edit Xtest1.c
  Tlist
  1wincmd w
  let r = getbufline(winbufnr(1), 1, '$')
  let expected = [
	\  'Xtest1.c',
	\  '  function',
	\  '    xyz',
	\  '    abc',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[3:])

  " sort the tags alphabetically
  normal s
  let r = getbufline(winbufnr(1), 1, '$')
  let expected = [
	\  'Xtest1.c',
	\  '  function',
	\  '    abc',
	\  '    xyz',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[3:])

  " sort the tags by chronological order.
  normal s
  let r = getbufline(winbufnr(1), 1, '$')
  let expected = [
	\  'Xtest1.c',
	\  '  function',
	\  '    xyz',
	\  '    abc',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[3:])

  TlistClose
  %bw!
endfunc

" Test for jumping to a tag when sorted by chronological order
func Test_tagjump_chronological_order()
  let g:Tlist_Sort_Type="name"
  edit Xtest1.c
  TlistOpen
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(7, line('.'))
  TlistOpen
  call cursor(6, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(3, line('.'))
  TlistClose
  %bw!
  let g:Tlist_Sort_Type="order"
endfunc

" Test for displaying detailed help text in the taglist window
func Test_tlist_window_toggle_help()
  edit Xtest1.c
  TlistOpen
  TlistOpen
  call feedkeys("\<F1>", 'xt')
  let r = getbufline(winbufnr(1), 1, '$')
  let expected = [
	\  '" <enter> : Jump to tag definition',
	\  '" o : Jump to tag definition in new window',
	\  '" p : Preview the tag definition',
	\  '" <space> : Display tag prototype',
	\  '" u : Update tag list',
	\  '" s : Select sort field',
	\  '" d : Remove file from taglist',
	\  '" x : Zoom-out/Zoom-in taglist window',
	\  '" + : Open a fold',
	\  '" - : Close a fold',
	\  '" * : Open all folds',
	\  '" = : Close all folds',
	\  '" [[ : Move to the start of previous file',
	\  '" ]] : Move to the start of next file',
	\  '" q : Close the taglist window',
	\  '" <F1> : Remove help text',
	\  '',
	\  'Xtest1.c',
	\  '  function',
	\  '    xyz',
	\  '    abc',
	\  ''
	\ ]
  call assert_equal(expected[:16], r[:16])
  call assert_equal(expected[18:], r[18:])

  " make sure jumping to a tag still works
  call cursor(21, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal('Xtest1.c', bufname(''))
  call assert_equal(7, line('.'))

  " The help text state should be remembered even if the taglist window is
  " closed and reopened.
  TlistClose
  TlistOpen
  call assert_equal(expected[:16], r[:16])
  call assert_equal(expected[18:], r[18:])

  " Display the brief help text.
  call feedkeys("\<F1>", 'xt')
  TlistClose
  %bw!
endfunc

" Test for toggling the taglist window help text in compact mode
" Help text is not displayed in compact mode.
func Test_tlist_window_toggle_help_compact_format()
  let g:Tlist_Compact_Format=1
  TlistOpen
  call assert_equal([''], getline(1, '$'))
  call feedkeys("\<F1>", 'xt')
  call assert_equal([''], getline(1, '$'))
  call feedkeys("\<F1>", 'xt')
  call assert_equal([''], getline(1, '$'))
  TlistClose
  %bw!
  let g:Tlist_Compact_Format=0
endfunc

" Test for opening a file in a new window, previous window and a new tab.
func Test_tlist_window_open_file()
  edit Xtest1.c
  call cursor(1, 1)
  TlistOpen

  " Open file in a new window
  call cursor(6, 1)
  normal o
  call assert_equal([2, 3], [winnr(), winnr('$')])
  call assert_equal(winbufnr(2), winbufnr(3))
  call assert_equal(7, line('.'))
  3wincmd w
  call assert_equal(1, line('.'))

  " open file in the previous window
  enew
  1wincmd w
  call cursor(5, 1)
  normal P
  call assert_equal(3, winnr())
  call assert_equal(winbufnr(2), winbufnr(3))
  call assert_equal(3, line('.'))

  " open a file without leaving the taglist window
  enew
  1wincmd w
  call cursor(5, 1)
  normal p
  call assert_equal(1, winnr())
  call assert_equal('Xtest1.c', bufname(winbufnr(2)))
  call assert_equal('', bufname(winbufnr(3)))
  2wincmd w
  call assert_equal(3, line('.'))

  " jumping to a file in another tabpage
  1wincmd w
  call cursor(6, 1)
  normal t
  call assert_equal(1, tabpagenr('$'))
  call assert_equal(2, winnr())
  enew
  1wincmd w
  call cursor(6, 1)
  normal t
  call assert_equal([2, 2], [tabpagenr(), tabpagenr('$')])
  call assert_equal([2, 7], [winnr(), line('.')])
  1tabnext
  1wincmd w
  call assert_equal(6, line('.'))
  2tabclose
  tabedit Xtest1.c
  1tabnext
  2wincmd w
  enew
  1wincmd w
  call cursor(5, 1)
  normal t
  call assert_equal([2, 1, 3], [tabpagenr(), winnr(), line('.')])

  " jumping to a file in a new tabpage
  1tabnext
  tabonly
  1wincmd w
  call cursor(6, 1)
  call feedkeys("\<C-t>", "xt")
  call assert_equal([2, 2], [tabpagenr('$'), tabpagenr()])
  call assert_equal(2, winnr())

  TlistClose
  %bw!
endfunc

" Test for opening a file from the taglist window when only taglist window is
" present
func Test_tlist_window_only_open_file()
  edit Xtest1.c
  call cursor(1, 1)
  TlistOpen
  only
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal([2, 'Xtest1.c'], [winnr(), bufname('')])
  TlistClose
  %bw!
endfunc

" Test for saving and restoring taglist session
func Test_tlist_session()
  edit Xtest1.c
  Tlist
  edit Xtest2.vim
  TlistSessionSave Xsession.vim
  %bw!
  TlistSessionLoad Xsession.vim
  let l = Tlist_Get_Filenames()
  call assert_match('Xtest1.c$', l[0])
  call assert_match('Xtest2.vim$', l[1])
  Tlist
  1wincmd w
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_match('Xtest1.c$', bufname(''))
  call assert_equal(3, line('.'))
  1wincmd w
  call cursor(14, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_match('Xtest2.vim$', bufname(''))
  call assert_equal(7, line('.'))

  call delete('Xsession.vim')
  TlistClose
  %bw!

  " Error cases
  redir => info
    TlistSessionSave
  redir END
  call assert_equal('Usage: TlistSessionSave <filename>', split(info, "\n")[0])

  redir => info
    TlistSessionSave Xsess.log
  redir END
  call assert_equal('Warning: Taglist is empty. Nothing to save.',
	\ split(info, "\n")[0])

  redir => info
    TlistSessionLoad
  redir END
  call assert_equal('Usage: TlistSessionLoad <filename>', split(info, "\n")[0])

  redir => info
    TlistSessionLoad Abcd
  redir END
  call assert_equal('Taglist: Error - Unable to open file Abcd',
	\ split(info, "\n")[0])

  call writefile(['test'], 'Xdummy')
  redir => info
    TlistSessionLoad Xdummy
  redir END
  call assert_equal('Taglist: Error - Corrupted session file Xdummy',
	\ split(info, "\n")[0])

  call delete('Xdummy')
endfunc

" Test for TlistLock and TlistUnlock
func Test_tlist_lock()
  let g:Tlist_Compact_Format=1
  TlistLock
  Tlist
  edit Xtest1.c
  edit Xtest2.vim
  call assert_equal([''], getbufline(winbufnr(1), 1, '$'))
  call assert_equal([], Tlist_Get_Filenames())
  TlistUnlock
  edit Xtest1.c
  edit Xtest2.vim
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c', r[0])
  call assert_match('Xtest2.vim', r[4])
  let l = Tlist_Get_Filenames()
  call assert_match('Xtest1.c', l[0])
  call assert_match('Xtest2.vim', l[1])
  TlistClose
  %bw!
  let g:Tlist_Compact_Format=0
endfunc

" Test for the :TlistAddFiles command
func Test_add_files()
  if has('nvim')
    " The TlistAddFiles command uses the following command to detect the
    " filetype of a file without loading it:
    "	  doautocmd filetypedect BufRead <filename>
    " This doesn't work in recent versions of NeoVim starting with 0.11.x
    return
  endif

  %bw!
  Tlist
  TlistAddFiles Xtest*
  let l = Tlist_Get_Filenames()
  call assert_match('Xtest1.c', l[0])
  call assert_match('Xtest2.vim', l[1])
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c', r[2])
  call assert_match('Xtest2.vim', r[7])
  1wincmd w
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal([2, 3], [winnr(), line('.')])
  call assert_match('Xtest1.c$', bufname(''))
  1wincmd w
  call cursor(14, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal([2, 7], [winnr(), line('.')])
  call assert_match('Xtest2.vim$', bufname(''))
  TlistClose
  %bw!
  call assert_equal([], Tlist_Get_Filenames())
  redir => l
    TlistAddFiles a1b2c3*
  redir END
  call assert_equal('Error: No matching files are found', split(l, "\n")[0])
endfunc

" Test for the :TlistAddFilesRecursive command
func Test_add_files_recursive()
  if has('nvim')
    " The TlistAddFiles command uses the following command to detect the
    " filetype of a file without loading it:
    "	  doautocmd filetypedect BufRead <filename>
    " This doesn't work in recent versions of NeoVim starting with 0.11.x
    return
  endif
  call mkdir('Xdir/a', 'p')
  call mkdir('Xdir/b', 'p')
  call writefile(['def xFn():', '  pass'], 'Xdir/x.py')
  call writefile(['def aFn():', '  pass'], 'Xdir/a/a.py')
  call writefile(['def bFn():', '  pass'], 'Xdir/b/b.py')
  TlistAddFilesRecursive Xdir
  let l = Tlist_Get_Filenames()
  call assert_match('x.py$', l[0])
  call assert_match('a.py$', l[1])
  call assert_match('b.py$', l[2])
  Tlist
  1wincmd w
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_match('x.py$', bufname(''))
  1wincmd w
  call cursor(9, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_match('a.py$', bufname(''))
  1wincmd w
  call cursor(13, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_match('b.py$', bufname(''))
  TlistClose
  %bw!
  call assert_equal([], Tlist_Get_Filenames())
  call delete('Xdir', 'rf')
  redir => l
    TlistAddFilesRecursive Xdir
  redir END
  call assert_match('Error: .*Xdir is not a directory', split(l, "\n")[0])
endfunc

" Test for :TlistToggle
func Test_tlist_window_toggle()
  TlistToggle
  call assert_equal(2, winnr('$'))
  call assert_equal('__Tag_List__', bufname(winbufnr(1)))
  TlistToggle
  call assert_equal(1, winnr('$'))
  call assert_equal('', bufname(winbufnr(1)))
endfunc

" Test for :TlistClose
func Test_tlist_window_close()
  redir => info
    TlistClose
  redir END
  call assert_equal('Error: Taglist window is not open', split(info, "\n")[0])
endfunc

" Test for the 'Tlist_GainFocus_On_ToggleOpen' option
func Test_Tlist_GainFocus_On_ToggleOpen()
  let g:Tlist_GainFocus_On_ToggleOpen=0
  TlistToggle
  call assert_equal([2, 2], [winnr(), winnr('$')])
  TlistClose
  call assert_equal(1, winnr('$'))
  let g:Tlist_GainFocus_On_ToggleOpen=1
  TlistToggle
  call assert_equal([1, 2], [winnr(), winnr('$')])
  call feedkeys("q", 'xt')
  call assert_equal([1, 1], [winnr(), winnr('$')])
  let g:Tlist_GainFocus_On_ToggleOpen=0
endfunc

" Test for the 'Tlist_Close_On_Select' option
func Test_Tlist_Close_On_Select()
  edit Xtest1.c
  let g:Tlist_Close_On_Select=1
  TlistOpen
  call cursor(5, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal([1, 1], [winnr(), winnr('$')])
  call assert_equal([3, 'Xtest1.c'], [line('.'), bufname('')])
  %bw!
  let g:Tlist_Close_On_Select=0
endfunc

" When opening a file from the taglist window, a buffer with 'buftype' set
" should not be used.
func Test_file_open_buftype_check()
  edit Xtest2.vim
  Tlist
  enew
  new
  set buftype=nofile
  3wincmd c
  1wincmd w
  call cursor(9, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal([2, 3], [winnr(), winnr('$')])
  call assert_equal([7, 'Xtest2.vim'], [line('.'), bufname('')])
  TlistClose
  %bw!
endfunc

" Test for the 'Tlist_Auto_Highlight_Tag' option
func Test_Tlist_Auto_Highlight_Tag()
  let g:Tlist_Auto_Highlight_Tag=0
  edit Xtest1.c
  call cursor(4, 1)
  Tlist
  1wincmd w
  call assert_equal([], getmatches())
  wincmd w
  " switching to the taglist window and then back should not highlight the tag
  wincmd w
  wincmd w
  1wincmd w
  call assert_equal([], getmatches())
  wincmd w
  " Using TlistHighlightTag should highlight the tag
  TlistHighlightTag
  1wincmd w
  let m = getmatches()
  call assert_equal('\%5l\s\+\zs.*', m[0].pattern)
  TlistClose
  %bw!
  let g:Tlist_Auto_Highlight_Tag=1
endfunc

" Test for the 'Tlist_Display_Prototype' option
func Test_Tlist_Display_Prototype()
  let g:Tlist_Display_Prototype=1
  edit Xtest1.c
  TlistOpen
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[2])
  let expected = [
	\  'Xtest1.c',
	\  '  function',
	\  '    void xyz()',
	\  '    void abc()',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[3:])
  call cursor(6, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal([2, 'Xtest1.c', 7], [winnr(), bufname(''), line('.')])
  TlistClose
  %bw!
  let g:Tlist_Display_Prototype=0
endfunc

" Test for the 'Tlist_Show_One_File' option
func Test_Tlist_Show_One_File()
  let g:Tlist_Compact_Format=1
  let g:Tlist_Show_One_File=1
  edit Xtest1.c
  edit Xtest2.vim
  enew
  Tlist

  let r = getbufline(winbufnr(1), 1, '$')
  call assert_equal([''], r)

  edit Xtest1.c
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[0])

  edit Xtest2.vim
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest2.vim (.*)', r[0])

  " Editing a non-existing file should not refresh the taglist window
  edit Xtest3.py
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest2.vim (.*)', r[0])

  " Test for jumping to a tag
  bw Xtest1.c
  1wincmd w
  call cursor(6, 1)
  call feedkeys("\<CR>", 'xt')
  call assert_equal(7, line('.'))

  " Test for highlighting the current tag
  call cursor(4, 1)
  TlistHighlightTag
  1wincmd w
  let m = getmatches()
  call assert_equal('\%5l\s\+\zs.*', m[0].pattern)

  " Test for getting information about a tag type
  1wincmd w
  call cursor(2, 1)
  redir => info
    call feedkeys("\<Space>", 'xt')
  redir END
  call assert_equal(['Tag type=variable, Tag count=1'], split(info, "\n"))

  " Test for deleting a file in the taglist window
  call cursor(1, 1)
  normal d
  let r = getline(1, '$')
  call assert_equal([''], r)

  " Add the file back again
  wincmd w
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_equal(['  variable', '    s:State', '  function', '    Func1',
	\ '    Func2', ''], r[1:])

  TlistClose
  %bw!
  let g:Tlist_Show_One_File=0
  let g:Tlist_Compact_Format=0
endfunc

" Test for highlighting the current tag when Tlist_Show_One_File=1
func Test_Show_One_File_Highlight_Tag()
  let g:Tlist_Compact_Format=1
  let g:Tlist_Show_One_File=1
  Tlist
  edit Xtest2.vim
  edit Xtest1.c
  " When removing an older file, make sure the index for the current file gets
  " updated
  bw Xtest2.vim

  call cursor(4, 1)
  redir => l
    TlistShowTag
  redir END
  let l = split(l, "\n")
  call assert_equal(['xyz'], l)

  call cursor(8, 1)
  redir => l
    TlistShowTag
  redir END
  let l = split(l, "\n")
  call assert_equal(['abc'], l)

  TlistClose
  %bw!
  let g:Tlist_Show_One_File=0
  let g:Tlist_Compact_Format=0
endfunc

" Test for 'Tlist_Display_Tag_Scope' option
func Test_Tlist_Display_Tag_Scope()
  " Create a file with a tag that has scope
  let l = [
	\  'class Car():',
	\  '  def __init__(self):',
	\  '    pass'
	\ ]
  call writefile(l, 'Xfile3.py')
  edit Xfile3.py

  " Test with Tlist_Display_Tag_Scope set to 0
  Tlist

  let g:Tlist_Display_Tag_Scope=0
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xfile3.py (.*)', r[2])
  let expected = [
	\  'Xfile3.py',
	\  '  class',
	\  '    Car',
	\  '',
	\  '  member',
	\  '    __init__',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[3:])

  " Test with Tlist_Display_Tag_Scope set to 1
  let g:Tlist_Display_Tag_Scope=1
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xfile3.py (.*)', r[2])
  let expected = [
	\  'Xfile3.py',
	\  '  class',
	\  '    Car',
	\  '',
	\  '  member',
	\  '    __init__ [Car]',
	\  ''
	\ ]
  call assert_equal(expected[1:], r[3:])
  TlistClose
  %bw!
  call delete('Xfile3.py')
endfunc

" Test for deleting a buffer which is in the taglist
func Test_bdel_buffer()
  let g:Tlist_Compact_Format=1
  edit Xtest1.c
  Tlist
  call assert_true(len(getbufline(winbufnr(1), 1, '$')) > 1)
  enew
  bdel Xtest1.c
  call assert_equal([''], getbufline(winbufnr(1), 1, '$'))
  TlistClose
  %bw!
  let g:Tlist_Compact_Format=0
endfunc

" Test for the 'Tlist_Enable_Fold_Column' option
func Test_Tlist_Enable_Fold_Column()
  edit Xtest1.c
  let g:Tlist_Enable_Fold_Column=0
  Tlist
  if has('nvim')
    call assert_equal('0', getwinvar(1, '&foldcolumn'))
  else
    call assert_equal(0, getwinvar(1, '&foldcolumn'))
  endif
  TlistClose
  let g:Tlist_Enable_Fold_Column=1
  Tlist
  if has('nvim')
    call assert_equal('3', getwinvar(1, '&foldcolumn'))
  else
    call assert_equal(3, getwinvar(1, '&foldcolumn'))
  endif
  TlistClose
  %bw!
endfunc

" Test for the 'Tlist_File_Fold_Auto_Close' option
func Test_Tlist_File_Fold_Auto_Close()
  edit Xtest1.c
  let g:Tlist_File_Fold_Auto_Close=1
  Tlist
  enew
  1wincmd w
  call assert_equal([-1, -1, 3, 3, 3, 3, -1],
	\ map(range(1, line('$')), "foldclosed(v:val)"))
  TlistClose
  let g:Tlist_File_Fold_Auto_Close = 0
  TlistOpen
  call assert_equal([-1, -1, -1, -1, -1, -1, -1],
	\ map(range(1, line('$')), "foldclosed(v:val)"))
  TlistClose
  %bw!
endfunc

" Test for the 'Tlist_Highlight_Tag_On_BufEnter' option
func Test_Tlist_Highlight_Tag_On_BufEnter()
  edit Xtest1.c
  call cursor(1, 1)
  let g:Tlist_Highlight_Tag_On_BufEnter = 0
  Tlist
  call cursor(9, 1)
  1wincmd w
  2wincmd w
  1wincmd w
  let m = getmatches()
  wincmd w
  call assert_equal([], m)
  let g:Tlist_Highlight_Tag_On_BufEnter = 1
  1wincmd w
  2wincmd w
  1wincmd w
  let m = getmatches()
  wincmd w
  call assert_equal('\%6l\s\+\zs.*', m[0].pattern)
  TlistClose
  %bw!
endfunc

" Test for the 'Tlist_Auto_Update' option
func Test_Tlist_Auto_Update()
  let g:Tlist_Compact_Format=1
  let g:Tlist_Auto_Update=0
  edit Xtest1.c
  Tlist
  call assert_equal([''], getbufline(winbufnr(1), 1, '$'))
  TlistUpdate
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[0])
  TlistClose
  %bw!

  let g:Tlist_Auto_Update=1
  edit Xtest1.c
  Tlist
  let r = getbufline(winbufnr(1), 1, '$')
  call assert_match('Xtest1.c (.*)', r[0])
  TlistClose
  %bw!
  let g:Tlist_Compact_Format=0
endfunc

" Test for the 'Tags' base menu and the popup menu
func Test_gui_base_menu()
  if !exists('*menu_info')
    return
  endif
  %bw!
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('Tags.Sort menu by')
  call assert_equal({'modes': 'a', 'name': 'Sort menu by',
	\ 'submenus': ['Name', 'Order'], 'shortcut': '', 'priority': 500,
	\ 'display': 'Sort menu by'}, m)

  " popup menu
  let m = menu_info('PopUp')
  call assert_equal(['a', 'PopUp', '', 500, 'PopUp'],
	\ [m.modes, m.name, m.shortcut, m.priority, m.display])
  call assert_true(index(m.submenus, 'Tags') != -1)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
endfunc

" Test for the 'Tags' menu with the tags
func Test_gui_menu_with_tags()
  if !exists('*menu_info')
    return
  endif
  edit Xtest2.vim
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest2.vim',
	\ '-SEP2-', 'variable', 'function'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  let m = menu_info('Tags.variable')
  call assert_equal({'modes': 'a', 'name': 'variable',
	\ 'submenus': ['0.s:State'], 'shortcut': '', 'priority': 500,
	\ 'display': 'variable'}, m)
  let m = menu_info('Tags.function')
  call assert_equal({'modes': 'a', 'name': 'function',
	\ 'submenus': ['0.Func1', '1.Func2'], 'shortcut': '', 'priority': 500,
	\ 'display': 'function'}, m)

  " popup menu
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-',
	\ 'variable', 'function'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags.variable')
  call assert_equal({'modes': 'a', 'name': 'variable',
	\ 'submenus': ['0.s:State'], 'shortcut': '', 'priority': 500,
	\ 'display': 'variable'}, m)
  let m = menu_info('PopUp.Tags.function')
  call assert_equal({'modes': 'a', 'name': 'function',
	\ 'submenus': ['0.Func1', '1.Func2'], 'shortcut': '', 'priority': 500,
	\ 'display': 'function'}, m)
  %bw!
endfunc

" Test for jumping to a tag by selecting a menu item
func Test_gui_menu_jump_to_tag()
  edit Xtest2.vim
  emenu Tags.variable.0\.s:State
  call assert_equal(1, line('.'))
  emenu Tags.function.1\.Func2
  call assert_equal(7, line('.'))

  " popup menu
  emenu PopUp.Tags.variable.0\.s:State
  call assert_equal(1, line('.'))
  emenu PopUp.Tags.function.1\.Func2
  call assert_equal(7, line('.'))
  %bw!
endfunc

" Test for refreshing the menu with the tags when jumping between files
func Test_gui_menu_edit_multiple_files()
  if !exists('*menu_info')
    return
  endif
  edit Xtest2.vim
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest2.vim',
	\ '-SEP2-', 'variable', 'function'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-',
	\ 'variable', 'function'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  enew
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  edit #
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest2.vim',
	\ '-SEP2-', 'variable', 'function'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-',
	\ 'variable', 'function'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  bw Xtest2.vim
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  %bw!
endfunc

" Test for the refresh menu item
func Test_gui_menu_refresh()
  if !exists('*menu_info')
    return
  endif
  call writefile([], 'Xfile3.py')
  edit Xfile3.py
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xfile3.py',
	\ '-SEP2-'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let l = [
	\  'class Car():',
	\  '  def __init__(self):',
	\  '    pass'
	\ ]
  call setline(1, l)
  write
  emenu Tags.Refresh\ menu
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xfile3.py',
	\ '-SEP2-', 'class', 'member'], 'shortcut': 'a', 'priority': 500,
	\ 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'class',
	\ 'member'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  %delete _
  write
  emenu Tags.Refresh\ menu
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xfile3.py',
	\ '-SEP2-'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  %bw!
  call delete('Xfile3.py')
endfunc

" Test for the 'Tlist_Max_Submenu_Items' option
func Test_gui_menu_max_submenu_items()
  if !exists('*menu_info')
    return
  endif
  let g:Tlist_Max_Submenu_Items=2
  let l = [
	\ '#define PI 3.14',
	\ 'void ASomeLongFunctionName1() { }',
	\ 'void BSomeLongFunctionName2() { }',
	\ 'void CSomeLongFunctionName3() { }',
	\ ]
  call writefile(l, 'Xfile4.c')
  edit Xfile4.c
  let m = menu_info('Tags.function')
  call assert_equal({'modes': 'a', 'name': 'function',
	\ 'submenus': ['ASomeLongF...BSomeLongF', 'CSomeLongF...CSomeLongF'],
	\ 'shortcut': '', 'priority': 500, 'display': 'function'}, m)
  let m = menu_info('PopUp.Tags.function')
  call assert_equal({'modes': 'a', 'name': 'function',
	\ 'submenus': ['ASomeLongF...BSomeLongF', 'CSomeLongF...CSomeLongF'],
	\ 'shortcut': '', 'priority': 500, 'display': 'function'}, m)

  %bw!
  let g:Tlist_Max_Submenu_Items=15
  call delete('Xfile4.c')
endfunc

" Test for changing the tag sort order using the menu
func Test_gui_menu_change_sort()
  if !exists('*menu_info')
    return
  endif
  edit Xtest1.c
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest1.c',
	\ '-SEP2-', '0.xyz', '1.abc'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-',
	\ '0.xyz', '1.abc'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)

  " sort the tags alphabetically
  emenu Tags.Sort\ menu\ by.Name
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest1.c',
	\ '-SEP2-', '0.abc', '1.xyz'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-',
	\ '0.abc', '1.xyz'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)

  " sort the tags by chronological order.
  emenu Tags.Sort\ menu\ by.Order
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest1.c',
	\ '-SEP2-', '0.xyz', '1.abc'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('PopUp.Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags',
	\ 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-',
	\ '0.xyz', '1.abc'],
	\ 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)

  %bw!
endfunc


" Test for jumping to a tag by double clicking the tag name
func Test_gui_double_click()
  if !has('gui_running')
    return
  endif
  edit Xtest1.c
  call cursor(1, 1)
  TlistOpen
  call cursor(6, 5)
  call test_setmouse(6, 5)
  call feedkeys("\<2-LeftMouse>", 'xt')
  call assert_equal(['Xtest1.c', 7], [bufname(''), line('.')])
  TlistClose
  %bw!
endfunc

" Test for jumping to a tag by single clicking the tag name
func Test_gui_single_click()
  if !has('gui_running')
    return
  endif
  let g:Tlist_Use_SingleClick=1
  edit Xtest1.c
  call cursor(1, 1)
  TlistOpen
  call cursor(5, 5)
  call test_setmouse(5, 5)
  call feedkeys("\<LeftMouse>", 'xt')
  call assert_equal(['Xtest1.c', 3], [bufname(''), line('.')])
  TlistClose
  %bw!
  let g:Tlist_Use_SingleClick=0
endfunc

" Test for :TlistDebug, :TlistUndebug and :TlistMessages commands
func Test_tlist_debug()
  " debug messages in a variable
  TlistDebug
  Tlist
  edit Xtest1.c
  call cursor(4, 1)
  TlistHighlightTag
  TlistClose
  TlistUndebug
  TlistMessages
  call assert_true(len(getline(1, '$')) > 10)
  %bw!

  " no debug messages
  TlistDebug
  TlistUndebug
  redir => info
    TlistMessages
  redir END
  call assert_equal('Taglist: No debug messages', split(info, "\n")[0])

  " debug messages in a file
  TlistDebug debug.log
  Tlist
  edit Xtest1.c
  call cursor(4, 1)
  TlistHighlightTag
  TlistClose
  TlistUndebug
  call assert_true(len(readfile('debug.log')) > 10)
  call delete('debug.log')

  " try to use a non-writable log file.  Run this test only on Unix-like
  " systems as the path is different on MS-Windows.
  if has('unix')
    redir => info
      TlistDebug /a/b/c/d/debug.log
    redir END
    call assert_equal('Taglist: Failed to create /a/b/c/d/debug.log',
	  \ split(info, "\n")[0])
  endif

  TlistUndebug
  %bw!
endfunc

" Test for zooming out and zooming in the taglist window
func Test_tlist_window_Zoom()
  " vertically split taglist window
  TlistOpen
  normal x
  call assert_equal(&columns - 2, winwidth(0))
  normal x
  call assert_equal(g:Tlist_WinWidth, winwidth(0))
  TlistClose
  " horizontally split taglist window
  let g:Tlist_Use_Horiz_Window=1
  TlistOpen
  normal x
  call assert_equal(&lines - 4, winheight(0))
  normal x
  call assert_equal(g:Tlist_WinHeight, winheight(0))
  TlistClose
  let g:Tlist_Use_Horiz_Window=0
endfunc

" Test for updating the tags in a file from the taglist window
func Test_tlist_window_update_file()
  call writefile([''], 'Xtest4.c')
  edit Xtest4.c
  TlistOpen
  call assert_equal(4, line('$'))
  call writefile(['#define FOO 1'], 'Xtest4.c')
  call cursor(3, 1)
  normal u
  call assert_equal(6, line('$'))
  TlistClose
  %bw!
  call delete('Xtest4.c')
endfunc

" Test for using a custom filetype setting (g:tlist_<ft>_settings)
func Test_custom_filetype_settings()
  call writefile([], 'Xtest')
  e Xtest
  set ft=myft
  Tlist

  let g:tlist_myft_settings=''
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - ',
	\ split(l, "\n")[0])

  let g:tlist_myft_settings='myft'
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - myft',
	\ split(l, "\n")[0])

  let g:tlist_myft_settings='myft:'
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - myft:',
	\ split(l, "\n")[0])

  let g:tlist_myft_settings='myft:func'
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - myft:func',
	\ split(l, "\n")[0])

  let g:tlist_myft_settings='myft;func:'
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - myft;func:',
	\ split(l, "\n")[0])

  let g:tlist_myft_settings='myft;:func'
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - myft;:func',
	\ split(l, "\n")[0])

  let g:tlist_myft_settings='myft;:'
  redir => l
    TlistUpdate
  redir END
  call assert_equal('Taglist: Invalid ctags option setting - myft;:',
	\ split(l, "\n")[0])

  TlistClose
  %bw!
  call delete('Xtest')
endfunc

" Test for custom highlight groups
func Test_custom_highlight_groups()
  if str2nr(&t_Co) <= 2
    " This test needs more than 2 colors
    return
  endif
  hi MyTagListTagName ctermfg=2
  hi MyTagListComment ctermfg=2
  hi MyTagListTitle ctermfg=2
  hi MyTagListFileName ctermfg=2
  hi MyTagListTagScope ctermfg=2

  Tlist
  redir => l
    hi TagListTagName
  redir END
  call assert_equal('TagListTagName xxx links to MyTagListTagName',
        \ split(l, "\n")[0])
  redir => l
    hi TagListComment
  redir END
  call assert_equal('TagListComment xxx links to MyTagListComment',
        \ split(l, "\n")[0])
  redir => l
    hi TagListTitle
  redir END
  call assert_equal('TagListTitle   xxx links to MyTagListTitle',
        \ split(l, "\n")[0])
  redir => l
    hi TagListFileName
  redir END
  call assert_equal('TagListFileName xxx links to MyTagListFileName',
	\ split(l, "\n")[0])
  redir => l
    hi TagListTagScope
  redir END
  call assert_equal('TagListTagScope xxx links to MyTagListTagScope',
	\ split(l, "\n")[0])
  TlistClose

  hi clear MyTagListTagName
  hi clear MyTagListComment
  hi clear MyTagListTitle
  hi clear MyTagListFileName
  hi clear MyTagListTagScope
endfunc

" Test for jumping to and highlighting tags when the tags are sorted by name
" or by order.
func Test_tag_search_order()
  let l = [
	\ '',
	\ 'void Zfunc()',
	\ '{',
	\ '}',
	\ 'void Afunc()',
	\ '{',
	\ '}',
	\ 'void Mfunc()',
	\ '{',
	\ '}',
	\ 'void Nfunc()',
	\ '{',
	\ '}',
	\ 'void Bfunc()',
	\ '{',
	\ '}']
  call writefile(l, 'Xfile4.c')
  edit Xfile4.c
  Tlist

  " try the different sort orders
  for sorttype in ['name', 'order']
    let g:Tlist_Sort_Type = sorttype
    bwipe Xfile4.c
    edit Xfile4.c
    let result = []
    " get the current tag
    for lnum in [1, 3, 6, 9, 12, 15]
      call cursor(lnum, 1)
      redir => l
      TlistShowTag
      redir END
      call add(result, split(l, "\n"))
    endfor
    call assert_equal([[], ['Zfunc'], ['Afunc'], ['Mfunc'], ['Nfunc'],
	  \ ['Bfunc']], result)

    " jump to a tag
    let result = []
    for lnum in [5, 6, 7, 8, 9]
      1wincmd w
      call cursor(lnum, 1)
      call feedkeys("\<CR>", 'xt')
      call assert_equal(2, winnr())
      call add(result, line('.'))
    endfor
    if sorttype == 'name'
      let expected = [5, 14, 8, 11, 2]
    else
      let expected = [2, 5, 8, 11, 14]
    endif
    call assert_equal(expected, result)
  endfor

  TlistClose
  %bw!
  call delete('Xfile4.c')
endfunc

" Test for the 'Tlist_Exit_OnlyWindow' option
" When closing a window if the taglist window is the only window in a tabpage,
" then the tabpage should be closed.
func Test_Tlist_Exit_OnlyWindow_tabpage()
  let g:Tlist_Exit_OnlyWindow=1
  Tlist
  tabnew
  Tlist
  call assert_equal([2, 2], [tabpagenr(), winnr()])
  close
  sleep 50m
  call assert_equal([1, 2], [tabpagenr(), winnr()])
  TlistClose
  let g:Tlist_Exit_OnlyWindow=0
  %bw!
endfunc

" TODO:
" 1. Test for 'Tlist_Process_File_Always'
"

" create files used by the tests
func CreateTestFiles()
  let l = [
	\  '#include <stdio.h>',
	\  '',
	\  'void xyz()',
	\  '{',
	\  '}',
	\  '',
	\  'void abc()',
	\  '{',
	\  '    xyz();',
	\  '}'
	\ ]
  call writefile(l, 'Xtest1.c')

  let l = [
	\  'let s:State = "start"',
	\  '',
	\  'func Func1()',
	\  '  let s:State = "Func1"',
	\  'endfunc',
	\  '',
	\  'func Func2()',
	\  '  let s:State = "Func2"',
	\  'endfunc'
	\ ]
  call writefile(l, 'Xtest2.vim')
endfunc

" remove the files used by the tests
func DeleteTestFiles()
  call delete('Xtest1.c')
  call delete('Xtest2.vim')
endfunc

func TaglistRunTests()
  set nomore
  set debug=beep
  call delete('test.log')

  call CreateTestFiles()

  " Get the list of test functions in this file and call them
  redir => fns
    silent function /^Test_
  redir END
  let fns = split(substitute(fns, '\(function\) \(\k*()\)', '\2', 'g'))

  for f in fns
    let v:errors = []
    let v:errmsg = ''
    try
      %bw!
      exe 'call ' . f
    catch
      call add(v:errors, "Error: Test " . f . " failed with exception " . v:exception . " at " . v:throwpoint)
    endtry
    if v:errmsg != ''
      call add(v:errors, "Error: Test " . f . " generated error " . v:errmsg)
    endif
    if !empty(v:errors)
      call writefile(v:errors, 'test.log', 'a')
      call writefile([f . ': FAIL'], 'test.log', 'a')
    else
      call writefile([f . ': pass'], 'test.log', 'a')
    endif
  endfor

  call DeleteTestFiles()
endfunc

let &cpo = s:save_cpo

call TaglistRunTests()
qall!

" vim: shiftwidth=2 softtabstop=2 noexpandtab
