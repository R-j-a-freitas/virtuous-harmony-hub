# Instruções para Corrigir a Galeria

## Problema Identificado

A tabela `gallery_images` no Supabase tem uma estrutura diferente do que o código espera:

**Estrutura Atual (na Base de Dados):**
- `filename`, `original_name`, `file_path`, `file_size`, `mime_type`
- `caption` (em vez de `description`)
- `sort_order` (em vez de `display_order`)

**Estrutura Esperada pelo Código:**
- `image_url`, `title`, `description`, `display_order`

## Solução

### Passo 1: Executar Script SQL

1. Aceda ao [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecione o seu projeto
3. Vá para **SQL Editor**
4. Execute o script **`ADAPTAR_TABELA_GALERIA.sql`**

Este script irá:
- ✅ Adicionar coluna `image_url` (e preencher com URLs baseadas em `file_path`)
- ✅ Adicionar coluna `title`
- ✅ Adicionar coluna `description` (se ainda não existir)
- ✅ Adicionar coluna `display_order` (e preencher com valores de `sort_order`)
- ✅ Manter todas as colunas existentes (compatibilidade total)

### Passo 2: Verificar Resultado

Após executar o script, verifique se todas as colunas foram adicionadas corretamente.

### Passo 3: Testar Upload

1. Recarregue a página do painel administrativo
2. Vá à aba **Galeria**
3. Tente fazer upload de uma nova imagem
4. O erro não deveria mais aparecer

## Estrutura Final da Tabela

Após executar o script, a tabela terá **ambas as estruturas** (antiga + nova):
- Campos antigos: `filename`, `file_path`, `caption`, `sort_order`, etc. (mantidos)
- Campos novos: `image_url`, `title`, `description`, `display_order` (adicionados)

Isso garante compatibilidade total!

## Nota Importante

Se houver imagens antigas na base de dados, elas terão:
- `image_url` preenchido automaticamente com base no `file_path`
- `display_order` = `sort_order`
- `description` = `caption` (se caption existir)

