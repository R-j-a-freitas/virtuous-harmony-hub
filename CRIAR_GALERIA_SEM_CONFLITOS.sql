-- =====================================================
-- SCRIPT ULTRA SIMPLES: GALERIA SEM CONFLITOS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. CRIAR TABELA (SE NÃO EXISTIR)
-- =====================================================

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
-- 2. HABILITAR RLS (SE NÃO ESTIVER HABILITADO)
-- =====================================================

ALTER TABLE public.gallery_images ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. CRIAR STORAGE BUCKET (SE NÃO EXISTIR)
-- =====================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'gallery-images',
  'gallery-images',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 4. VERIFICAR E CRIAR POLÍTICAS (SEM CONFLITOS)
-- =====================================================

-- Verificar se as políticas já existem e criar apenas as que faltam
DO $$
BEGIN
    -- Política para visualizar imagens visíveis
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'gallery_images' 
        AND policyname = 'Anyone can view visible gallery images'
    ) THEN
        CREATE POLICY "Anyone can view visible gallery images"
        ON public.gallery_images
        FOR SELECT
        USING (is_visible = true);
    END IF;

    -- Política para admins verem todas as imagens
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'gallery_images' 
        AND policyname = 'Admins can view all gallery images'
    ) THEN
        CREATE POLICY "Admins can view all gallery images"
        ON public.gallery_images
        FOR SELECT
        USING (public.is_admin());
    END IF;

    -- Política para admins inserirem imagens
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'gallery_images' 
        AND policyname = 'Admins can insert gallery images'
    ) THEN
        CREATE POLICY "Admins can insert gallery images"
        ON public.gallery_images
        FOR INSERT
        WITH CHECK (public.is_admin());
    END IF;

    -- Política para admins atualizarem imagens
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'gallery_images' 
        AND policyname = 'Admins can update gallery images'
    ) THEN
        CREATE POLICY "Admins can update gallery images"
        ON public.gallery_images
        FOR UPDATE
        USING (public.is_admin());
    END IF;

    -- Política para admins deletarem imagens
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'gallery_images' 
        AND policyname = 'Admins can delete gallery images'
    ) THEN
        CREATE POLICY "Admins can delete gallery images"
        ON public.gallery_images
        FOR DELETE
        USING (public.is_admin());
    END IF;
END $$;

-- =====================================================
-- 5. VERIFICAR E CRIAR POLÍTICAS DE STORAGE
-- =====================================================

DO $$
BEGIN
    -- Política para visualizar imagens no storage
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Anyone can view gallery images'
    ) THEN
        CREATE POLICY "Anyone can view gallery images"
        ON storage.objects
        FOR SELECT
        USING (bucket_id = 'gallery-images');
    END IF;

    -- Política para admins fazerem upload
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Admins can upload gallery images'
    ) THEN
        CREATE POLICY "Admins can upload gallery images"
        ON storage.objects
        FOR INSERT
        WITH CHECK (
          bucket_id = 'gallery-images' AND 
          public.is_admin()
        );
    END IF;

    -- Política para admins atualizarem imagens no storage
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Admins can update gallery images'
    ) THEN
        CREATE POLICY "Admins can update gallery images"
        ON storage.objects
        FOR UPDATE
        USING (
          bucket_id = 'gallery-images' AND 
          public.is_admin()
        );
    END IF;

    -- Política para admins deletarem imagens no storage
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Admins can delete gallery images'
    ) THEN
        CREATE POLICY "Admins can delete gallery images"
        ON storage.objects
        FOR DELETE
        USING (
          bucket_id = 'gallery-images' AND 
          public.is_admin()
        );
    END IF;
END $$;

-- =====================================================
-- 6. INSERIR IMAGEM DE EXEMPLO (SE NÃO EXISTIR)
-- =====================================================

-- Verificar se já existe uma imagem de exemplo antes de inserir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.gallery_images 
        WHERE filename = 'exemplo-1.jpg'
    ) THEN
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
        ) VALUES (
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
    END IF;
END $$;

-- =====================================================
-- 7. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se tudo foi criado corretamente
SELECT 
  '✅ SISTEMA DE GALERIA CONFIGURADO COM SUCESSO!' as status,
  COUNT(*) as total_images,
  COUNT(CASE WHEN is_visible = true THEN 1 END) as visible_images,
  COUNT(CASE WHEN is_visible = false THEN 1 END) as hidden_images
FROM public.gallery_images;

-- Verificar políticas criadas
SELECT 
  'Políticas da tabela gallery_images:' as info,
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'gallery_images'
ORDER BY policyname;

-- Verificar bucket de storage
SELECT 
  'Bucket de storage:' as info,
  id,
  name,
  public
FROM storage.buckets 
WHERE id = 'gallery-images';

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Tabela gallery_images criada/verificada
-- ✅ RLS habilitado
-- ✅ Storage bucket criado/verificado
-- ✅ Políticas criadas sem conflitos
-- ✅ Imagem de exemplo inserida
-- ✅ Sistema de galeria totalmente funcional
-- 
-- =====================================================
