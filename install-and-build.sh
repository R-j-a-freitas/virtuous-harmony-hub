#!/bin/bash
# Script para instalar dependências e fazer build no cPanel
# Use este script via "Run JS Script" no cPanel

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"
cd "$APPROOT" || exit 1

echo "=== Instalando dependências e fazendo build ==="
echo "Diretório: $(pwd)"
echo ""

# Tentar encontrar o npm em várias localizações
NPM_PATHS=(
    "/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/20/bin/npm"
    "/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/npm"
    "/opt/cpanel/ea-nodejs20/bin/npm"
    "/opt/cpanel/ea-nodejs18/bin/npm"
    "/usr/local/bin/npm"
    "/usr/bin/npm"
)

NPM_CMD=""
for npm_path in "${NPM_PATHS[@]}"; do
    if [ -x "$npm_path" ] 2>/dev/null; then
        NPM_CMD="$npm_path"
        echo "✓ npm encontrado em: $NPM_CMD"
        "$NPM_CMD" --version
        break
    fi
done

if [ -z "$NPM_CMD" ]; then
    echo "ERRO: npm não encontrado!"
    echo ""
    echo "SOLUÇÃO: Configure o Node.js no cPanel:"
    echo "1. Vá para 'Setup Node.js App'"
    echo "2. Crie uma aplicação com Node.js 18 ou 20"
    echo "3. Application Root: $APPROOT"
    exit 1
fi

# Instalar dependências
echo ""
echo "=== Instalando dependências ==="
"$NPM_CMD" install

if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao instalar dependências"
    exit 1
fi

# Verificar se node_modules existe
if [ ! -d "node_modules" ]; then
    echo "ERRO: node_modules não foi criado"
    exit 1
fi

echo ""
echo "✓ Dependências instaladas com sucesso"
echo ""

# Fazer build
echo "=== Fazendo build ==="
"$NPM_CMD" run build:dev

if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao fazer build"
    exit 1
fi

echo ""
echo "=== Build concluído com sucesso ==="
echo "Arquivos gerados em: dist/"



