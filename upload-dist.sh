#!/bin/bash
# Script para fazer upload e extrair dist/ no servidor
# Uso: Faça upload do dist-virtuous-harmony-hub.zip via File Manager, depois execute este script

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"
ZIPFILE="dist-virtuous-harmony-hub.zip"

echo "==== Upload e Deploy da pasta dist/ ===="
echo ""

cd "$APPROOT" || exit 1

if [ ! -f "$ZIPFILE" ]; then
    echo "ERRO: $ZIPFILE nao encontrado!"
    echo ""
    echo "INSTRUCOES:"
    echo "1. Faca build localmente: .\build-and-deploy.ps1 (Windows)"
    echo "2. Faca upload do dist-virtuous-harmony-hub.zip via File Manager"
    echo "3. Execute este script novamente"
    exit 1
fi

echo "1. Removendo dist/ antiga..."
rm -rf dist

echo "2. Extraindo novo build..."
unzip -q "$ZIPFILE" -d . || exit 1

echo "3. Removendo ZIP..."
rm "$ZIPFILE"

echo "4. Verificando dist/..."
if [ -d "dist" ] && [ -f "dist/index.html" ]; then
    echo "✓ Build extraido com sucesso!"
    echo ""
    echo "Arquivos em dist/:"
    ls -la dist/ | head -10
else
    echo "✗ ERRO: dist/ nao foi criada ou esta vazia!"
    exit 1
fi

echo ""
echo "5. Reiniciando Passenger..."
mkdir -p tmp
touch tmp/restart.txt

echo ""
echo "==== Concluido! ===="
echo ""
echo "Verifique o site em: https://virtuousensemble.pt"
echo "Health check: curl https://virtuousensemble.pt/__health"

