-- Migration: Habilitar pg_cron e configurar job de keepalive
-- Esta migration tenta habilitar pg_cron e criar o job agendado

-- Passo 1: Verificar se pg_cron está disponível
DO $$
BEGIN
    -- Tentar habilitar a extensão pg_cron
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    RAISE NOTICE 'Extensão pg_cron habilitada com sucesso';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'Erro: Permissões insuficientes para habilitar pg_cron. Use a alternativa com Database Function.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao habilitar pg_cron: %', SQLERRM;
END $$;

-- Passo 2: Verificar se pg_net está disponível (necessário para chamadas HTTP)
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS pg_net;
    RAISE NOTICE 'Extensão pg_net habilitada com sucesso';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'Erro: Permissões insuficientes para habilitar pg_net.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao habilitar pg_net: %', SQLERRM;
END $$;

-- Passo 3: Criar função SQL que executa o keepalive diretamente na base de dados
-- Esta função não precisa de HTTP, trabalha diretamente com a tabela
CREATE OR REPLACE FUNCTION public.keep_db_active()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    insert_id UUID;
    result jsonb;
BEGIN
    -- Fazer INSERT
    INSERT INTO public.db_keepalive (note)
    VALUES ('Keepalive ping - ' || NOW()::text)
    RETURNING id INTO insert_id;
    
    -- Pequeno delay (PostgreSQL não tem sleep nativo, mas podemos usar pg_sleep)
    PERFORM pg_sleep(0.1);
    
    -- Fazer DELETE
    DELETE FROM public.db_keepalive WHERE id = insert_id;
    
    -- Limpar registros antigos (mais de 7 dias)
    DELETE FROM public.db_keepalive 
    WHERE created_at < NOW() - INTERVAL '7 days';
    
    -- Retornar resultado
    result := jsonb_build_object(
        'success', true,
        'message', 'Base de dados mantida ativa com sucesso',
        'timestamp', NOW()::text,
        'insert_id', insert_id::text
    );
    
    RETURN result;
END;
$$;

-- Comentário na função
COMMENT ON FUNCTION public.keep_db_active() IS 'Função para manter a base de dados ativa através de operações INSERT/DELETE';

-- Passo 4: Tentar habilitar e agendar o job com pg_cron (se disponível)
DO $$
DECLARE
    cron_available BOOLEAN := false;
    job_exists BOOLEAN := false;
BEGIN
    -- Tentar habilitar pg_cron
    BEGIN
        CREATE EXTENSION IF NOT EXISTS pg_cron;
        cron_available := true;
        RAISE NOTICE 'Extensão pg_cron habilitada com sucesso';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'pg_cron não pode ser habilitado: Permissões insuficientes';
            cron_available := false;
        WHEN OTHERS THEN
            RAISE NOTICE 'pg_cron não está disponível: %', SQLERRM;
            cron_available := false;
    END;
    
    -- Se pg_cron estiver disponível, tentar agendar o job
    IF cron_available THEN
        BEGIN
            -- Verificar se o schema cron existe
            IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cron') THEN
                -- Verificar se job já existe
                BEGIN
                    SELECT EXISTS (
                        SELECT 1 FROM cron.job WHERE jobname = 'keep-db-active-daily'
                    ) INTO job_exists;
                EXCEPTION
                    WHEN OTHERS THEN
                        job_exists := false;
                END;
                
                -- Remover job existente se houver
                IF job_exists THEN
                    BEGIN
                        PERFORM cron.unschedule('keep-db-active-daily');
                        RAISE NOTICE 'Job existente removido';
                    EXCEPTION
                        WHEN OTHERS THEN
                            RAISE NOTICE 'Aviso ao remover job existente: %', SQLERRM;
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
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE NOTICE 'Erro ao criar job pg_cron: %', SQLERRM;
                END;
            ELSE
                RAISE NOTICE 'Schema cron não existe. pg_cron não está totalmente habilitado.';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Erro ao configurar job pg_cron: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ pg_cron não está disponível. A função keep_db_active() foi criada e pode ser executada manualmente.';
        RAISE NOTICE 'Para agendar automaticamente, solicite ao suporte do Supabase para habilitar pg_cron.';
    END IF;
END $$;

-- Passo 5: Criar função alternativa usando pg_net para chamar Edge Function
-- (Caso pg_cron funcione mas você prefira usar a Edge Function)
CREATE OR REPLACE FUNCTION public.keep_db_active_via_edge_function()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    response_id bigint;
    supabase_url text;
    service_role_key text;
    result jsonb;
BEGIN
    -- Obter URL e chave do Supabase (você precisa configurar essas variáveis)
    -- Nota: Em produção, use secrets do Supabase
    supabase_url := current_setting('app.settings.supabase_url', true);
    service_role_key := current_setting('app.settings.service_role_key', true);
    
    -- Se não estiverem configuradas, usar valores padrão
    IF supabase_url IS NULL THEN
        supabase_url := 'https://mhzhxwmxnofltgdmshcq.supabase.co';
    END IF;
    
    -- Verificar se pg_net está disponível
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_net') THEN
        RAISE EXCEPTION 'pg_net não está disponível. Use keep_db_active() diretamente.';
    END IF;
    
    -- Chamar Edge Function via HTTP
    SELECT net.http_post(
        url := supabase_url || '/functions/v1/keep-db-active',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || COALESCE(service_role_key, '')
        ),
        body := '{}'::jsonb
    ) INTO response_id;
    
    result := jsonb_build_object(
        'success', true,
        'message', 'Chamada à Edge Function enviada',
        'request_id', response_id
    );
    
    RETURN result;
END;
$$;

-- Comentário na função alternativa
COMMENT ON FUNCTION public.keep_db_active_via_edge_function() IS 'Função alternativa que chama a Edge Function keep-db-active via HTTP';
