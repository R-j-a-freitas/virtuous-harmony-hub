# Instrução Rápida - Corrigir Imagens

## Problema
As imagens não aparecem porque as URLs na base de dados estão **truncadas** (ex: terminam em `/ga` em vez do nome completo do ficheiro).

## Solução Rápida (2 minutos)

### Passo 1: Executar Script SQL

1. Abra o [Supabase Dashboard](https://supabase.com/dashboard)
2. Vá para **SQL Editor** (no menu lateral)
3. Execute o script **`SOLUCAO_IMEDIATA_IMAGENS.sql`**
4. Verifique o resultado - deve mostrar ✅ CORRETA para todas as imagens

### Passo 2: Recarregar Página

1. Após executar o script, aguarde alguns segundos
2. **Recarregue a página do admin** (F5 ou Ctrl+R)
3. **Recarregue a página do site** (se estiver aberta)
4. As imagens devem aparecer agora!

## O que o Script Faz

1. ✅ Identifica todas as URLs truncadas/malformadas
2. ✅ Limpa as URLs problemáticas
3. ✅ Reconstrói URLs completas usando `file_path` ou `filename`
4. ✅ Garante que o bucket é público
5. ✅ Cria política de storage se necessário

## Verificação Rápida

Após executar o script, execute esta query para verificar:

```sql
SELECT 
    id,
    filename,
    image_url,
    CASE 
        WHEN image_url LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%' 
             AND LENGTH(image_url) > 90 THEN '✅ OK'
        ELSE '❌ PROBLEMA'
    END as status
FROM public.gallery_images;
```

Todas devem mostrar ✅ OK.

## Se Ainda Não Funcionar

1. Verifique se os ficheiros existem no Storage:
   - Supabase Dashboard → Storage → gallery-images
   - Confirme que os ficheiros listados correspondem aos `filename` na base de dados

2. Teste uma URL diretamente:
   - Copie uma `image_url` da base de dados
   - Cole no browser
   - Se abrir a imagem → URLs estão corretas
   - Se der erro 404 → ficheiro não existe no storage

