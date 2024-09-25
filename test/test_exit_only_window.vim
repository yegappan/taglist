" Test for the 'Tlist_Exit_OnlyWindow' taglist option

let g:Tlist_Exit_OnlyWindow=1
set rtp+=..
source ../plugin/taglist.vim
let s:save_cpo = &cpo
set cpo&vim

augroup TaglistTest
  au!
  au VimLeave * call writefile(['Test_Tlist_Exit_OnlyWindow: pass'],
	      \ 'test.log', 'a')
augroup END

Tlist
close
sleep 50m

call writefile(['Test_Tlist_Exit_OnlyWindow: FAIL'], 'test.log', 'a')
augroup TaglistTest
  au!
augroup END

let &cpo = s:save_cpo
