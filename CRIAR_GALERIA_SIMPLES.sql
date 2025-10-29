-- =====================================================
-- SCRIPT SIMPLES: CRIAR TABELA GALERIA BÁSICA
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. CRIAR TABELA BÁSICA
-- =====================================================

-- Criar tabela para gestão de imagens da galeria
CREATE TABLE IF NOT EXISTS public.gallery_images (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  filename TEXT NOT NULL,
  original_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  mime_type TEXT NOT NULL,
  width INTEGER,
  height INTEGER,
  alt_text TEXT,
  caption TEXT,
  is_visible BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  uploaded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- =====================================================
-- 2. HABILITAR RLS
-- =====================================================

ALTER TABLE public.gallery_images ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICAS BÁSICAS
-- =====================================================

-- Política: Qualquer pessoa pode ver imagens visíveis
CREATE POLICY "Anyone can view visible gallery images"
ON public.gallery_images
FOR SELECT
USING (is_visible = true);

-- Política: Apenas admins podem ver todas as imagens
CREATE POLICY "Admins can view all gallery images"
ON public.gallery_images
FOR SELECT
USING (public.is_admin());

-- Política: Apenas admins podem inserir imagens
CREATE POLICY "Admins can insert gallery images"
ON public.gallery_images
FOR INSERT
WITH CHECK (public.is_admin());

-- Política: Apenas admins podem atualizar imagens
CREATE POLICY "Admins can update gallery images"
ON public.gallery_images
FOR UPDATE
USING (public.is_admin());

-- Política: Apenas admins podem deletar imagens
CREATE POLICY "Admins can delete gallery images"
ON public.gallery_images
FOR DELETE
USING (public.is_admin());

-- =====================================================
-- 4. CRIAR STORAGE BUCKET
-- =====================================================

-- Criar bucket para imagens da galeria
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'gallery-images',
  'gallery-images',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 5. POLÍTICAS DE STORAGE
-- =====================================================

-- Política: Qualquer pessoa pode ver imagens públicas
CREATE POLICY "Anyone can view gallery images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'gallery-images');

-- Política: Apenas admins podem fazer upload
CREATE POLICY "Admins can upload gallery images"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'gallery-images' AND 
  public.is_admin()
);

-- Política: Apenas admins podem atualizar imagens
CREATE POLICY "Admins can update gallery images"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'gallery-images' AND 
  public.is_admin()
);

-- Política: Apenas admins podem deletar imagens
CREATE POLICY "Admins can delete gallery images"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'gallery-images' AND 
  public.is_admin()
);

-- =====================================================
-- 6. INSERIR IMAGEM DE EXEMPLO
-- =====================================================

-- Inserir uma imagem de exemplo para teste
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
) VALUES 
(
  'exemplo-1.jpg',
  'casamento-exemplo-1.jpg',
  'gallery-images/exemplo-1.jpg',
  1024000,
  'image/jpeg',
  1920,
  1080,
  'Casamento elegante no jardim',
  'Celebração de casamento ao ar livre com decoração floral',
  true,
  1
);

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se a tabela foi criada
SELECT 
  '✅ TABELA GALERIA CRIADA COM SUCESSO!' as status,
  COUNT(*) as total_images,
  COUNT(CASE WHEN is_visible = true THEN 1 END) as visible_images,
  COUNT(CASE WHEN is_visible = false THEN 1 END) as hidden_images
FROM public.gallery_images;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Tabela gallery_images criada
-- ✅ RLS habilitado com políticas seguras
-- ✅ Storage bucket criado
-- ✅ Políticas de storage configuradas
-- ✅ Imagem de exemplo inserida
-- ✅ Sistema básico de galeria funcional
-- 
-- =====================================================
