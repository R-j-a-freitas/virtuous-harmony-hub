# Solução Completa para Problema de Imagens

## Problema Identificado

1. ✅ As imagens fazem upload para o storage corretamente
2. ❌ Mas a base de dados tem registos de imagens que **não existem no storage**
3. ❌ Quando tentas aceder a essas imagens, dá erro 404

## Causa Raiz

Os registos na base de dados foram criados **sem fazer upload para o storage**, ou os ficheiros foram eliminados do storage mas os registos ficaram na BD.

## Solução (3 Passos)

### Passo 1: Limpar Registos Inexistentes

Execute o script **`LIMPAR_IMAGENS_INEXISTENTES.sql`** no Supabase SQL Editor.

Este script:
- ✅ Identifica imagens na BD que não têm ficheiros no storage
- ✅ Marca como ocultas (em vez de deletar)
- ✅ Adiciona ao BD as imagens que existem no storage mas não estão na BD
- ✅ Corrige URLs de todas as imagens existentes

**Resultado esperado:** Apenas imagens que realmente existem no storage aparecerão.

### Passo 2: Verificar Upload no Admin

O código de upload foi melhorado com:
- ✅ Melhor tratamento de erros
- ✅ Logs detalhados no console
- ✅ Verificação se upload foi bem-sucedido
- ✅ Guarda `filename` e `file_path` na BD

**Teste:** Fazer upload de uma nova imagem pelo admin e verificar:
1. Aparece no storage (Supabase Dashboard → Storage → gallery-images)
2. Aparece na BD com URL correta
3. Aparece no site e no admin

### Passo 3: Recarregar Páginas

Após executar o script SQL:
1. Recarregue a página do admin (F5)
2. Recarregue a página do site
3. As imagens devem aparecer agora!

## Como Verificar se Funciona

### Verificar no Supabase:

```sql
-- Verificar sincronização entre BD e Storage
SELECT 
    gi.id,
    gi.filename,
    gi.is_visible,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM storage.objects so 
            WHERE so.bucket_id = 'gallery-images' 
            AND so.name = gi.filename
        ) THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status
FROM public.gallery_images gi
WHERE gi.is_visible = true;
```

Todas devem mostrar ✅ EXISTE.

### Verificar no Browser:

1. Abrir uma `image_url` da BD diretamente no browser
2. Se a imagem abrir → ✅ URL está correta
3. Se der 404 → ❌ Ficheiro não existe no storage

## Prevenção Futura

**Sempre que fizer upload pelo admin:**
1. O código automaticamente faz upload para o storage
2. Depois cria registo na BD com URL correta
3. Se o upload falhar, o registo não é criado

**Se criar imagens manualmente:**
- Certifique-se de fazer upload para o storage ANTES de criar registo na BD
- Ou use o script `LIMPAR_IMAGENS_INEXISTENTES.sql` para sincronizar

## Resolução de Problemas

**Imagens ainda não aparecem?**
1. Verifique no Console do Browser (F12) → erros de CORS ou 404
2. Verifique no Supabase Storage → os ficheiros existem?
3. Execute novamente `LIMPAR_IMAGENS_INEXISTENTES.sql`

**Upload falha?**
1. Verifique políticas RLS no storage
2. Verifique se bucket `gallery-images` existe e é público
3. Verifique Console do Browser para mensagens de erro

