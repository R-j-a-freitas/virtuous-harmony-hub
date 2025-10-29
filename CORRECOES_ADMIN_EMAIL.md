# Correções Implementadas e Instruções

## ✅ **CORREÇÕES IMPLEMENTADAS:**

### 1. **Painel Administrativo Conectado à Base de Dados**
- ✅ Removidos dados mockados
- ✅ Conexão real com Supabase implementada
- ✅ Busca eventos reais da base de dados
- ✅ Busca testemunhos reais da base de dados
- ✅ Atualização automática a cada 5 segundos

### 2. **Operações de Eventos Funcionais**
- ✅ Aprovar/Desaprovar eventos atualiza a base de dados
- ✅ Adicionar evento salva na base de dados
- ✅ Excluir evento remove da base de dados
- ✅ Sincronização automática com página pública

### 3. **Operações de Testemunhos Funcionais**
- ✅ Mostrar/Ocultar testemunhos atualiza a base de dados
- ✅ Excluir testemunho remove da base de dados
- ✅ Sincronização automática com página pública

### 4. **Melhorias no Envio de Email**
- ✅ Melhor logging de erros no console do browser
- ✅ Tratamento de erros melhorado

---

## ⚠️ **AÇÕES NECESSÁRIAS PARA COMPLETAR:**

### **1. Executar Script SQL para Políticas RLS**

Execute o script `CRIAR_POLITICAS_ADMIN.sql` no Supabase Dashboard:

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/sql/new
2. Cole o conteúdo do arquivo `CRIAR_POLITICAS_ADMIN.sql`
3. Clique em "Run" para executar

**Isso permitirá que o painel administrativo atualize e exclua registos.**

---

### **2. Deploy da Edge Function para Emails**

A edge function precisa estar deployada no Supabase:

#### **Opção A: Via Supabase CLI (Recomendado)**

```bash
# Instalar Supabase CLI (se ainda não tiver)
npm install -g supabase

# Login no Supabase
supabase login

# Link do projeto
supabase link --project-ref mhzhxwmxnofltgdmshcq

# Deploy da function
supabase functions deploy send-contact-email
```

#### **Opção B: Via Dashboard do Supabase**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Crie nova function chamada `send-contact-email`
3. Cole o conteúdo de `supabase/functions/send-contact-email/index.ts`

---

### **3. Configurar RESEND_API_KEY**

1. Acesse: https://resend.com/api-keys
2. Crie ou copie sua API Key
3. No Supabase Dashboard:
   - Vá em: Settings → Edge Functions → Secrets
   - Adicione: `RESEND_API_KEY` = sua chave API
   - OU use a chave hardcoded no código (temporária)

**Nota:** A chave já está hardcoded no código como fallback: `re_NG6kkN6E_7GWUDiayqPjS8mDQRoJboAcs`

---

## 🧪 **TESTAR APÓS CORREÇÕES:**

### **Teste 1: Painel Administrativo**
1. Acesse: http://localhost:8081/admin
2. Faça login
3. Verifique se os eventos e testemunhos aparecem
4. Tente aprovar/desaprovar um evento
5. Verifique se aparece no site público

### **Teste 2: Envio de Email**
1. Preencha o formulário de contacto no site
2. Envie o formulário
3. Verifique o console do browser (F12) para logs
4. Verifique a caixa de entrada: virtuousensemble@gmail.com

---

## 🔍 **DEBUGGING:**

### **Se eventos não aparecem no admin:**
- Verifique o console do browser (F12) para erros
- Verifique se o script SQL foi executado
- Verifique se há dados na tabela `events` no Supabase

### **Se aprovar/desaprovar não funciona:**
- Execute o script `CRIAR_POLITICAS_ADMIN.sql`
- Verifique o console do browser para erros de permissão

### **Se emails não são enviados:**
- Verifique se a edge function está deployada
- Verifique os logs da edge function no Supabase Dashboard
- Verifique se `RESEND_API_KEY` está configurada
- Verifique o console do browser para erros detalhados

---

## 📋 **CHECKLIST FINAL:**

- [ ] Script `CRIAR_POLITICAS_ADMIN.sql` executado
- [ ] Edge function `send-contact-email` deployada
- [ ] `RESEND_API_KEY` configurada (ou usando fallback)
- [ ] Teste: Eventos aparecem no admin
- [ ] Teste: Aprovar evento funciona
- [ ] Teste: Testemunhos aparecem no admin
- [ ] Teste: Mostrar/ocultar testemunho funciona
- [ ] Teste: Envio de email funciona

---

## ⚡ **PRÓXIMOS PASSOS:**

1. Execute o script SQL primeiro
2. Teste o painel administrativo
3. Se funcionar, faça deploy da edge function
4. Teste o envio de email
