-- =====================================================
-- CORRIGIR URLs TRUNCADAS - SOLUÇÃO FINAL
-- =====================================================
-- Este script corrige TODAS as URLs que estão truncadas
-- Execute no SQL Editor do Supabase

-- =====================================================
-- 1. IDENTIFICAR URLs TRUNCADAS
-- =====================================================

-- Mostrar todas as URLs truncadas ou problemáticas
SELECT 
    id,
    filename,
    file_path,
    image_url as url_atual,
    LENGTH(image_url) as tamanho_url,
    '❌ TRUNCADA' as status
FROM public.gallery_images
WHERE image_url LIKE '%/ga%'
   OR image_url LIKE '%/gallery-images/%' AND image_url NOT LIKE '%/' || COALESCE(file_path, filename, '') || '%'
   OR LENGTH(image_url) < 90
ORDER BY created_at DESC;

-- =====================================================
-- 2. CORRIGIR TODAS AS URLs USANDO filename/file_path
-- =====================================================

-- Limpar todas as URLs truncadas ou malformadas
UPDATE public.gallery_images
SET image_url = NULL
WHERE image_url LIKE '%/ga%'
   OR image_url LIKE '%/gallery-images/%' AND image_url NOT LIKE '%/' || COALESCE(file_path, filename, '') || '%'
   OR LENGTH(image_url) < 90
   OR image_url NOT LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%';

-- Reconstruir URLs corretamente usando file_path
UPDATE public.gallery_images
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || file_path
WHERE (image_url IS NULL OR image_url = '')
  AND file_path IS NOT NULL
  AND file_path != ''
  AND file_path NOT LIKE 'gallery-images/%';

-- Se file_path não existir, usar filename
UPDATE public.gallery_images
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || filename
WHERE (image_url IS NULL OR image_url = '')
  AND (file_path IS NULL OR file_path = '')
  AND filename IS NOT NULL
  AND filename != ''
  AND filename NOT LIKE 'gallery-images/%';

-- =====================================================
-- 3. VERIFICAR RESULTADO
-- =====================================================

-- Mostrar todas as imagens com URLs corrigidas
SELECT 
    id,
    filename,
    file_path,
    image_url as url_corrigida,
    LENGTH(image_url) as tamanho_url,
    CASE 
        WHEN image_url LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%' 
             AND image_url LIKE '%/' || COALESCE(file_path, filename, '') || '%'
             AND LENGTH(image_url) > 90 THEN '✅ CORRETA'
        WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM URL'
        ELSE '⚠️ VERIFICAR'
    END as status_final,
    is_visible
FROM public.gallery_images
ORDER BY created_at DESC;

-- =====================================================
-- 4. TESTE RÁPIDO
-- =====================================================

-- Mostrar URLs para teste manual (copiar e colar no browser)
SELECT 
    id,
    filename,
    'URL para teste: ' || image_url as url_para_testar
FROM public.gallery_images
WHERE is_visible = true
  AND image_url IS NOT NULL
  AND image_url != ''
ORDER BY display_order, created_at DESC
LIMIT 5;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- ✅ Todas as URLs devem estar completas
-- ✅ URLs devem terminar com o nome do ficheiro (ex: .../1761773632590_ymvblr.jpeg)
-- ✅ Todas devem mostrar ✅ CORRETA no status_final

