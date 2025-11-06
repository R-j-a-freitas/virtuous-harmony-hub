# Script para instalar Node.js no Windows
Write-Host "Instalando Node.js..." -ForegroundColor Green

# URL do instalador Node.js LTS (versão mais recente)
$nodeVersion = "20.18.0"
$nodeUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"
$installerPath = "$env:TEMP\nodejs-installer.msi"

Write-Host "Baixando Node.js v$nodeVersion..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download concluído!" -ForegroundColor Green
    
    Write-Host "Instalando Node.js (isso pode levar alguns minutos)..." -ForegroundColor Yellow
    Write-Host "Por favor, aceite os termos e condições no instalador que será aberto." -ForegroundColor Cyan
    
    # Executar o instalador silenciosamente
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
    
    Write-Host "Node.js instalado com sucesso!" -ForegroundColor Green
    Write-Host "Por favor, feche e reabra o PowerShell para usar o npm." -ForegroundColor Yellow
    
    # Limpar o instalador
    Remove-Item $installerPath -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "Erro ao baixar/instalar Node.js: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Instalação manual:" -ForegroundColor Yellow
    Write-Host "1. Acesse: https://nodejs.org/" -ForegroundColor Cyan
    Write-Host "2. Baixe a versão LTS" -ForegroundColor Cyan
    Write-Host "3. Execute o instalador" -ForegroundColor Cyan
    Write-Host "4. Feche e reabra o PowerShell" -ForegroundColor Cyan
    exit 1
}

