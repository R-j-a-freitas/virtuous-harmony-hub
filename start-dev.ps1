# Script PowerShell para iniciar o servidor de desenvolvimento
$ErrorActionPreference = "Stop"

# Mudar para o diretório do script
Set-Location $PSScriptRoot

# Definir caminho do Node.js
$nodePath = "C:\nodejs\node-v20.11.0-win-x64\node.exe"

# Verificar se o Node.js existe
if (-not (Test-Path $nodePath)) {
    Write-Host "Erro: Node.js não encontrado em $nodePath" -ForegroundColor Red
    exit 1
}

# Verificar se o Vite existe
$vitePath = Join-Path $PSScriptRoot "node_modules\vite\bin\vite.js"
if (-not (Test-Path $vitePath)) {
    Write-Host "Erro: Vite não encontrado. Execute 'npm install' primeiro." -ForegroundColor Red
    exit 1
}

Write-Host "Iniciando servidor de desenvolvimento..." -ForegroundColor Green
Write-Host "Servidor estará disponível em: http://localhost:8080" -ForegroundColor Cyan

# Executar Vite
& $nodePath $vitePath --port 8080 --host 0.0.0.0

