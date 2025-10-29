@ECHO off
SETLOCAL

REM Definir o caminho para o Node.js
SET NODE_PATH=C:\nodejs\node-v20.11.0-win-x64\node.exe

REM Executar o Vite
"%NODE_PATH%" "%~dp0\..\vite\bin\vite.js" %*
