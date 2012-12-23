@echo off
call coffee -o js -c -- coffee/jquery-extensions.coffee coffee/app.coffee coffee/handlers.coffee coffee/main.coffee coffee/net.coffee coffee/rendering.coffee
if "%ERRORLEVEL%" == "0" index.html

