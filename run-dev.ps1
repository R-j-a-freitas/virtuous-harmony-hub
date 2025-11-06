# Script simplificado para executar o projeto (assume Node.js já instalado)
$ErrorActionPreference = "Stop"

Write-Host "=== Executando Projeto ===" -ForegroundColor Cyan
Write-Host ""

# Mudar para o diretório do script
Set-Location $PSScriptRoot

# Verificar Node.js
Write-Host "Verificando Node.js..." -ForegroundColor Cyan
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: Node.js não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, instale o Node.js:" -ForegroundColor Yellow
    Write-Host "1. Execute: .\install-nodejs.ps1" -ForegroundColor White
    Write-Host "2. Ou baixe de: https://nodejs.org/" -ForegroundColor White
    Write-Host "3. Ou execute: .\setup-and-run.ps1 (instalação automática)" -ForegroundColor White
    exit 1
}

# Verificar npm
Write-Host "Verificando npm..." -ForegroundColor Cyan
try {
    $npmVersion = npm --version
    Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: npm não encontrado!" -ForegroundColor Red
    exit 1
}

# Instalar dependências se necessário
Write-Host ""
Write-Host "Verificando dependências..." -ForegroundColor Cyan
if (-not (Test-Path "node_modules")) {
    Write-Host "Instalando dependências (isso pode levar alguns minutos)..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Erro ao instalar dependências!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Dependências instaladas!" -ForegroundColor Green
} else {
    Write-Host "✓ Dependências já instaladas" -ForegroundColor Green
}

# Executar servidor de desenvolvimento
Write-Host ""
Write-Host "=== Iniciando Servidor de Desenvolvimento ===" -ForegroundColor Cyan
Write-Host "Servidor: http://localhost:8080" -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
Write-Host ""

npm run dev

