#!/bin/bash

# Script to run the unit-tests for the taglist Vim plugin

VIMPRG=${VIMPRG:=/usr/bin/vim}
export VIMRUNTIME=/usr/share/vim/vim82
#VIMPRG=/home/yega/bin/vim90/bin/vim
#export VIMRUNTIME=/home/yega/bin/vim90/share/vim/vim90
VIM_CMD="$VIMPRG -u NONE -U NONE -i NONE --noplugin -N --not-a-term"
#VIM_CMD="$VIMPRG -g -f -u NONE -U NONE -i NONE --noplugin -N --not-a-term"

$VIM_CMD -S unit_tests.vim

echo "Taglist unit test results:"
echo

if [ ! -f test.log ]
then
  echo "ERROR: Test results file 'test.log' is not found"
  exit 1
fi

cat test.log

echo
grep FAIL test.log > /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "ERROR: Some test(s) failed."
  exit 1
fi

echo "SUCCESS: All the tests passed."
exit 0
