-- =====================================================
-- SCRIPT: CORRIGIR ERRO DE DIGITAÇÃO NO NOME DO ARQUIVO
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- CORRIGIR ERRO DE DIGITAÇÃO
-- =====================================================

-- Corrigir "exemolo" para "exemplo"
UPDATE public.gallery_images 
SET filename = REPLACE(filename, 'exemolo', 'exemplo'),
    file_path = REPLACE(file_path, 'exemolo', 'exemplo')
WHERE filename LIKE '%exemolo%' OR file_path LIKE '%exemolo%';

-- =====================================================
-- VERIFICAR CORREÇÃO
-- =====================================================

-- Mostrar arquivos corrigidos
SELECT 
  'Arquivos Corrigidos:' as info,
  id,
  filename,
  file_path,
  is_visible
FROM public.gallery_images 
WHERE filename LIKE '%exemplo%'
ORDER BY created_at DESC;

-- =====================================================
-- TESTAR URLs CORRIGIDAS
-- =====================================================

-- Mostrar URLs que serão geradas
SELECT 
  'URLs Corrigidas:' as info,
  filename,
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
-- ✅ Erro de digitação corrigido
-- ✅ URLs geradas corretamente
-- ✅ Imagens devem aparecer na galeria
-- 
-- =====================================================
