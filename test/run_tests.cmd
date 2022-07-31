@echo off

REM Script to run the unit-tests for the taglist Vim plugin on MS-Windows

SETLOCAL
SET VIMPRG="vim.exe"
REM SET VIMPRG="C:\Program Files (x86)\vim\vim82\vim.exe"
REM SET VIMPRG="C:\Program Files (x86)\vim\vim73\vim.exe"
SET VIM_CMD=%VIMPRG% -N -u NONE -U NONE -i NONE --noplugin

if exist "test.log" del test.log

%VIM_CMD% -S unit_tests.vim
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Vim encountered some error when running the tests.
    exit /b 1
)

IF NOT EXIST test.log (
    echo ERROR: Test results file 'test.log' is not found.
    exit /b 1
)

echo Taglist unit test results:
echo =========================
type test.log
echo(

findstr /I FAIL test.log > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ERROR: Some tests failed.
    exit /b 1
)
if %ERRORLEVEL% NEQ 0 echo SUCCESS: All the tests passed.
exit /b 0
