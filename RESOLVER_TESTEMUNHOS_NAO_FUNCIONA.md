# 🔧 Resolver Problema: Testemunhos Não Funcionam

## 🔍 **PROBLEMA IDENTIFICADO**

A política RLS (Row Level Security) está configurada para exigir autenticação para inserir testemunhos. Isso impede que visitantes não autenticados enviem testemunhos através do formulário público.

---

## ✅ **SOLUÇÃO RÁPIDA**

### **PASSO 1: Corrigir Política RLS no Supabase**

1. Acesse o **Supabase Dashboard**: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq
2. Vá para **SQL Editor** (ícone de banco de dados no menu lateral)
3. Clique em **"New query"**
4. **Cole o conteúdo completo** do arquivo: `CORRIGIR_POLITICA_TESTIMONIALS_PUBLICO.sql`
5. Clique em **"Run"** (ou pressione Ctrl+Enter)
6. ✅ Verifique se aparece "Success. No rows returned" ou mensagem de sucesso

---

### **PASSO 2: Verificar se Funcionou**

1. Abra o site no navegador
2. Abra o **DevTools** (F12) → aba **Console**
3. Vá para a secção de **Testemunhos**
4. Clique em **"Deixar Testemunho"**
5. Preencha o formulário:
   - Nome: Teste
   - Avaliação: 5 estrelas
   - Testemunho: Este é um testemunho de teste
6. Clique em **"Enviar Testemunho"**

**O que deve acontecer:**
- ✅ Mensagem de sucesso: "O seu testemunho foi enviado e será analisado em breve"
- ✅ Formulário limpa e fecha
- ✅ No console: "📧 Attempting to send testimonial email via edge function..."

**Se aparecer erro:**
- ❌ Verifique o console (F12) para ver a mensagem de erro completa
- ❌ Verifique se executou o script SQL corretamente
- ❌ Verifique se a tabela `testimonials` existe no Supabase

---

## 🔍 **DIAGNÓSTICO ADICIONAL**

### **Verificar Políticas RLS Ativas**

Execute este SQL no Supabase para verificar as políticas:

```sql
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'testimonials'
ORDER BY policyname;
```

**Deve aparecer:**
- ✅ `Anyone can insert testimonials` (cmd: INSERT, with_check: true)
- ✅ `Anyone can view approved testimonials` (cmd: SELECT, qual: approved = true)
- ✅ Políticas de admin (opcionais)

### **Verificar Erros no Console**

Se ainda não funcionar, verifique no console do navegador (F12):

1. **Erro de permissão (42501):**
   - Significa que a política RLS ainda não foi corrigida
   - Execute novamente o script SQL

2. **Erro de conexão:**
   - Verifique se o Supabase está acessível
   - Verifique as credenciais no arquivo `.env` ou configuração

3. **Erro de validação:**
   - Verifique se preencheu todos os campos obrigatórios
   - Nome: mínimo 2 caracteres, apenas letras
   - Testemunho: mínimo 10 caracteres, máximo 1000

---

## 📧 **ENVIO DE EMAIL**

O envio de email requer que a edge function `send-testimonial-email` esteja deployada:

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Verifique se `send-testimonial-email` existe
3. Se não existir:
   - Clique em **"Create a new function"**
   - Nome: `send-testimonial-email`
   - Cole o conteúdo de: `supabase/functions/send-testimonial-email/index.ts`
   - Clique em **"Deploy"**

**Nota:** O testemunho será salvo mesmo se o email falhar. O email é apenas uma notificação.

---

## ✅ **TESTE FINAL**

Após corrigir:

1. ✅ Formulário abre e permite escrever
2. ✅ Validação funciona (mostra erros se campos inválidos)
3. ✅ Envio funciona (mensagem de sucesso)
4. ✅ Testemunho é salvo na base de dados (com `approved: false`)
5. ✅ Email é enviado ao admin (se edge function estiver deployada)

---

## 🆘 **SE AINDA NÃO FUNCIONAR**

1. **Verifique os logs do Supabase:**
   - Dashboard → Logs → Postgres Logs
   - Procure por erros relacionados a `testimonials`

2. **Verifique o console do navegador:**
   - F12 → Console
   - Procure por erros em vermelho

3. **Teste a conexão com Supabase:**
   - Verifique se outras funcionalidades (como formulário de contacto) funcionam
   - Se não funcionarem, pode ser problema de configuração geral

4. **Verifique a estrutura da tabela:**
   ```sql
   SELECT column_name, data_type, is_nullable
   FROM information_schema.columns
   WHERE table_schema = 'public' 
   AND table_name = 'testimonials';
   ```

   Deve ter as colunas: `id`, `name`, `content`, `rating`, `approved`, `created_at`, `updated_at`

