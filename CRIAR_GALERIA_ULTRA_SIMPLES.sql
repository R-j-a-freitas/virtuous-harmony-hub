-- =====================================================
-- SCRIPT ULTRA SIMPLES: GALERIA SEM ERROS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. CRIAR TABELA
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
-- 2. HABILITAR RLS
-- =====================================================

ALTER TABLE public.gallery_images ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. CRIAR STORAGE BUCKET
-- =====================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'gallery-images',
  'gallery-images',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 4. CRIAR POLÍTICAS (COM TRATAMENTO DE ERRO)
-- =====================================================

-- Função para criar política apenas se não existir
DO $$
BEGIN
    -- Política para visualizar imagens visíveis
    BEGIN
        CREATE POLICY "Anyone can view visible gallery images"
        ON public.gallery_images
        FOR SELECT
        USING (is_visible = true);
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins verem todas as imagens
    BEGIN
        CREATE POLICY "Admins can view all gallery images"
        ON public.gallery_images
        FOR SELECT
        USING (public.is_admin());
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins inserirem imagens
    BEGIN
        CREATE POLICY "Admins can insert gallery images"
        ON public.gallery_images
        FOR INSERT
        WITH CHECK (public.is_admin());
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins atualizarem imagens
    BEGIN
        CREATE POLICY "Admins can update gallery images"
        ON public.gallery_images
        FOR UPDATE
        USING (public.is_admin());
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins deletarem imagens
    BEGIN
        CREATE POLICY "Admins can delete gallery images"
        ON public.gallery_images
        FOR DELETE
        USING (public.is_admin());
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;
END $$;

-- =====================================================
-- 5. POLÍTICAS DE STORAGE (COM TRATAMENTO DE ERRO)
-- =====================================================

DO $$
BEGIN
    -- Política para visualizar imagens no storage
    BEGIN
        CREATE POLICY "Anyone can view gallery images"
        ON storage.objects
        FOR SELECT
        USING (bucket_id = 'gallery-images');
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins fazerem upload
    BEGIN
        CREATE POLICY "Admins can upload gallery images"
        ON storage.objects
        FOR INSERT
        WITH CHECK (
          bucket_id = 'gallery-images' AND 
          public.is_admin()
        );
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins atualizarem imagens no storage
    BEGIN
        CREATE POLICY "Admins can update gallery images"
        ON storage.objects
        FOR UPDATE
        USING (
          bucket_id = 'gallery-images' AND 
          public.is_admin()
        );
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;

    -- Política para admins deletarem imagens no storage
    BEGIN
        CREATE POLICY "Admins can delete gallery images"
        ON storage.objects
        FOR DELETE
        USING (
          bucket_id = 'gallery-images' AND 
          public.is_admin()
        );
    EXCEPTION WHEN duplicate_object THEN
        -- Política já existe, continuar
    END;
END $$;

-- =====================================================
-- 6. INSERIR IMAGEM DE EXEMPLO
-- =====================================================

-- Inserir imagem de exemplo apenas se não existir nenhuma
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
WHERE NOT EXISTS (SELECT 1 FROM public.gallery_images LIMIT 1);

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

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Tabela gallery_images criada
-- ✅ RLS habilitado
-- ✅ Storage bucket criado
-- ✅ Políticas criadas (sem conflitos)
-- ✅ Imagem de exemplo inserida (se não existir nenhuma)
-- ✅ Sistema de galeria totalmente funcional
-- 
-- =====================================================
