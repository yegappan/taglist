" Unit tests for the Taglist plugin

syntax on
filetype on
filetype plugin on

" Set the $TAGLIST_PROFILE environment variable to profile the taglist plugin
let do_profile = v:false
if exists('$TAGLIST_PROFILE')
  let do_profile = v:true
endif

if do_profile
  " profile the taglist plugin
  profile start taglist_profile.txt
  profile! file */taglist/*
endif

set packpath+=../..
let g:Tlist_Show_Menu=1
packadd taglist

" The WaitFor*() functions are reused from the Vim test suite.
"
" Wait for up to five seconds for "assert" to return zero.  "assert" must be a
" (lambda) function containing one assert function.  Example:
"	call WaitForAssert({-> assert_equal("dead", job_status(job)})
"
" A second argument can be used to specify a different timeout in msec.
"
" Return zero for success, one for failure (like the assert function).
func WaitForAssert(assert, ...)
  let timeout = get(a:000, 0, 5000)
  if WaitForCommon(v:null, a:assert, timeout) < 0
    return 1
  endif
  return 0
endfunc

" Either "expr" or "assert" is not v:null
" Return the waiting time for success, -1 for failure.
func WaitForCommon(expr, assert, timeout)
  " using reltime() is more accurate, but not always available
  let slept = 0
  if exists('*reltimefloat')
    let start = reltime()
  endif

  while 1
    if type(a:expr) == v:t_func
      let success = a:expr()
    elseif type(a:assert) == v:t_func
      let success = a:assert() == 0
    else
      let success = eval(a:expr)
    endif
    if success
      return slept
    endif

    if slept >= a:timeout
      break
    endif
    if type(a:assert) == v:t_func
      " Remove the error added by the assert function.
      call remove(v:errors, -1)
    endif

    sleep 10m
    if exists('*reltimefloat')
      let slept = float2nr(reltimefloat(reltime(start)) * 1000)
    else
      let slept += 10
    endif
  endwhile

  return -1  " timed out
endfunc

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
  let l = split(l, "\n")
  call assert_equal([], l)
  TlistClose
  bw!
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
  call assert_equal(['Xtest1.c, Filetype=c, Tag count=2'], split(info, "\n"))
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

  let g:Tlist_Compact_Format=0
  TlistClose
  call delete('Xtest3.c')
  %bw!
endfunc

" Test for deleting a file in the taglist window.
func Test_tlist_window_delete_file()
  %bw!
  edit Xtest1.c
  Tlist
  edit Xtest2.vim
  enew
  1wincmd w
  call cursor(3, 1)
  call feedkeys("d", 'xt')
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
  let g:Tlist_Sort_Type="order"
  TlistClose
  %bw!
endfunc

" Test for displaying detailed help text in the taglist window
func Test_tlist_window_toggle_help()
  edit Xtest1.c
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
  Tlist
  TlistSessionLoad Xsession.vim
  let l = Tlist_Get_Filenames()
  call assert_match('Xtest1.c$', l[0])
  call assert_match('Xtest2.vim$', l[1])
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
  let g:Tlist_Compact_Format=0
  %bw!
endfunc

" Test for the :TlistAddFiles command
func Test_add_files()
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
endfunc

" Test for the :TlistAddFilesRecursive command
func Test_add_files_recursive()
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
  let g:Tlist_Close_On_Select=0
  %bw!
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
  let g:Tlist_Auto_Highlight_Tag=1
  TlistClose
  %bw!
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
  let g:Tlist_Display_Prototype=0
  TlistClose
  %bw!
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
  let g:Tlist_Show_One_File=0
  let g:Tlist_Compact_Format=0
  TlistClose
  %bw!
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
  let g:Tlist_Compact_Format=0
  TlistClose
  %bw!
endfunc

" Test for the 'Tlist_Enable_Fold_Column' option
func Test_Tlist_Enable_Fold_Column()
  edit Xtest1.c
  let g:Tlist_Enable_Fold_Column=0
  Tlist
  call assert_equal(0, getwinvar(1, '&foldcolumn'))
  TlistClose
  let g:Tlist_Enable_Fold_Column=1
  Tlist
  call assert_equal(3, getwinvar(1, '&foldcolumn'))
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
  let g:Tlist_Compact_Format=0
  %bw!
endfunc

" Test for the 'Tags' base menu
func Test_gui_base_menu()
  if !has('gui_running')
    return
  endif
  %bw!
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags', 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('Tags.Sort menu by')
  call assert_equal({'modes': 'a', 'name': 'Sort menu by', 'submenus': ['Name', 'Order'], 'shortcut': '', 'priority': 500, 'display': 'Sort menu by'}, m)
endfunc

" Test for the 'Tags' menu with the tags
func Test_gui_menu_with_tags()
  if !has('gui_running')
    return
  endif
  edit Xtest2.vim
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags', 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest2.vim', '-SEP2-', 'variable', 'function'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  let m = menu_info('Tags.variable')
  call assert_equal({'modes': 'a', 'name': 'variable', 'submenus': ['0.s:State'], 'shortcut': '', 'priority': 500, 'display': 'variable'}, m)
  let m = menu_info('Tags.function')
  call assert_equal({'modes': 'a', 'name': 'function', 'submenus': ['0.Func1', '1.Func2'], 'shortcut': '', 'priority': 500, 'display': 'function'}, m)
  %bw!
endfunc

" Test for jumping to a tag by selecting a menu item
func Test_gui_menu_jump_to_tag()
  if !has('gui_running')
    return
  endif
  edit Xtest2.vim
  emenu Tags.variable.0\.s:State
  call assert_equal(1, line('.'))
  emenu Tags.function.1\.Func2
  call assert_equal(7, line('.'))
  %bw!
endfunc

" Test for refreshing the menu with the tags when jumping between files
func Test_gui_menu_refresh()
  if !has('gui_running')
    return
  endif
  edit Xtest2.vim
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags', 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest2.vim', '-SEP2-', 'variable', 'function'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  enew
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags', 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
  edit #
  let m = menu_info('Tags')
  call assert_equal({'modes': 'a', 'name': 'T&ags', 'submenus': ['Refresh menu', 'Sort menu by', '-SEP1-', 'Xtest2.vim', '-SEP2-', 'variable', 'function'], 'shortcut': 'a', 'priority': 500, 'display': 'Tags'}, m)
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

" TODO:
" 1. Test for configuring the highlight groups TagListTagName,
"    TagListTagScope, TagListTitle, TagListComment and TagListFileName
" 2. Test for 'Tlist_Process_File_Always'
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

call TaglistRunTests()
qall!

" vim: shiftwidth=2 softtabstop=2 noexpandtab
