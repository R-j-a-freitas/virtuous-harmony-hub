# Script para fazer build local e preparar para upload no cPanel
# Uso: .\build-and-deploy.ps1

Write-Host "==== Virtuous Ensemble - Build e Deploy ====" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar se esta no diretorio correto
if (-not (Test-Path "package.json")) {
    Write-Host "ERRO: package.json nao encontrado. Execute este script na raiz do projeto." -ForegroundColor Red
    exit 1
}

# 2. Verificar e instalar dependencias
Write-Host "1. Verificando dependencias..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "Instalando dependencias..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO: Falha ao instalar dependencias!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[OK] Dependencias ja instaladas" -ForegroundColor Green
}

# Verificar se vite esta instalado
if (-not (Test-Path "node_modules\.bin\vite.cmd") -and -not (Test-Path "node_modules\.bin\vite")) {
    Write-Host "Vite nao encontrado, instalando..." -ForegroundColor Yellow
    npm install vite --save-dev
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO: Falha ao instalar vite!" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# 3. Fazer build
Write-Host "2. Fazendo build do projeto..." -ForegroundColor Yellow
# Usar npx para garantir que o vite seja encontrado
npx vite build

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO: Build falhou!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Build concluido com sucesso!" -ForegroundColor Green
Write-Host ""

# 4. Verificar se dist foi criado
if (-not (Test-Path "dist")) {
    Write-Host "ERRO: Pasta dist nao foi criada!" -ForegroundColor Red
    exit 1
}

Write-Host "3. Verificando conteudo de dist/..." -ForegroundColor Yellow
$fileCount = (Get-ChildItem -Path "dist" -Recurse -File).Count
Write-Host "[OK] Encontrados $fileCount arquivos em dist/" -ForegroundColor Green
Write-Host ""

# 5. Criar 404.html e .htaccess
Write-Host "4. Criando arquivos necessarios para SPA..." -ForegroundColor Yellow

# Criar 404.html
if (Test-Path "dist/index.html") {
    Copy-Item "dist/index.html" "dist/404.html" -Force
    Write-Host "[OK] Criado dist/404.html" -ForegroundColor Green
}

# Criar .htaccess
$htaccessContent = "RewriteEngine On`nRewriteBase /`nRewriteCond %{REQUEST_FILENAME} !-f`nRewriteCond %{REQUEST_FILENAME} !-d`nRewriteRule . /index.html [L]"
$htaccessPath = Join-Path "dist" ".htaccess"
[System.IO.File]::WriteAllText($htaccessPath, $htaccessContent, [System.Text.Encoding]::ASCII)
Write-Host "[OK] Criado dist/.htaccess" -ForegroundColor Green
Write-Host ""

# 6. Criar arquivo ZIP
Write-Host "5. Criando arquivo ZIP para upload..." -ForegroundColor Yellow
$zipFile = "dist-virtuous-harmony-hub.zip"

# Remover ZIP antigo se existir
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# Criar ZIP
Compress-Archive -Path "dist\*" -DestinationPath $zipFile -Force

if (Test-Path $zipFile) {
    $zipSize = (Get-Item $zipFile).Length / 1MB
    $zipSizeRounded = [math]::Round($zipSize, 2)
    Write-Host "[OK] ZIP criado: $zipFile ($zipSizeRounded MB)" -ForegroundColor Green
} else {
    Write-Host "ERRO: Falha ao criar ZIP!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "BUILD E PREPARACAO CONCLUIDOS!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PROXIMOS PASSOS NO CPANEL:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Acesse o File Manager do cPanel" -ForegroundColor White
Write-Host "2. Navegue para: /home/virtuou2/repositories/virtuous-harmony-hub" -ForegroundColor White
Write-Host "3. Faca upload do arquivo: $zipFile" -ForegroundColor White
Write-Host "4. Extraia o ZIP (botao direito -> Extract)" -ForegroundColor White
Write-Host "5. Execute no Terminal do cPanel:" -ForegroundColor White
Write-Host ""
Write-Host "   cd /home/virtuou2/repositories/virtuous-harmony-hub" -ForegroundColor Gray
Write-Host "   rm -rf /home/virtuou2/public_html/*" -ForegroundColor Gray
Write-Host "   cp -R dist/. /home/virtuou2/public_html/" -ForegroundColor Gray
Write-Host "   cp dist/.htaccess /home/virtuou2/public_html/" -ForegroundColor Gray
Write-Host ""
Write-Host "OU use o script deploy-to-public-html.sh no servidor" -ForegroundColor Yellow
Write-Host ""
Write-Host "Arquivo ZIP pronto: $zipFile" -ForegroundColor Green
Write-Host ""
