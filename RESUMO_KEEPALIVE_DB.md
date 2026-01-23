# 📋 Resumo: Sistema de Keepalive da Base de Dados

## ✅ O que foi criado

Foi implementado um sistema completo para manter a base de dados Supabase ativa, evitando que ela entre em pausa por falta de uso.

### Ficheiros Criados:

1. **`supabase/migrations/20250129000000_create_db_keepalive.sql`**
   - Cria a tabela `db_keepalive` usada para as operações de keepalive

2. **`supabase/functions/keep-db-active/index.ts`**
   - Edge Function que executa insert e delete diariamente
   - Mantém a base de dados ativa através de operações periódicas

3. **`GUIA_CONFIGURAR_KEEPALIVE_DB.md`**
   - Guia completo com instruções passo a passo
   - Inclui configuração do cron job no Supabase

4. **`GUIA_VERCEL_CRON_ALTERNATIVO.md`**
   - Alternativas caso o pg_cron não esteja disponível
   - Inclui GitHub Actions, cron-job.org, EasyCron, etc.

## 🚀 Como Configurar (Resumo Rápido)

### 1. Executar a Migration

No Supabase Dashboard → SQL Editor, execute:

```sql
CREATE TABLE IF NOT EXISTS public.db_keepalive (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT DEFAULT 'Keepalive ping - manter DB ativa'
);

CREATE INDEX IF NOT EXISTS idx_db_keepalive_created_at ON public.db_keepalive(created_at);
ALTER TABLE public.db_keepalive ENABLE ROW LEVEL SECURITY;
```

### 2. Fazer Deploy da Edge Function

**Via Supabase CLI:**
```bash
supabase functions deploy keep-db-active
```

**Via Dashboard:**
1. Supabase Dashboard → Edge Functions
2. Create a new function → Nome: `keep-db-active`
3. Cole o conteúdo de `supabase/functions/keep-db-active/index.ts`
4. Deploy

### 3. Configurar Cron Job (Solução Nativa Supabase)

**✅ Solução Recomendada: Usar Função SQL + pg_cron**

Execute a migration `20250129000001_enable_pg_cron_and_schedule.sql` no SQL Editor:

```sql
-- Esta migration cria a função SQL e tenta agendar com pg_cron
-- Consulte GUIA_SUPABASE_NATIVO.md para instruções completas
```

**O que a migration faz**:
1. Cria função SQL `keep_db_active()` que executa insert/delete diretamente
2. Tenta habilitar `pg_cron` e agendar o job automaticamente
3. Se `pg_cron` não estiver disponível, você pode executar a função manualmente

**Se pg_cron não estiver disponível**:
- Execute manualmente quando necessário: `SELECT public.keep_db_active();`
- Ou solicite ao suporte do Supabase para habilitar `pg_cron` (planos pagos)

**Consulte `GUIA_SUPABASE_NATIVO.md`** para instruções detalhadas e troubleshooting.

## 🧪 Testar

Teste manualmente a Edge Function:

```bash
curl -X POST \
  'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active' \
  -H 'Authorization: Bearer SUA_ANON_KEY' \
  -H 'Content-Type: application/json'
```

## 📊 Como Funciona

1. **Diariamente** (ou conforme agendado), o cron job chama a Edge Function
2. A função faz um **INSERT** na tabela `db_keepalive`
3. Imediatamente após, faz um **DELETE** do mesmo registro
4. Limpa registros antigos (mais de 7 dias)
5. Isso mantém a base de dados ativa sem acumular dados desnecessários

## 🔍 Verificar se Está Funcionando

### Ver Logs da Edge Function:
- Supabase Dashboard → Edge Functions → `keep-db-active` → Logs

### Verificar na Base de Dados:
```sql
SELECT * FROM public.db_keepalive 
ORDER BY created_at DESC 
LIMIT 10;
```

A tabela deve estar vazia ou com poucos registros (a função limpa após cada execução).

## 📚 Documentação Completa

Para instruções detalhadas, consulte:
- **`GUIA_CONFIGURAR_KEEPALIVE_DB.md`** - Guia completo principal
- **`GUIA_VERCEL_CRON_ALTERNATIVO.md`** - Alternativas ao pg_cron

## ⚠️ Importante

- **pg_cron pode não estar disponível** no plano gratuito do Supabase
- **Use GitHub Actions** (Opção 1) - é a solução mais simples e gratuita
- A função executa no horário **UTC** (02:00 UTC = 03:00 em Portugal no inverno)
- Use a chave **anon** (não service_role) para chamar a Edge Function externamente
- A tabela `db_keepalive` permanece limpa automaticamente
- A base de dados permanecerá ativa enquanto o cron estiver configurado

---

**Criado em**: Janeiro 2025
