-- =====================================================
-- SCRIPT: CORRIGIR URLs DAS IMAGENS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- CORRIGIR file_path DAS IMAGENS
-- =====================================================

-- Atualizar file_path para remover duplicação
UPDATE public.gallery_images 
SET file_path = REPLACE(file_path, 'gallery-images/gallery-images/', 'gallery-images/')
WHERE file_path LIKE 'gallery-images/gallery-images/%';

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Mostrar file_path corrigidos
SELECT 
  'File Paths Corrigidos:' as info,
  id,
  filename,
  file_path,
  is_visible
FROM public.gallery_images 
ORDER BY created_at DESC;

-- =====================================================
-- TESTAR URLs
-- =====================================================

-- Mostrar URLs que serão geradas
SELECT 
  'URLs que serão geradas:' as info,
  filename,
  file_path,
  'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || 
  CASE 
    WHEN file_path LIKE 'gallery-images/%' THEN SPLIT_PART(file_path, '/', 2)
    ELSE file_path
  END as url_gerada
FROM public.gallery_images 
WHERE is_visible = true
ORDER BY sort_order;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ File paths corrigidos (sem duplicação)
-- ✅ URLs geradas corretamente
-- ✅ Imagens devem aparecer na galeria
-- 
-- =====================================================
