# Script para compilar o projeto e criar ZIP da pasta dist/
$ErrorActionPreference = "Stop"

Write-Host "=== Compilando Projeto e Criando ZIP ===" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

Write-Host "Verificando Node.js..." -ForegroundColor Cyan
$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCheck) {
    Write-Host "Erro: Node.js nao encontrado!" -ForegroundColor Red
    exit 1
}
$nodeVersion = node --version
Write-Host "Node.js: $nodeVersion" -ForegroundColor Green

Write-Host ""
Write-Host "Limpando build anterior..." -ForegroundColor Cyan
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
    Write-Host "Pasta dist/ removida" -ForegroundColor Green
}

Write-Host ""
Write-Host "Executando build..." -ForegroundColor Cyan
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao fazer build!" -ForegroundColor Red
    exit 1
}

Write-Host "Build concluido com sucesso!" -ForegroundColor Green

if (-not (Test-Path "dist")) {
    Write-Host "Erro: Pasta dist/ nao foi criada!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "dist/index.html")) {
    Write-Host "Erro: dist/index.html nao encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Criando arquivo ZIP..." -ForegroundColor Cyan

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$zipFileName = "virtuous-harmony-hub-dist-$timestamp.zip"
$zipPath = Join-Path $PSScriptRoot $zipFileName

$distPath = Join-Path $PSScriptRoot "dist"
Get-ChildItem -Path $distPath -Recurse | Compress-Archive -DestinationPath $zipPath -Force

if (Test-Path $zipPath) {
    $zipSize = (Get-Item $zipPath).Length / 1MB
    Write-Host "ZIP criado com sucesso!" -ForegroundColor Green
    Write-Host "Arquivo: $zipFileName" -ForegroundColor White
    Write-Host "Tamanho: $([math]::Round($zipSize, 2)) MB" -ForegroundColor White
    Write-Host "Localizacao: $zipPath" -ForegroundColor White
    Write-Host ""
    Write-Host "=== Concluido! ===" -ForegroundColor Green
    Write-Host "O arquivo ZIP esta pronto para upload no servidor." -ForegroundColor Cyan
} else {
    Write-Host "Erro ao criar ZIP!" -ForegroundColor Red
    exit 1
}
