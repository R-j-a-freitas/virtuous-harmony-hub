-- =====================================================
-- LIMPAR REGISTOS DE IMAGENS QUE NÃO EXISTEM NO STORAGE
-- =====================================================
-- Este script remove da BD as imagens que não têm ficheiros no storage

-- =====================================================
-- 1. VERIFICAR QUAIS IMAGENS EXISTEM NO STORAGE
-- =====================================================

-- Listar ficheiros que realmente existem no storage
SELECT 
    name as filename_no_storage,
    created_at
FROM storage.objects
WHERE bucket_id = 'gallery-images'
ORDER BY created_at DESC;

-- =====================================================
-- 2. IDENTIFICAR REGISTOS NA BD SEM FICHEIROS NO STORAGE
-- =====================================================

-- Mostrar imagens na BD que NÃO têm ficheiros correspondentes no storage
SELECT 
    gi.id,
    gi.filename,
    gi.file_path,
    gi.image_url,
    gi.is_visible,
    '❌ NÃO EXISTE NO STORAGE' as status
FROM public.gallery_images gi
WHERE NOT EXISTS (
    SELECT 1 
    FROM storage.objects so 
    WHERE so.bucket_id = 'gallery-images' 
    AND (so.name = gi.file_path OR so.name = gi.filename)
)
ORDER BY gi.created_at DESC;

-- =====================================================
-- 3. OPÇÃO 1: DELETAR REGISTOS SEM FICHEIROS
-- =====================================================
-- DESCOMENTE AS LINHAS ABAIXO SE QUISER DELETAR AUTOMATICAMENTE

-- DELETE FROM public.gallery_images
-- WHERE NOT EXISTS (
--     SELECT 1 
--     FROM storage.objects so 
--     WHERE so.bucket_id = 'gallery-images' 
--     AND (so.name = file_path OR so.name = filename)
-- );

-- =====================================================
-- 4. OPÇÃO 2: MARCAR COMO OCULTO (RECOMENDADO)
-- =====================================================
-- Marca como não visível em vez de deletar (permite recuperar depois)

UPDATE public.gallery_images
SET is_visible = false
WHERE NOT EXISTS (
    SELECT 1 
    FROM storage.objects so 
    WHERE so.bucket_id = 'gallery-images' 
    AND (so.name = file_path OR so.name = filename)
);

-- =====================================================
-- 5. ADICIONAR IMAGENS DO STORAGE QUE NÃO ESTÃO NA BD
-- =====================================================

-- Inserir na BD as imagens que existem no storage mas não estão na BD
INSERT INTO public.gallery_images (
    filename,
    original_name,
    file_path,
    file_size,
    mime_type,
    image_url,
    is_visible,
    display_order,
    created_at
)
SELECT 
    so.name as filename,
    so.name as original_name, -- Usar o nome do ficheiro como original_name também
    so.name as file_path,
    COALESCE((so.metadata->>'size')::integer, 0) as file_size, -- Extrair tamanho do metadata ou usar 0
    COALESCE(so.metadata->>'mimetype', 'image/jpeg') as mime_type, -- Extrair mimetype ou usar padrão
    'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || so.name as image_url,
    true as is_visible,
    0 as display_order,
    so.created_at
FROM storage.objects so
WHERE so.bucket_id = 'gallery-images'
AND NOT EXISTS (
    SELECT 1 
    FROM public.gallery_images gi
    WHERE gi.file_path = so.name OR gi.filename = so.name
)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. ATUALIZAR URLs DAS IMAGENS EXISTENTES
-- =====================================================

-- Garantir que todas as imagens que existem no storage têm URLs corretas
-- Primeiro, limpar URLs truncadas ou malformadas
UPDATE public.gallery_images
SET image_url = NULL
WHERE image_url LIKE '%/ga%'
   OR image_url LIKE '%/gallery-images/%' AND image_url NOT LIKE '%/' || COALESCE(file_path, filename, '') || '%'
   OR LENGTH(image_url) < 90
   OR image_url NOT LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%';

-- Reconstruir URLs corretamente para todas as imagens que existem no storage
UPDATE public.gallery_images gi
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || COALESCE(gi.file_path, gi.filename)
FROM storage.objects so
WHERE so.bucket_id = 'gallery-images'
AND (so.name = gi.file_path OR so.name = gi.filename)
AND (gi.image_url IS NULL 
     OR gi.image_url = ''
     OR gi.image_url LIKE '%/ga%'
     OR gi.image_url NOT LIKE '%/' || COALESCE(gi.file_path, gi.filename) || '%');

-- Também corrigir URLs para imagens que não estão no storage (usar filename/file_path mesmo assim)
UPDATE public.gallery_images
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || COALESCE(file_path, filename)
WHERE (image_url IS NULL OR image_url = '' OR image_url LIKE '%/ga%')
  AND COALESCE(file_path, filename) IS NOT NULL
  AND COALESCE(file_path, filename) != '';

-- =====================================================
-- 7. VERIFICAR RESULTADO FINAL
-- =====================================================

-- Mostrar todas as imagens visíveis com verificação
SELECT 
    gi.id,
    gi.title,
    gi.filename,
    gi.file_path,
    gi.image_url,
    gi.is_visible,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM storage.objects so 
            WHERE so.bucket_id = 'gallery-images' 
            AND (so.name = gi.file_path OR so.name = gi.filename)
        ) THEN '✅ EXISTE NO STORAGE'
        ELSE '❌ NÃO EXISTE NO STORAGE'
    END as status_storage
FROM public.gallery_images gi
WHERE gi.is_visible = true
ORDER BY gi.display_order, gi.created_at DESC;

