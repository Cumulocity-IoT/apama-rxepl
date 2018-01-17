@echo off

REM Fix ERRORLEVEL
dir>NUL

REM Don't pollute the calling environment
setlocal

REM Setup the Apama Environment
IF DEFINED APAMA_HOME (
    call "%APAMA_HOME%\bin\apama_env.bat"
) ELSE (
    goto error
)

cd test

pysys run -n8 -vCRIT

goto:eof

:error
echo Could not find Apama installation