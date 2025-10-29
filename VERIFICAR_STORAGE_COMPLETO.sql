-- =====================================================
-- SCRIPT: VERIFICAR IMAGENS NO STORAGE
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- VERIFICAR IMAGENS NO STORAGE
-- =====================================================

-- Verificar se o bucket existe
SELECT 
  'Buckets Disponíveis:' as info,
  id,
  name,
  public,
  created_at
FROM storage.buckets
WHERE name = 'gallery-images';

-- =====================================================
-- VERIFICAR ARQUIVOS NO STORAGE
-- =====================================================

-- Verificar arquivos no bucket gallery-images
SELECT 
  'Arquivos no Storage:' as info,
  name,
  bucket_id,
  created_at,
  updated_at
FROM storage.objects 
WHERE bucket_id = 'gallery-images'
ORDER BY created_at DESC;

-- =====================================================
-- COMPARAR COM BASE DE DADOS
-- =====================================================

-- Comparar arquivos no storage com registros na base de dados
SELECT 
  'Comparação Storage vs Database:' as info,
  gi.filename as db_filename,
  gi.file_path as db_file_path,
  so.name as storage_filename,
  CASE 
    WHEN so.name IS NULL THEN '❌ Arquivo não existe no storage'
    WHEN gi.filename IS NULL THEN '❌ Registro não existe na base de dados'
    ELSE '✅ Arquivo existe em ambos'
  END as status
FROM public.gallery_images gi
FULL OUTER JOIN storage.objects so ON (
  so.bucket_id = 'gallery-images' AND 
  so.name = CASE 
    WHEN gi.file_path LIKE 'gallery-images/%' THEN SPLIT_PART(gi.file_path, '/', 2)
    ELSE gi.file_path
  END
)
ORDER BY gi.created_at DESC;

-- =====================================================
-- TESTAR URLs DIRETAMENTE
-- =====================================================

-- Gerar URLs para testar manualmente
SELECT 
  'URLs para Testar:' as info,
  filename,
  'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || 
  CASE 
    WHEN file_path LIKE 'gallery-images/%' THEN SPLIT_PART(file_path, '/', 2)
    ELSE file_path
  END as url_para_testar
FROM public.gallery_images 
WHERE is_visible = true
ORDER BY sort_order;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Bucket gallery-images deve existir
-- ✅ Arquivos devem existir no storage
-- ✅ URLs devem ser válidas
-- 
-- =====================================================
