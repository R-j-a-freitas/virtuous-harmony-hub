-- Migration: Verificar e configurar pg_cron (executar após a migration anterior)
-- Esta migration verifica se pg_cron está disponível e configura o job

DO $$
DECLARE
    cron_available BOOLEAN := false;
    job_exists BOOLEAN := false;
BEGIN
    -- Verificar se pg_cron está disponível
    BEGIN
        -- Verificar se a extensão está instalada
        SELECT EXISTS (
            SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'
        ) INTO cron_available;
        
        -- Se não estiver, tentar habilitar
        IF NOT cron_available THEN
            BEGIN
                CREATE EXTENSION IF NOT EXISTS pg_cron;
                cron_available := true;
                RAISE NOTICE '✅ Extensão pg_cron habilitada';
            EXCEPTION
                WHEN insufficient_privilege THEN
                    RAISE NOTICE '❌ Permissões insuficientes para habilitar pg_cron';
                    RAISE NOTICE '💡 Solicite ao suporte do Supabase para habilitar pg_cron';
                    cron_available := false;
                WHEN OTHERS THEN
                    RAISE NOTICE '❌ Erro ao habilitar pg_cron: %', SQLERRM;
                    cron_available := false;
            END;
        ELSE
            RAISE NOTICE '✅ pg_cron já está habilitado';
        END IF;
        
        -- Se pg_cron estiver disponível, verificar se o schema existe
        IF cron_available THEN
            BEGIN
                -- Verificar se o schema cron existe
                IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cron') THEN
                    RAISE NOTICE '✅ Schema cron existe';
                    
                    -- Verificar se job já existe
                    BEGIN
                        SELECT EXISTS (
                            SELECT 1 FROM cron.job WHERE jobname = 'keep-db-active-daily'
                        ) INTO job_exists;
                    EXCEPTION
                        WHEN OTHERS THEN
                            job_exists := false;
                            RAISE NOTICE '⚠️ Erro ao verificar jobs existentes: %', SQLERRM;
                    END;
                    
                    -- Remover job existente se houver
                    IF job_exists THEN
                        BEGIN
                            PERFORM cron.unschedule('keep-db-active-daily');
                            RAISE NOTICE '✅ Job existente removido';
                        EXCEPTION
                            WHEN OTHERS THEN
                                RAISE NOTICE '⚠️ Erro ao remover job: %', SQLERRM;
                        END;
                    END IF;
                    
                    -- Criar novo job
                    BEGIN
                        PERFORM cron.schedule(
                            'keep-db-active-daily',
                            '0 2 * * *', -- Todos os dias às 02:00 UTC
                            'SELECT public.keep_db_active();'
                        );
                        RAISE NOTICE '✅ Job pg_cron criado com sucesso: keep-db-active-daily';
                        RAISE NOTICE '📅 Agendado para executar diariamente às 02:00 UTC';
                    EXCEPTION
                        WHEN OTHERS THEN
                            RAISE NOTICE '❌ Erro ao criar job: %', SQLERRM;
                    END;
                ELSE
                    RAISE NOTICE '❌ Schema cron não existe. pg_cron pode não estar totalmente funcional.';
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE NOTICE '❌ Erro ao configurar cron: %', SQLERRM;
            END;
        ELSE
            RAISE NOTICE '';
            RAISE NOTICE '═══════════════════════════════════════════════════════════';
            RAISE NOTICE '⚠️  pg_cron NÃO ESTÁ DISPONÍVEL';
            RAISE NOTICE '═══════════════════════════════════════════════════════════';
            RAISE NOTICE '';
            RAISE NOTICE 'A função keep_db_active() foi criada e pode ser executada manualmente:';
            RAISE NOTICE '  SELECT public.keep_db_active();';
            RAISE NOTICE '';
            RAISE NOTICE 'Para agendar automaticamente:';
            RAISE NOTICE '  1. Contacte o suporte do Supabase';
            RAISE NOTICE '  2. Solicite: "Please enable pg_cron extension"';
            RAISE NOTICE '  3. Após habilitado, execute esta migration novamente';
            RAISE NOTICE '';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '❌ Erro geral: %', SQLERRM;
    END;
END $$;

-- Verificar status final
DO $$
BEGIN
    -- Verificar se a função existe
    IF EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_schema = 'public' AND routine_name = 'keep_db_active'
    ) THEN
        RAISE NOTICE '';
        RAISE NOTICE '✅ Função keep_db_active() está disponível';
    ELSE
        RAISE NOTICE '❌ Função keep_db_active() não encontrada';
    END IF;
    
    -- Verificar se pg_cron está disponível
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cron') THEN
            IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'keep-db-active-daily') THEN
                RAISE NOTICE '✅ Job keep-db-active-daily está agendado';
            ELSE
                RAISE NOTICE '⚠️ Job keep-db-active-daily não foi criado';
            END IF;
        END IF;
    END IF;
END $$;
