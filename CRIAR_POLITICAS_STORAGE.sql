-- =====================================================
-- SCRIPT PARA CRIAR POLÍTICAS DE STORAGE AUTOMATICAMENTE
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- TENTAR CRIAR POLÍTICAS DE STORAGE
-- =====================================================

-- Política 1: Visualizar imagens (público)
DO $$
BEGIN
    BEGIN
        CREATE POLICY "Anyone can view gallery images"
        ON storage.objects
        FOR SELECT
        USING (bucket_id = 'gallery-images');
        
        RAISE NOTICE '✅ Política "Anyone can view gallery images" criada com sucesso';
    EXCEPTION 
        WHEN duplicate_object THEN
            RAISE NOTICE '⚠️ Política "Anyone can view gallery images" já existe';
        WHEN insufficient_privilege THEN
            RAISE NOTICE '❌ Sem permissão para criar política "Anyone can view gallery images"';
    END;
END $$;

-- Política 2: Upload de imagens (apenas admins)
DO $$
BEGIN
    BEGIN
        CREATE POLICY "Admins can upload gallery images"
        ON storage.objects
        FOR INSERT
        WITH CHECK (
            bucket_id = 'gallery-images' AND 
            public.is_admin()
        );
        
        RAISE NOTICE '✅ Política "Admins can upload gallery images" criada com sucesso';
    EXCEPTION 
        WHEN duplicate_object THEN
            RAISE NOTICE '⚠️ Política "Admins can upload gallery images" já existe';
        WHEN insufficient_privilege THEN
            RAISE NOTICE '❌ Sem permissão para criar política "Admins can upload gallery images"';
    END;
END $$;

-- Política 3: Atualizar imagens (apenas admins)
DO $$
BEGIN
    BEGIN
        CREATE POLICY "Admins can update gallery images"
        ON storage.objects
        FOR UPDATE
        USING (
            bucket_id = 'gallery-images' AND 
            public.is_admin()
        );
        
        RAISE NOTICE '✅ Política "Admins can update gallery images" criada com sucesso';
    EXCEPTION 
        WHEN duplicate_object THEN
            RAISE NOTICE '⚠️ Política "Admins can update gallery images" já existe';
        WHEN insufficient_privilege THEN
            RAISE NOTICE '❌ Sem permissão para criar política "Admins can update gallery images"';
    END;
END $$;

-- Política 4: Deletar imagens (apenas admins)
DO $$
BEGIN
    BEGIN
        CREATE POLICY "Admins can delete gallery images"
        ON storage.objects
        FOR DELETE
        USING (
            bucket_id = 'gallery-images' AND 
            public.is_admin()
        );
        
        RAISE NOTICE '✅ Política "Admins can delete gallery images" criada com sucesso';
    EXCEPTION 
        WHEN duplicate_object THEN
            RAISE NOTICE '⚠️ Política "Admins can delete gallery images" já existe';
        WHEN insufficient_privilege THEN
            RAISE NOTICE '❌ Sem permissão para criar política "Admins can delete gallery images"';
    END;
END $$;

-- =====================================================
-- VERIFICAR POLÍTICAS CRIADAS
-- =====================================================

-- Listar todas as políticas de storage
SELECT 
    'Políticas de Storage:' as info,
    policyname,
    cmd,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'storage' 
    AND tablename = 'objects'
    AND policyname LIKE '%gallery%'
ORDER BY policyname;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- Se funcionar:
-- ✅ Todas as 4 políticas serão criadas
-- ✅ Sistema de galeria totalmente funcional
-- 
-- Se não funcionar:
-- ❌ Mensagens de "Sem permissão"
-- ⚠️ Necessário criar manualmente no Dashboard
-- 
-- =====================================================
