# Como Verificar e Corrigir Imagens que Não Aparecem

## Problema
As imagens não aparecem nem no site nem na página de administração, mesmo com URLs aparentemente corretas.

## Possíveis Causas

1. **URLs duplicadas**: `gallery-images/gallery-images/arquivo.jpg`
2. **Políticas de Storage**: RLS bloqueando acesso público
3. **Arquivos não existem no Storage**: Ficheiros não foram carregados corretamente
4. **Bucket não é público**: Configuração incorreta do bucket

## Solução Passo a Passo

### Passo 1: Executar Script de Correção SQL

1. Aceda ao [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecione o seu projeto
3. Vá para **SQL Editor**
4. Execute o script **`CORRIGIR_URLS_E_STORAGE.sql`**

Este script irá:
- ✅ Corrigir `file_path` duplicado
- ✅ Atualizar `image_url` com caminho correto
- ✅ Verificar políticas de storage
- ✅ Garantir que bucket é público
- ✅ Criar política de SELECT pública

### Passo 2: Verificar Storage Manualmente

1. No Supabase Dashboard, vá para **Storage**
2. Clique em **gallery-images**
3. Verifique se os ficheiros existem lá
4. Se não existirem, faça upload manual de uma imagem de teste

### Passo 3: Testar URL Diretamente

1. Copie uma URL da base de dados (após executar o script SQL)
2. Cole no browser
3. Se aparecer um erro 404 ou 403:
   - **404**: Ficheiro não existe no storage - precisa fazer upload
   - **403**: Problema de políticas RLS - executar script novamente

### Passo 4: Verificar no Browser Console

1. Abra a página do site ou admin
2. Abra **Developer Tools** (F12)
3. Vá à aba **Console**
4. Procure por erros relacionados com:
   - `CORS`
   - `403 Forbidden`
   - `404 Not Found`
   - `Failed to load image`

### Passo 5: Verificar Estrutura de URLs

URLs corretas devem ser:
```
✅ CORRETO: https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/exemplo-1.jpg
❌ ERRADO: https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/gallery-images/exemplo-1.jpg
```

## Checklist de Verificação

Após executar o script SQL, verifique:

- [ ] `file_path` não tem `gallery-images/` duplicado
- [ ] `image_url` está no formato correto
- [ ] Bucket `gallery-images` existe e é público
- [ ] Política "Anyone can view gallery images" existe
- [ ] Ficheiros existem no Storage
- [ ] URLs abrem diretamente no browser

## Se o Problema Persistir

1. **Limpar cache do browser** (Ctrl+Shift+Delete)
2. **Testar em modo anónimo/privado**
3. **Verificar CORS** no Supabase Dashboard → Storage → Settings
4. **Verificar se URLs têm typos** (ex: `mhzhxwmxnofltedmshca` vs `mhzhxwmxnofltgdmshcq`)

## Nota sobre o Código

O código foi atualizado para:
- Mostrar mensagem de erro se imagem não carregar
- Log de erros no console para debug
- `loading="lazy"` para melhor performance

