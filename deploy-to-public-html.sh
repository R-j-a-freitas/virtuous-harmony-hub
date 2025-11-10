#!/bin/bash
# Script para copiar dist/ para public_html no servidor cPanel
# Execute este script no Terminal do cPanel após fazer upload e extrair o ZIP

echo "==== Copiando arquivos para public_html ===="

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"
DEPLOYPATH="/home/virtuou2/public_html"

# Verificar se dist existe
if [ ! -d "$APPROOT/dist" ]; then
    echo "ERRO: Pasta dist não encontrada em $APPROOT"
    echo "Certifique-se de que extraiu o ZIP no diretório correto."
    exit 1
fi

# Verificar se public_html existe
if [ ! -d "$DEPLOYPATH" ]; then
    echo "ERRO: public_html não encontrado em $DEPLOYPATH"
    exit 1
fi

# Limpar public_html
echo "Limpando public_html..."
rm -rf "$DEPLOYPATH"/* 2>/dev/null || true
rm -rf "$DEPLOYPATH"/.[!.]* 2>/dev/null || true
rm -rf "$DEPLOYPATH"/..?* 2>/dev/null || true

# Copiar arquivos
echo "Copiando arquivos de dist para public_html..."
cp -R "$APPROOT/dist/." "$DEPLOYPATH/" || {
    echo "ERRO: Falha ao copiar arquivos"
    exit 1
}

# Verificar cópia
FILE_COUNT=$(find "$DEPLOYPATH" -type f | wc -l)
JS_COUNT=$(find "$DEPLOYPATH" -name "*.js" | wc -l)
CSS_COUNT=$(find "$DEPLOYPATH" -name "*.css" | wc -l)

echo ""
echo "=========================================="
echo "DEPLOY CONCLUÍDO COM SUCESSO!"
echo "=========================================="
echo "Total de arquivos: $FILE_COUNT"
echo "Arquivos JavaScript: $JS_COUNT"
echo "Arquivos CSS: $CSS_COUNT"
echo ""
echo "Site disponível em: https://virtuousensemble.pt"
echo ""



