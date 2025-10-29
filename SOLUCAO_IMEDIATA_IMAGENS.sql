-- =====================================================
-- SOLUÇÃO IMEDIATA PARA IMAGENS NÃO APARECEREM
-- =====================================================
-- Execute este script NO SQL Editor do Supabase
-- Este script corrige TODAS as URLs truncadas/malformadas

-- =====================================================
-- 1. IDENTIFICAR E LIMPAR URLs PROBLEMÁTICAS
-- =====================================================

-- Listar TODAS as URLs para ver o estado atual
SELECT 
    id,
    filename,
    file_path,
    image_url,
    CASE 
        WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM URL'
        WHEN image_url LIKE '%/ga%' OR image_url LIKE '%/gallery-images/ga%' THEN '❌ URL TRUNCADA'
        WHEN image_url NOT LIKE '%/' || COALESCE(NULLIF(file_path, ''), NULLIF(filename, ''), '') || '%' THEN '⚠️ URL INCOMPLETA'
        WHEN LENGTH(image_url) < 90 THEN '⚠️ URL MUITO CURTA'
        ELSE '✅ OK'
    END as status_antes
FROM public.gallery_images
ORDER BY created_at DESC;

-- =====================================================
-- 2. LIMPAR TODAS AS URLs PROBLEMÁTICAS
-- =====================================================

-- Limpar URLs que estão truncadas, malformadas ou muito curtas
UPDATE public.gallery_images 
SET image_url = NULL
WHERE image_url IS NULL 
   OR image_url = ''
   OR image_url LIKE '%/ga%'
   OR image_url LIKE '%/gallery-images/ga%'
   OR image_url LIKE '%/gallery-images/gallery-images%'
   OR image_url NOT LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%'
   OR LENGTH(image_url) < 90;

-- =====================================================
-- 3. RECONSTRUIR URLs USANDO file_path
-- =====================================================

-- Primeiro, corrigir file_path removendo qualquer prefixo inválido
UPDATE public.gallery_images 
SET file_path = REPLACE(file_path, 'gallery-images/', '')
WHERE file_path LIKE 'gallery-images/%';

UPDATE public.gallery_images 
SET file_path = TRIM(file_path);

-- Agora reconstruir image_url usando file_path limpo
UPDATE public.gallery_images 
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || file_path
WHERE (image_url IS NULL OR image_url = '') 
  AND file_path IS NOT NULL 
  AND file_path != ''
  AND file_path NOT LIKE 'gallery-images/%';

-- =====================================================
-- 4. SE file_path ESTIVER VAZIO, USAR filename
-- =====================================================

-- Se file_path não existir mas filename existir, usar filename
UPDATE public.gallery_images 
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || filename
WHERE (image_url IS NULL OR image_url = '') 
  AND (file_path IS NULL OR file_path = '')
  AND filename IS NOT NULL 
  AND filename != ''
  AND filename NOT LIKE 'gallery-images/%';

-- =====================================================
-- 5. VERIFICAR RESULTADO FINAL
-- =====================================================

-- Mostrar todas as imagens com suas URLs corrigidas
SELECT 
    id,
    title,
    filename,
    file_path,
    image_url,
    LENGTH(image_url) as url_length,
    is_visible,
    CASE 
        WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM URL'
        WHEN image_url LIKE '%/ga%' THEN '❌ AINDA TRUNCADA'
        WHEN LENGTH(image_url) < 90 THEN '⚠️ URL CURTA'
        WHEN image_url LIKE 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/%' 
             AND image_url LIKE '%' || COALESCE(NULLIF(file_path, ''), NULLIF(filename, ''), '') || '%' THEN '✅ CORRETA'
        ELSE '⚠️ VERIFICAR'
    END as status_depois
FROM public.gallery_images
ORDER BY created_at DESC;

-- =====================================================
-- 6. GARANTIR POLÍTICAS DE STORAGE (SE NECESSÁRIO)
-- =====================================================

-- Garantir que bucket é público
UPDATE storage.buckets
SET public = true
WHERE id = 'gallery-images';

-- Recriar política de SELECT pública
DROP POLICY IF EXISTS "Anyone can view gallery images" ON storage.objects;

CREATE POLICY "Anyone can view gallery images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'gallery-images');

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- ✅ Todas as URLs estão completas e corretas
-- ✅ URLs seguem formato: https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/{filename}
-- ✅ Bucket é público
-- ✅ Política de SELECT existe
-- ✅ Imagens devem aparecer no site e no admin após recarregar página

