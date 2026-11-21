@echo off
setlocal

set "GODOT_BIN=%GODOT_BIN%"
if "%GODOT_BIN%"=="" set "GODOT_BIN=godot"

set "LOG_FILE=%TEMP%\deckbound_headless_tests_%RANDOM%_%RANDOM%.log"
"%GODOT_BIN%" --headless --path . --scene res://tests/test_runner.tscn -- %* > "%LOG_FILE%" 2>&1
type "%LOG_FILE%"

findstr /C:"Result: FAILED" "%LOG_FILE%" >nul
if %ERRORLEVEL%==0 (
  del "%LOG_FILE%" >nul 2>&1
  exit /b 1
)

del "%LOG_FILE%" >nul 2>&1
exit /b 0
