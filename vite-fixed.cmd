@ECHO off
SETLOCAL

REM Mudar para o diretório do script
cd /d "%~dp0"

REM Definir o caminho para o Node.js
SET NODE_PATH=C:\nodejs\node-v20.11.0-win-x64\node.exe

REM Executar o Vite
"%NODE_PATH%" "%CD%\node_modules\vite\bin\vite.js" --port 8080 --host 0.0.0.0
