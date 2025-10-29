-- =====================================================
-- CORRIGIR URLs DAS IMAGENS - SOLUÇÃO DEFINITIVA
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- Este script corrige todas as URLs truncadas ou malformadas

-- =====================================================
-- 1. LIMPAR E CORRIGIR file_path
-- =====================================================

-- Remover 'gallery-images/' do início do file_path se existir
UPDATE public.gallery_images 
SET file_path = REPLACE(file_path, 'gallery-images/', '')
WHERE file_path LIKE 'gallery-images/%';

-- Remover qualquer prefixo inválido
UPDATE public.gallery_images 
SET file_path = TRIM(file_path);

-- =====================================================
-- 2. RECONSTRUIR image_url CORRETAMENTE
-- =====================================================

-- Primeiro, limpar TODAS as URLs que estão malformadas ou truncadas
UPDATE public.gallery_images 
SET image_url = NULL
WHERE image_url IS NULL 
   OR image_url LIKE '%/ga%'
   OR image_url LIKE '%gallery-images/gallery-images%'
   OR image_url NOT LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%'
   OR LENGTH(image_url) < 80; -- URLs muito curtas estão truncadas

-- Agora reconstruir image_url usando file_path
UPDATE public.gallery_images 
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || file_path
WHERE (image_url IS NULL OR image_url = '') 
  AND file_path IS NOT NULL 
  AND file_path != ''
  AND file_path NOT LIKE 'gallery-images/%';

-- Se file_path não existir mas filename existir, usar filename
UPDATE public.gallery_images 
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || filename
WHERE (image_url IS NULL OR image_url = '') 
  AND file_path IS NULL
  AND filename IS NOT NULL 
  AND filename != '';

-- =====================================================
-- 3. VERIFICAR RESULTADOS
-- =====================================================

-- Mostrar todas as imagens com suas URLs
SELECT 
    id,
    title,
    filename,
    file_path,
    CASE 
        WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM URL'
        WHEN image_url LIKE '%/ga%' THEN '❌ URL TRUNCADA'
        WHEN image_url NOT LIKE '%/' || COALESCE(file_path, filename, '') || '%' THEN '⚠️ URL PODE ESTAR INCORRETA'
        ELSE '✅ OK'
    END as status,
    image_url,
    is_visible
FROM public.gallery_images
ORDER BY created_at DESC;

-- =====================================================
-- 4. TESTAR URLs GERADAS
-- =====================================================

-- Mostrar URLs para teste manual
SELECT 
    id,
    title,
    filename,
    file_path,
    image_url as url_completa,
    'Copie e cole esta URL no browser para testar' as instrucao
FROM public.gallery_images
WHERE image_url IS NOT NULL
ORDER BY created_at DESC;

-- =====================================================
-- 5. GARANTIR POLÍTICAS DE STORAGE
-- =====================================================

-- Garantir que bucket é público
UPDATE storage.buckets
SET public = true
WHERE id = 'gallery-images';

-- Remover política antiga se existir e criar nova
DROP POLICY IF EXISTS "Anyone can view gallery images" ON storage.objects;

CREATE POLICY "Anyone can view gallery images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'gallery-images');

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- ✅ Todas as URLs estão corretas e completas
-- ✅ URLs seguem o formato: https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/{filename}
-- ✅ Bucket é público
-- ✅ Política de SELECT existe

