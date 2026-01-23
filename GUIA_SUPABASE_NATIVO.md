# 🔄 Guia: Keepalive Apenas com Supabase (Solução Nativa)

Este guia mostra como configurar o keepalive usando **apenas recursos nativos do Supabase**, sem depender de serviços externos.

## 📋 O que foi criado

1. **Função SQL `keep_db_active()`**: Executa insert/delete diretamente na base de dados
2. **Job pg_cron**: Agendamento automático (se disponível no seu plano)
3. **Função alternativa**: Para chamar Edge Function via HTTP (opcional)

## 🚀 Configuração Passo a Passo

### Passo 1: Executar as Migrations

Execute as migrations **na ordem** no Supabase Dashboard → SQL Editor:

1. **Primeiro**: `20250129000000_create_db_keepalive.sql` (cria a tabela)
2. **Segundo**: `20250129000001_enable_pg_cron_and_schedule.sql` (cria a função SQL)
3. **Terceiro**: `20250129000002_verificar_e_configurar_cron.sql` (tenta habilitar pg_cron e agendar)

Ou execute tudo de uma vez:

```sql
-- Migration 1: Criar tabela
CREATE TABLE IF NOT EXISTS public.db_keepalive (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT DEFAULT 'Keepalive ping - manter DB ativa'
);

CREATE INDEX IF NOT EXISTS idx_db_keepalive_created_at ON public.db_keepalive(created_at);
ALTER TABLE public.db_keepalive ENABLE ROW LEVEL SECURITY;

-- Migration 2: Criar função SQL (cole o conteúdo de 20250129000001_enable_pg_cron_and_schedule.sql)
-- Migration 3: Configurar cron (cole o conteúdo de 20250129000002_verificar_e_configurar_cron.sql)

-- OU execute diretamente os ficheiros completos na ordem:
-- 1. 20250129000000_create_db_keepalive.sql
-- 2. 20250129000001_enable_pg_cron_and_schedule.sql  
-- 3. 20250129000002_verificar_e_configurar_cron.sql
```

### Passo 2: Verificar se pg_cron foi habilitado

Execute no SQL Editor:

```sql
-- Verificar se a função foi criada
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_name = 'keep_db_active';

-- Verificar extensões disponíveis (pode dar erro se pg_cron não estiver disponível)
SELECT * FROM pg_extension WHERE extname IN ('pg_cron', 'pg_net');

-- Verificar se o schema cron existe (sem erro se não existir)
SELECT EXISTS (
    SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cron'
) AS cron_schema_exists;

-- Ver jobs agendados (só funciona se pg_cron estiver disponível)
-- Se der erro "relation cron.job does not exist", significa que pg_cron não está disponível
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cron') THEN
        RAISE NOTICE 'Jobs agendados:';
        FOR rec IN SELECT * FROM cron.job WHERE jobname = 'keep-db-active-daily'
        LOOP
            RAISE NOTICE 'Job ID: %, Nome: %, Schedule: %', rec.jobid, rec.jobname, rec.schedule;
        END LOOP;
    ELSE
        RAISE NOTICE 'pg_cron não está disponível - não há jobs para mostrar';
    END IF;
END $$;

### Passo 3: Se pg_cron não estiver disponível

Se o `pg_cron` não estiver disponível no seu plano, você tem duas opções:

#### Opção A: Executar Manualmente (Teste)

Teste a função manualmente:

```sql
SELECT public.keep_db_active();
```

Deve retornar:
```json
{
  "success": true,
  "message": "Base de dados mantida ativa com sucesso",
  "timestamp": "2025-01-29 10:00:00",
  "insert_id": "uuid-aqui"
}
```

#### Opção B: Usar Database Webhooks (Se disponível)

1. Supabase Dashboard → **Database** → **Webhooks**
2. Criar webhook que chama a função periodicamente
3. **Nota**: Webhooks são acionados por eventos, não por tempo

#### Opção C: Habilitar pg_cron via Support

Se você tem um plano pago, pode solicitar ao suporte do Supabase para habilitar `pg_cron`:

1. Aceda ao Supabase Dashboard
2. Vá para **Support** ou abra um ticket
3. Solicite: "Please enable pg_cron extension for my project"
4. Após habilitado, execute novamente a migration

## 🔍 Verificar se Está Funcionando

### Verificar Jobs Agendados

```sql
-- Ver todos os jobs
SELECT 
    jobid,
    jobname,
    schedule,
    active,
    command
FROM cron.job
WHERE jobname = 'keep-db-active-daily';
```

### Ver Histórico de Execuções

```sql
-- Ver últimas execuções
SELECT 
    jobid,
    runid,
    job_pid,
    database,
    username,
    command,
    status,
    return_message,
    start_time,
    end_time
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'keep-db-active-daily')
ORDER BY start_time DESC
LIMIT 10;
```

### Verificar a Tabela

```sql
-- Ver registros (deve estar vazia ou com poucos registros)
SELECT * FROM public.db_keepalive 
ORDER BY created_at DESC 
LIMIT 10;

-- Verificar estatísticas
SELECT 
    COUNT(*) as total_registros,
    MIN(created_at) as mais_antigo,
    MAX(created_at) as mais_recente
FROM public.db_keepalive;
```

## ⚙️ Configurações Avançadas

### Alterar Frequência do Cron

```sql
-- Remover job existente
SELECT cron.unschedule('keep-db-active-daily');

-- Criar novo job (a cada 12 horas)
SELECT cron.schedule(
    'keep-db-active-twice-daily',
    '0 */12 * * *',
    $$SELECT public.keep_db_active();$$
);
```

### Executar Imediatamente (Teste)

```sql
-- Executar a função agora
SELECT public.keep_db_active();
```

### Ver Logs de Execução

```sql
-- Ver mensagens de erro/sucesso
SELECT 
    start_time,
    end_time,
    status,
    return_message
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'keep-db-active-daily')
ORDER BY start_time DESC
LIMIT 20;
```

## 🛠️ Troubleshooting

### Erro: "schema cron does not exist"

**Causa**: A extensão `pg_cron` não está habilitada no seu projeto.

**Soluções**:
1. **Solicitar ao suporte do Supabase** para habilitar (planos pagos)
2. **Usar função manualmente** quando necessário
3. **Upgrade do plano** se estiver no plano gratuito

### Erro: "permission denied for schema cron"

**Causa**: Não tem permissões para usar pg_cron.

**Solução**: Contacte o suporte do Supabase para habilitar permissões.

### Função não está sendo executada

**Verificar**:
1. O job está ativo? `SELECT * FROM cron.job WHERE jobname = 'keep-db-active-daily';`
2. Há erros nos logs? `SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;`
3. A função funciona manualmente? `SELECT public.keep_db_active();`

## 📝 Notas Importantes

- A função `keep_db_active()` trabalha **diretamente na base de dados**, sem necessidade de HTTP
- Mais eficiente que chamar Edge Function
- O `pg_cron` pode não estar disponível no plano gratuito
- Se `pg_cron` não funcionar, você pode executar a função manualmente quando necessário
- A função limpa automaticamente registros com mais de 7 dias

## ✅ Checklist

- [ ] Migration 1 executada (tabela `db_keepalive` criada)
- [ ] Migration 2 executada (função `keep_db_active()` criada)
- [ ] Verificado se `pg_cron` está disponível
- [ ] Job agendado (se pg_cron disponível)
- [ ] Teste manual realizado: `SELECT public.keep_db_active();`
- [ ] Verificado histórico de execuções

---

**Última atualização**: Janeiro 2025
