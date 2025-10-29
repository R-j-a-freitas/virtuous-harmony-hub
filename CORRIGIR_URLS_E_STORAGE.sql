-- =====================================================
-- CORRIGIR URLs DAS IMAGENS E VERIFICAR STORAGE
-- =====================================================
-- Este script corrige URLs duplicadas e verifica storage

-- =====================================================
-- 1. CORRIGIR file_path (remover duplicação)
-- =====================================================

-- Remover 'gallery-images/' do início do file_path se existir
UPDATE public.gallery_images 
SET file_path = REPLACE(file_path, 'gallery-images/', '')
WHERE file_path LIKE 'gallery-images/%';

-- =====================================================
-- 2. CORRIGIR image_url (construir corretamente)
-- =====================================================

-- Atualizar image_url com base no file_path corrigido
-- Primeiro, limpar URLs duplicadas ou malformadas
UPDATE public.gallery_images 
SET image_url = NULL
WHERE image_url LIKE '%gallery-images/gallery-images%' 
   OR image_url NOT LIKE 'https://%.supabase.co/storage/v1/object/public/%';

-- Agora construir URLs corretas
UPDATE public.gallery_images 
SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || file_path
WHERE (image_url IS NULL OR image_url = '') 
  AND file_path IS NOT NULL 
  AND file_path != '';

-- =====================================================
-- 3. VERIFICAR POLÍTICAS DE STORAGE
-- =====================================================

-- Verificar se bucket existe e é público
SELECT 
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
FROM storage.buckets
WHERE id = 'gallery-images';

-- Verificar políticas de storage para SELECT (visualização pública)
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'storage'
AND tablename = 'objects'
AND policyname LIKE '%gallery%';

-- =====================================================
-- 4. VERIFICAR ARQUIVOS NO STORAGE
-- =====================================================

-- Listar arquivos no bucket (se tiver permissão)
SELECT 
    name,
    bucket_id,
    created_at,
    metadata
FROM storage.objects
WHERE bucket_id = 'gallery-images'
ORDER BY created_at DESC
LIMIT 20;

-- =====================================================
-- 5. MOSTRAR URLs CORRIGIDAS
-- =====================================================

SELECT 
    id,
    title,
    filename,
    file_path,
    image_url,
    is_visible,
    CASE 
        WHEN image_url LIKE '%gallery-images/gallery-images%' THEN '❌ URL DUPLICADA'
        WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM URL'
        ELSE '✅ OK'
    END as status_url
FROM public.gallery_images
ORDER BY created_at DESC;

-- =====================================================
-- 6. CRIAR/GARANTIR POLÍTICAS DE STORAGE
-- =====================================================

-- Garantir que bucket é público
UPDATE storage.buckets
SET public = true
WHERE id = 'gallery-images';

-- Garantir política de SELECT pública (remover e recriar se necessário)
DROP POLICY IF EXISTS "Anyone can view gallery images" ON storage.objects;

CREATE POLICY "Anyone can view gallery images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'gallery-images');

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- ✅ file_path corrigido (sem duplicação)
-- ✅ image_url atualizado com caminho correto
-- ✅ Bucket é público
-- ✅ Política de SELECT existe e permite acesso público

