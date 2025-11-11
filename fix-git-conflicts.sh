#!/bin/bash
# Script para resolver conflitos Git no servidor cPanel
# Uso: Execute este script no Terminal do cPanel ou via SSH

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"

echo "==== Resolvendo conflitos Git ===="
echo ""

cd "$APPROOT" || exit 1

echo "1. Verificando status do Git..."
git status

echo ""
echo "2. Fazendo fetch do GitHub..."
git fetch origin

echo ""
echo "3. Descartando alteracoes locais em package.json..."
git checkout -- package.json

echo ""
echo "4. Fazendo reset hard para sincronizar com GitHub..."
echo "   (Isso apagara todas as mudancas locais nao commitadas)"
git reset --hard origin/main

echo ""
echo "5. Verificando status final..."
git status

echo ""
echo "==== Concluido! ===="
echo ""
echo "Agora no cPanel:"
echo "1. Va para Git Version Control"
echo "2. Clique em 'Update from Remote'"
echo "3. Clique em 'Deploy HEAD Commit'"
echo ""

