-- =====================================================
-- SCRIPT: CRIAR IMAGENS DE TESTE NO STORAGE
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- VERIFICAR BUCKET
-- =====================================================

-- Verificar se o bucket existe
SELECT 
  'Bucket Status:' as info,
  id,
  name,
  public,
  created_at
FROM storage.buckets
WHERE name = 'gallery-images';

-- =====================================================
-- VERIFICAR ARQUIVOS EXISTENTES
-- =====================================================

-- Verificar arquivos no storage
SELECT 
  'Arquivos no Storage:' as info,
  name,
  bucket_id,
  created_at
FROM storage.objects 
WHERE bucket_id = 'gallery-images'
ORDER BY created_at DESC;

-- =====================================================
-- CRIAR IMAGENS DE TESTE SE NÃO EXISTIREM
-- =====================================================

-- Inserir imagens de teste na base de dados
INSERT INTO public.gallery_images (
  filename,
  original_name,
  file_path,
  file_size,
  mime_type,
  width,
  height,
  alt_text,
  caption,
  is_visible,
  sort_order
)
SELECT 
  'exemplo-1.jpg',
  'exemplo-1.jpg',
  'gallery-images/exemplo-1.jpg',
  500000,
  'image/jpeg',
  800,
  600,
  'Casamento elegante no jardim',
  'Um casamento elegante realizado em um belo jardim',
  true,
  1
WHERE NOT EXISTS (
  SELECT 1 FROM public.gallery_images 
  WHERE filename = 'exemplo-1.jpg'
);

INSERT INTO public.gallery_images (
  filename,
  original_name,
  file_path,
  file_size,
  mime_type,
  width,
  height,
  alt_text,
  caption,
  is_visible,
  sort_order
)
SELECT 
  'exemplo-2.jpg',
  'exemplo-2.jpg',
  'gallery-images/exemplo-2.jpg',
  450000,
  'image/jpeg',
  800,
  600,
  'Evento corporativo',
  'Evento corporativo elegante',
  true,
  2
WHERE NOT EXISTS (
  SELECT 1 FROM public.gallery_images 
  WHERE filename = 'exemplo-2.jpg'
);

INSERT INTO public.gallery_images (
  filename,
  original_name,
  file_path,
  file_size,
  mime_type,
  width,
  height,
  alt_text,
  caption,
  is_visible,
  sort_order
)
SELECT 
  'teste-exemplo.jpg',
  'teste-exemplo.jpg',
  'gallery-images/teste-exemplo.jpg',
  400000,
  'image/jpeg',
  800,
  600,
  'Imagem de teste para galeria',
  'Esta é uma imagem de exemplo para testar o sistema de galeria',
  true,
  3
WHERE NOT EXISTS (
  SELECT 1 FROM public.gallery_images 
  WHERE filename = 'teste-exemplo.jpg'
);

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Mostrar imagens criadas
SELECT 
  'Imagens na Base de Dados:' as info,
  id,
  filename,
  file_path,
  alt_text,
  is_visible,
  sort_order
FROM public.gallery_images 
ORDER BY sort_order;

-- =====================================================
-- GERAR URLs PARA TESTE
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
-- INSTRUÇÕES PARA UPLOAD MANUAL
-- =====================================================
-- 
-- 1. Acesse o Supabase Dashboard
-- 2. Vá para Storage > gallery-images
-- 3. Faça upload das seguintes imagens:
--    - exemplo-1.jpg
--    - exemplo-2.jpg  
--    - teste-exemplo.jpg
-- 4. Ou use qualquer imagem JPG que tenha
-- 5. Teste as URLs geradas acima
-- 
-- =====================================================
