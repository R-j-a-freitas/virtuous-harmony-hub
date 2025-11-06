# Script automático para corrigir e executar o projeto
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CORREÇÃO E EXECUÇÃO AUTOMÁTICA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Mudar para o diretório do script
Set-Location $PSScriptRoot

# Função para encontrar Node.js
function Find-NodeJS {
    $paths = @(
        "C:\nodejs\node-v20.11.0-win-x64\node.exe",
        "C:\nodejs\node.exe",
        "$env:ProgramFiles\nodejs\node.exe",
        "${env:ProgramFiles(x86)}\nodejs\node.exe",
        "$env:LOCALAPPDATA\Programs\nodejs\node.exe",
        "$env:APPDATA\npm\node.exe"
    )
    
    # Tentar usar node do PATH primeiro
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            $nodePath = (Get-Command node).Source
            Write-Host "✓ Node.js encontrado no PATH: $nodeVersion" -ForegroundColor Green
            Write-Host "  Localização: $nodePath" -ForegroundColor Gray
            return $nodePath
        }
    } catch {}
    
    # Procurar em locais comuns
    foreach ($path in $paths) {
        if (Test-Path $path) {
            try {
                $nodeVersion = & $path --version 2>$null
                if ($nodeVersion) {
                    Write-Host "✓ Node.js encontrado: $nodeVersion" -ForegroundColor Green
                    Write-Host "  Localização: $path" -ForegroundColor Gray
                    
                    # Adicionar ao PATH da sessão atual
                    $nodeDir = [System.IO.Path]::GetDirectoryName($path)
                    if ($env:PATH -notlike "*$nodeDir*") {
                        $env:PATH = "$nodeDir;$env:PATH"
                        Write-Host "  ✓ Adicionado ao PATH da sessão" -ForegroundColor Yellow
                    }
                    return $path
                }
            } catch {}
        }
    }
    
    return $null
}

# Função para encontrar npm
function Find-NPM {
    $nodePath = Find-NodeJS
    if (-not $nodePath) {
        return $null
    }
    
    $nodeDir = [System.IO.Path]::GetDirectoryName($nodePath)
    $npmPath = Join-Path $nodeDir "npm.cmd"
    
    if (Test-Path $npmPath) {
        return $npmPath
    }
    
    # Tentar usar npm do PATH
    try {
        $npmVersion = npm --version 2>$null
        if ($npmVersion) {
            return (Get-Command npm).Source
        }
    } catch {}
    
    return $null
}

# PASSO 1: Verificar Node.js
Write-Host "[1/4] Verificando Node.js..." -ForegroundColor Cyan
$nodePath = Find-NodeJS

if (-not $nodePath) {
    Write-Host "✗ Node.js não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Opções:" -ForegroundColor Yellow
    Write-Host "  1. Execute: .\install-nodejs.ps1" -ForegroundColor White
    Write-Host "  2. Baixe de: https://nodejs.org/" -ForegroundColor White
    Write-Host "  3. Execute: .\setup-and-run.ps1" -ForegroundColor White
    exit 1
}

# PASSO 2: Verificar npm
Write-Host ""
Write-Host "[2/4] Verificando npm..." -ForegroundColor Cyan
$npmPath = Find-NPM

if (-not $npmPath) {
    Write-Host "✗ npm não encontrado!" -ForegroundColor Red
    exit 1
}

try {
    $npmVersion = npm --version 2>$null
    Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro ao verificar npm!" -ForegroundColor Red
    exit 1
}

# PASSO 3: Verificar e instalar dependências
Write-Host ""
Write-Host "[3/4] Verificando dependências..." -ForegroundColor Cyan

if (-not (Test-Path "node_modules")) {
    Write-Host "  Instalando dependências (pode levar alguns minutos)..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Erro ao instalar dependências!" -ForegroundColor Red
        Write-Host "  Tentando limpar cache e reinstalar..." -ForegroundColor Yellow
        npm cache clean --force
        Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
        Remove-Item -Force package-lock.json -ErrorAction SilentlyContinue
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Erro persistente ao instalar dependências!" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "✓ Dependências instaladas!" -ForegroundColor Green
} else {
    Write-Host "✓ Dependências já instaladas" -ForegroundColor Green
    
    # Verificar se node_modules está completo
    $vitePath = Join-Path "node_modules" "vite" "bin" "vite.js"
    if (-not (Test-Path $vitePath)) {
        Write-Host "  node_modules incompleto, reinstalando..." -ForegroundColor Yellow
        npm install
    }
}

# PASSO 4: Verificar e corrigir problemas comuns
Write-Host ""
Write-Host "[4/4] Verificando configuração..." -ForegroundColor Cyan

# Verificar se vite.config.ts existe
if (-not (Test-Path "vite.config.ts")) {
    Write-Host "  ⚠ vite.config.ts não encontrado!" -ForegroundColor Yellow
}

# Verificar se tsconfig.json existe
if (-not (Test-Path "tsconfig.json")) {
    Write-Host "  ⚠ tsconfig.json não encontrado!" -ForegroundColor Yellow
}

Write-Host "✓ Configuração verificada" -ForegroundColor Green

# Executar o projeto
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO SERVIDOR DE DESENVOLVIMENTO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Servidor: http://localhost:8080" -ForegroundColor Green
Write-Host "✓ Pressione Ctrl+C para parar" -ForegroundColor Yellow
Write-Host ""

# Executar npm run dev
try {
    npm run dev
} catch {
    Write-Host ""
    Write-Host "✗ Erro ao executar o servidor!" -ForegroundColor Red
    Write-Host "  Erro: $_" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Tentativas de correção:" -ForegroundColor Cyan
    Write-Host "  1. Verifique se todas as dependências estão instaladas" -ForegroundColor White
    Write-Host "  2. Execute: npm install" -ForegroundColor White
    Write-Host "  3. Verifique os logs acima para mais detalhes" -ForegroundColor White
    exit 1
}

