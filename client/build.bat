@echo off
call coffee -o js -c coffee/
if "%ERRORLEVEL%" == "0" start http://localhost:8080/index.html

