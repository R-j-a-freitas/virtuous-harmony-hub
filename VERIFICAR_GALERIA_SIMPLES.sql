-- =====================================================
-- SCRIPT SIMPLES: VERIFICAR GALERIA
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- VERIFICAR IMAGENS NA BASE DE DADOS
-- =====================================================

SELECT 
  'Imagens na Base de Dados:' as info,
  id,
  filename,
  file_path,
  is_visible,
  created_at
FROM public.gallery_images 
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- VERIFICAR ARQUIVOS NO STORAGE (SIMPLES)
-- =====================================================

SELECT 
  'Arquivos no Storage:' as info,
  name,
  bucket_id,
  created_at
FROM storage.objects 
WHERE bucket_id = 'gallery-images'
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- CONTAR IMAGENS VISÍVEIS
-- =====================================================

SELECT 
  'Imagens Visíveis:' as info,
  COUNT(*) as total_visiveis
FROM public.gallery_images 
WHERE is_visible = true;

-- =====================================================
-- CONTAR TOTAL DE IMAGENS
-- =====================================================

SELECT 
  'Total de Imagens:' as info,
  COUNT(*) as total_imagens
FROM public.gallery_images;

-- =====================================================
-- CONTAR ARQUIVOS NO STORAGE
-- =====================================================

SELECT 
  'Arquivos no Storage:' as info,
  COUNT(*) as total_arquivos
FROM storage.objects 
WHERE bucket_id = 'gallery-images';

-- =====================================================
-- RESUMO FINAL
-- =====================================================

SELECT 
  'RESUMO FINAL:' as info,
  (SELECT COUNT(*) FROM public.gallery_images) as imagens_na_db,
  (SELECT COUNT(*) FROM storage.objects WHERE bucket_id = 'gallery-images') as arquivos_no_storage,
  (SELECT COUNT(*) FROM public.gallery_images WHERE is_visible = true) as imagens_visiveis;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- Se tudo estiver correto:
-- ✅ Imagens na DB: 7
-- ✅ Arquivos no Storage: 7 (ou mais)
-- ✅ Imagens visíveis: 5
-- 
-- Se houver problemas:
-- ❌ Imagens na DB mas não no Storage = problema de upload
-- ❌ Arquivos no Storage mas não na DB = problema de sincronização
-- 
-- =====================================================
