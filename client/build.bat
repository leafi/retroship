@echo off
call coffee -o js -c -- coffee/jquery-extensions.coffee coffee/app.coffee coffee/handlers.coffee coffee/main.coffee coffee/net.coffee coffee/rendering.coffee coffee/tileset-transparency.coffee
if "%ERRORLEVEL%" == "0" start http://localhost:8080/index.html

