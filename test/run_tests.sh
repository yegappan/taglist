#!/bin/bash

# Script to run the unit-tests for the taglist Vim plugin

if [ -n "$TAGLIST_TEST_GUI" ]
then
    GUI_FLAGS="-g -f"
else
    GUI_FLAGS=
fi

VIMPRG=${VIMPRG:=/usr/bin/vim}
VIMCMD="$VIMPRG ${GUI_FLAGS} -N -u NONE -U NONE -i NONE --noplugin"
export VIMCMD

rm -f test.log

$VIMCMD -S unit_tests.vim
if [ $? -ne 0 ]
then
  echo ERROR: Vim encountered some error when running the tests.
  exit 1
fi

if [ ! -f test.log ]
then
  echo "ERROR: Test results file 'test.log' is not found"
  exit 1
fi

echo "Taglist unit test results:"
echo "========================="
echo

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
