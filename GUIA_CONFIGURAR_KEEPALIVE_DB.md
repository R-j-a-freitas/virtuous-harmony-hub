# 🔄 Guia: Configurar Keepalive da Base de Dados Supabase

Este guia explica como configurar uma rotina automática para manter a base de dados Supabase ativa, evitando que ela entre em pausa por falta de uso.

## 📋 O que foi criado

1. **Tabela `db_keepalive`**: Tabela simples usada para operações de keepalive
2. **Edge Function `keep-db-active`**: Função que executa insert e delete diariamente
3. **Cron Job**: Configuração para executar a função automaticamente

## 🚀 Passos para Configuração

### Passo 1: Executar a Migration

1. Aceda ao **Supabase Dashboard**: https://supabase.com/dashboard
2. Selecione o seu projeto
3. Vá para **SQL Editor**
4. Execute a migration `20250129000000_create_db_keepalive.sql`:

```sql
-- Copiar e colar o conteúdo do ficheiro:
-- supabase/migrations/20250129000000_create_db_keepalive.sql
```

Ou execute diretamente no SQL Editor:

```sql
CREATE TABLE IF NOT EXISTS public.db_keepalive (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT DEFAULT 'Keepalive ping - manter DB ativa'
);

CREATE INDEX IF NOT EXISTS idx_db_keepalive_created_at ON public.db_keepalive(created_at);

ALTER TABLE public.db_keepalive ENABLE ROW LEVEL SECURITY;
```

### Passo 2: Fazer Deploy da Edge Function

#### Opção A: Via Supabase CLI (Recomendado)

```bash
# Certifique-se de que está na raiz do projeto
cd virtuous-harmony-hub-1

# Fazer deploy da função
supabase functions deploy keep-db-active
```

#### Opção B: Via Dashboard do Supabase

1. Aceda ao **Supabase Dashboard**
2. Vá para **Edge Functions**
3. Clique em **Create a new function**
4. Nome: `keep-db-active`
5. Cole o conteúdo do ficheiro `supabase/functions/keep-db-active/index.ts`
6. Clique em **Deploy**

### Passo 3: Configurar o Cron Job

**⚠️ IMPORTANTE**: A extensão `pg_cron` pode não estar disponível no seu plano do Supabase. Se receber o erro "schema 'cron' does not exist", use uma das alternativas abaixo.

#### ❌ Se pg_cron não estiver disponível (Erro: "schema cron does not exist")

Use uma das alternativas abaixo. Recomendamos **GitHub Actions** (Opção 1) se o código estiver no GitHub.

#### ✅ Opção 1: GitHub Actions (Recomendado - Gratuito)

1. **Criar o workflow** (já criado em `.github/workflows/keep-db-active.yml`)

2. **Configurar o secret no GitHub**:
   - Vá ao seu repositório no GitHub
   - **Settings** → **Secrets and variables** → **Actions**
   - Clique em **New repository secret**
   - **Name**: `SUPABASE_ANON_KEY`
   - **Value**: Sua chave anon do Supabase
     - Obtenha em: Supabase Dashboard → Settings → API → anon public key
   - Clique em **Add secret**

3. **Fazer commit e push**:
   ```bash
   git add .github/workflows/keep-db-active.yml
   git commit -m "Adicionar GitHub Actions para keepalive da DB"
   git push
   ```

4. **Verificar execução**:
   - GitHub → Seu repositório → **Actions**
   - Veja o workflow "Keep DB Active" executando diariamente

#### ✅ Opção 2: cron-job.org (Gratuito)

1. Aceda a: https://cron-job.org
2. Crie uma conta gratuita
3. Clique em **Create cronjob**
4. Configure:
   - **Title**: Keep DB Active
   - **Address (URL)**: `https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active`
   - **Request method**: POST
   - **Request headers**: 
     ```
     Authorization: Bearer SUA_ANON_KEY
     Content-Type: application/json
     ```
   - **Request body**: `{}`
   - **Schedule**: Diariamente às 02:00 UTC
5. Clique em **Create**

#### ✅ Opção 3: EasyCron (Gratuito)

1. Aceda a: https://www.easycron.com
2. Crie uma conta gratuita
3. Clique em **Add New Cron Job**
4. Configure:
   - **Cron Job Title**: Keep DB Active
   - **URL**: `https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active`
   - **HTTP Method**: POST
   - **HTTP Headers**: 
     ```
     Authorization: Bearer SUA_ANON_KEY
     Content-Type: application/json
     ```
   - **Cron Expression**: `0 2 * * *` (diariamente às 02:00 UTC)
5. Salve o cron job

#### ✅ Opção 4: pg_cron (Apenas se disponível)

Se o seu plano Supabase suportar pg_cron:

1. Aceda ao **SQL Editor** no Supabase Dashboard
2. Execute:

```sql
-- Verificar se pg_cron está disponível
SELECT * FROM pg_extension WHERE extname = 'pg_cron';

-- Se não estiver, tentar habilitar (pode não funcionar em planos gratuitos)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Agendar o job (substitua YOUR_SERVICE_ROLE_KEY)
SELECT cron.schedule(
  'keep-db-active',
  '0 2 * * *', -- Todos os dias às 02:00 UTC
  $$
  SELECT
    net.http_post(
      url := 'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
      ),
      body := '{}'::jsonb
    );
  $$
);
```

**⚠️ ATENÇÃO**: Substitua `YOUR_SERVICE_ROLE_KEY` pela sua chave service_role:
- Vá para **Settings** → **API**
- Copie a chave **service_role** (não a anon key!)

### Passo 4: Verificar se está Funcionando

#### Teste Manual da Edge Function

1. Aceda ao **Supabase Dashboard** → **Edge Functions**
2. Clique em `keep-db-active`
3. Clique em **Invoke function**
4. Verifique os logs para confirmar que funcionou

Ou teste via curl:

```bash
curl -X POST \
  'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json'
```

#### Verificar o Cron Job

```sql
-- Ver todos os jobs agendados
SELECT * FROM cron.job;

-- Ver histórico de execuções
SELECT * FROM cron.job_run_details 
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'keep-db-active')
ORDER BY start_time DESC
LIMIT 10;
```

## 🔍 Monitorização

### Verificar Logs da Edge Function

1. Aceda ao **Supabase Dashboard** → **Edge Functions** → `keep-db-active`
2. Clique em **Logs** para ver as execuções

### Verificar a Tabela db_keepalive

```sql
-- Ver registros recentes (deve estar vazia ou com poucos registros)
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

Para executar mais frequentemente (ex: a cada 12 horas):

```sql
-- Remover o job existente
SELECT cron.unschedule('keep-db-active-daily');

-- Criar novo job (a cada 12 horas)
SELECT cron.schedule(
  'keep-db-active-twice-daily',
  '0 */12 * * *', -- A cada 12 horas
  $$
  SELECT
    net.http_post(
      url := 'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
      ),
      body := '{}'::jsonb
    );
  $$
);
```

### Horários Comuns de Cron

- `0 2 * * *` - Todos os dias às 02:00 UTC
- `0 */12 * * *` - A cada 12 horas
- `0 */6 * * *` - A cada 6 horas
- `0 * * * *` - A cada hora
- `*/30 * * * *` - A cada 30 minutos

## 🛠️ Troubleshooting

### Erro: "pg_cron extension not found"

Se a extensão pg_cron não estiver disponível, use uma alternativa:

1. **GitHub Actions** (gratuito para repositórios públicos)
2. **Vercel Cron Jobs** (se estiver usando Vercel)
3. **Serviço externo** como cron-job.org

### Erro: "Function not found"

Certifique-se de que:
1. A Edge Function foi deployada corretamente
2. O nome da função está correto no cron job
3. A URL do Supabase está correta

### Erro: "Permission denied"

Certifique-se de que:
1. Está usando a chave **service_role** (não anon key) no cron job
2. A tabela `db_keepalive` existe e tem as permissões corretas

## 📝 Notas Importantes

- A função executa um INSERT seguido de DELETE, mantendo a tabela limpa
- A função também limpa registros com mais de 7 dias automaticamente
- O cron job executa no horário UTC
- A base de dados permanecerá ativa enquanto o cron job estiver configurado

## ✅ Checklist Final

- [ ] Migration executada (tabela `db_keepalive` criada)
- [ ] Edge Function `keep-db-active` deployada
- [ ] Cron job configurado e agendado
- [ ] Teste manual realizado com sucesso
- [ ] Logs verificados após primeira execução automática

---

**Última atualização**: Janeiro 2025
