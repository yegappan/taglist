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

check_result()
{
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
}

TESTS="unit_tests.vim test_exit_only_window.vim"
for test in $TESTS
do
  $VIMCMD -S $test
  check_result
done

# Test for 'Tlist_Auto_Open'
cat << EOF > Xautoopen.py
class Foo:
  def bar(self):
    pass
EOF

cat << EOF > Xautoopen.txt
vim editor
EOF

$VIMCMD -c "let test_case=1" -S test_auto_open.vim
check_result
$VIMCMD -c "let test_case=2" -S test_auto_open.vim Xautoopen.py
check_result
$VIMCMD -c "let test_case=3" -S test_auto_open.vim Xautoopen.txt
check_result
rm -f Xautoopen.py Xautoopen.txt

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
