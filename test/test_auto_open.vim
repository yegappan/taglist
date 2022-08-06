" Test for the 'Tlist_Auto_Open' option

syntax on
filetype on
filetype plugin on
set rtp+=..
let g:Tlist_Auto_Open=1
source ../plugin/taglist.vim
set cpo&vim

if !exists('test_case')
  finish
endif

doautocmd VimEnter *

let m = 'Test_Tlist_Auto_Open(' . test_case . '): '
if test_case == 1
  " Vim invoked without any arguments
  if winnr('$') == 1 && @% == ''
    call writefile([m . 'pass'], 'test.log', 'a')
  else
    call writefile([m . 'FAIL'], 'test.log', 'a')
  endif
elseif test_case == 2
  " Vim invoked with a supported file
  if winnr() == 2 && bufname(winbufnr(1)) ==# '__Tag_List__'
    let r = getbufline(winbufnr(1), 1, '$')
    let expected = [
	  \ '  class',
	  \ '    Foo',
	  \ '',
	  \ '  member',
	  \ '    bar [Foo]',
	  \ ''
	  \ ]
    call assert_equal(expected, r[3:])
    if r[3:] ==# expected
      call writefile([m . 'pass'], 'test.log', 'a')
    else
      call writefile([m . 'FAIL'], 'test.log', 'a')
    endif
  else
    call writefile([m . 'FAIL'], 'test.log', 'a')
  endif
elseif test_case == 3
  " Vim invoked with an unsupported file
  if winnr('$') == 2
    call writefile([m . 'FAIL'], 'test.log', 'a')
  else
    call writefile([m . 'pass'], 'test.log', 'a')
  endif
endif

qall

" vim: shiftwidth=2 softtabstop=2 noexpandtab
