# Script para configurar e executar o projeto automaticamente
$ErrorActionPreference = "Continue"

Write-Host "=== Configuração e Execução do Projeto ===" -ForegroundColor Cyan
Write-Host ""

# Mudar para o diretório do script
Set-Location $PSScriptRoot

# Função para verificar se Node.js está instalado
function Test-NodeInstalled {
    # Tentar encontrar Node.js em locais comuns primeiro
    $commonPaths = @(
        "$env:ProgramFiles\nodejs\node.exe",
        "${env:ProgramFiles(x86)}\nodejs\node.exe",
        "$env:LOCALAPPDATA\Programs\nodejs\node.exe",
        "C:\nodejs\node.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $nodeDir = [System.IO.Path]::GetDirectoryName($path)
            $env:PATH = "$nodeDir;$env:PATH"
            try {
                $nodeVersion = & $path --version 2>$null
                if ($nodeVersion) {
                    Write-Host "✓ Node.js encontrado em: $path ($nodeVersion)" -ForegroundColor Green
                    return $true
                }
            } catch {}
        }
    }
    
    # Tentar usar node do PATH
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            Write-Host "✓ Node.js encontrado no PATH: $nodeVersion" -ForegroundColor Green
            return $true
        }
    } catch {}
    
    return $false
}

# Verificar Node.js
if (-not (Test-NodeInstalled)) {
    Write-Host "Node.js não encontrado. Tentando instalar..." -ForegroundColor Yellow
    Write-Host ""
    
    # Tentar executar o script de instalação
    if (Test-Path "install-nodejs.ps1") {
        Write-Host "Executando script de instalação do Node.js..." -ForegroundColor Cyan
        Write-Host "NOTA: A instalação pode requerer privilégios de administrador." -ForegroundColor Yellow
        Write-Host ""
        
        try {
            # Tentar executar como administrador
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            
            if ($isAdmin) {
                & powershell -ExecutionPolicy Bypass -File "install-nodejs.ps1"
            } else {
                Write-Host "Tentando executar como administrador..." -ForegroundColor Yellow
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\install-nodejs.ps1`"" -Verb RunAs -Wait
            }
            
            # Atualizar PATH após instalação
            $env:PATH = "$env:ProgramFiles\nodejs;$env:PATH"
            $env:PATH = "${env:ProgramFiles(x86)}\nodejs;$env:PATH"
            
            # Aguardar um pouco para o PATH ser atualizado
            Start-Sleep -Seconds 3
            
            # Verificar novamente
            if (-not (Test-NodeInstalled)) {
                Write-Host ""
                Write-Host "⚠ ATENÇÃO: Node.js pode não ter sido instalado automaticamente." -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Por favor, execute uma das seguintes opções:" -ForegroundColor Cyan
                Write-Host "1. Execute manualmente: .\install-nodejs.ps1" -ForegroundColor White
                Write-Host "2. Baixe e instale de: https://nodejs.org/" -ForegroundColor White
                Write-Host "3. Após instalar, feche e reabra o PowerShell e execute este script novamente." -ForegroundColor White
                Write-Host ""
                exit 1
            }
        } catch {
            Write-Host "Erro ao instalar Node.js: $_" -ForegroundColor Red
            Write-Host ""
            Write-Host "Por favor, instale manualmente o Node.js de: https://nodejs.org/" -ForegroundColor Yellow
            Write-Host "Ou execute: .\install-nodejs.ps1" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "Erro: Script de instalação não encontrado." -ForegroundColor Red
        Write-Host "Por favor, instale manualmente o Node.js de: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
}

# Verificar npm
Write-Host ""
Write-Host "Verificando npm..." -ForegroundColor Cyan
try {
    $npmVersion = npm --version 2>$null
    Write-Host "✓ npm encontrado: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "Erro: npm não encontrado." -ForegroundColor Red
    exit 1
}

# Instalar dependências
Write-Host ""
Write-Host "Instalando dependências do projeto..." -ForegroundColor Cyan
if (-not (Test-Path "node_modules")) {
    Write-Host "Executando: npm install" -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erro ao instalar dependências." -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Dependências instaladas com sucesso!" -ForegroundColor Green
} else {
    Write-Host "✓ Dependências já instaladas (node_modules existe)" -ForegroundColor Green
}

# Executar o servidor de desenvolvimento
Write-Host ""
Write-Host "=== Iniciando servidor de desenvolvimento ===" -ForegroundColor Cyan
Write-Host "Servidor estará disponível em: http://localhost:8080" -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar o servidor" -ForegroundColor Yellow
Write-Host ""

npm run dev

