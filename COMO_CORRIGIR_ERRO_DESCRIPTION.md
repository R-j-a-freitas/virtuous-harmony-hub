# Como Corrigir o Erro "Could not find the 'description' column"

## Problema
O erro indica que a coluna `description` não existe na tabela `gallery_images` no Supabase.

## Solução

### Passo 1: Executar Script SQL no Supabase

1. Aceda ao [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecione o seu projeto
3. Vá para **SQL Editor** (no menu lateral)
4. Execute o script `CORRIGIR_COLUNA_DESCRIPTION_GALERIA.sql`

O script irá:
- Verificar se a coluna `description` existe
- Adicionar a coluna se ela não existir
- Mostrar a estrutura atual da tabela

### Passo 2: Atualizar Schema Cache (se necessário)

Se após executar o script ainda aparecer o erro:

1. No Supabase Dashboard, vá para **Table Editor**
2. Selecione a tabela `gallery_images`
3. Verifique se a coluna `description` existe
4. Se existir, o problema é apenas com o cache - aguarde alguns minutos ou atualize a página

### Passo 3: Verificar Código

O código foi atualizado para:
- Especificar explicitamente as colunas no `SELECT` (em vez de usar `*`)
- Tratar a coluna `description` de forma segura no `INSERT`

## Estrutura Esperada da Tabela

A tabela `gallery_images` deve ter as seguintes colunas:
- `id` (UUID)
- `image_url` (TEXT)
- `title` (TEXT, nullable)
- `description` (TEXT, nullable) ← Esta pode estar em falta
- `alt_text` (TEXT, nullable)
- `display_order` (INTEGER)
- `is_visible` (BOOLEAN)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Teste

Após executar o script SQL:
1. Recarregue a página do painel administrativo
2. Tente fazer upload de uma imagem
3. O erro não deveria mais aparecer

