-- =====================================================
-- SCRIPT DE VERIFICAÇÃO: STORAGE vs DATABASE
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
-- VERIFICAR ARQUIVOS NO STORAGE
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
-- COMPARAR DATABASE vs STORAGE
-- =====================================================

-- Imagens na DB mas não no Storage
SELECT 
  'Imagens na DB mas NÃO no Storage:' as info,
  gi.filename,
  gi.file_path
FROM public.gallery_images gi
LEFT JOIN storage.objects so ON gi.file_path = so.name
WHERE so.name IS NULL;

-- Arquivos no Storage mas não na DB
SELECT 
  'Arquivos no Storage mas NÃO na DB:' as info,
  so.name,
  so.bucket_id
FROM storage.objects so
LEFT JOIN public.gallery_images gi ON so.name = gi.file_path
WHERE so.bucket_id = 'gallery-images' 
  AND gi.file_path IS NULL;

-- =====================================================
-- RESUMO FINAL
-- =====================================================

SELECT 
  'Resumo Final:' as info,
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
