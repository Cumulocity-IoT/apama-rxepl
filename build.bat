@echo off

REM Fix ERRORLEVEL
dir>NUL

REM Don't pollute the calling environment
setlocal

REM Setup the Apama Environment
IF DEFINED APAMA_HOME (
  call "%APAMA_HOME%\bin\apama_env.bat"
) ELSE (
  echo Could not find Apama installation
  goto error
)

call ".\clean.bat"

engine_deploy --outputDeployDir "%~dp0output" src

goto:eof

:error