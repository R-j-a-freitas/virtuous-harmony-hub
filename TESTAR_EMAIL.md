# Guia Rápido: Testar e Corrigir Envio de Emails

## 🔍 **PASSO 1: VERIFICAR SE A EDGE FUNCTION ESTÁ DEPLOYADA**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Procure por `send-contact-email` na lista
3. **Se NÃO existir**, precisa fazer deploy:

### **Fazer Deploy da Edge Function:**

**Opção A: Via Supabase Dashboard (Mais Fácil)**
1. No Dashboard, vá em **Edge Functions**
2. Clique em **Create a new function**
3. Nome: `send-contact-email`
4. Cole o conteúdo do arquivo `supabase/functions/send-contact-email/index.ts`
5. Clique em **Deploy**

**Opção B: Via CLI**
```bash
# Se tiver Supabase CLI instalado
supabase functions deploy send-contact-email
```

---

## 🔑 **PASSO 2: CONFIGURAR RESEND_API_KEY**

1. Obtenha sua chave do Resend:
   - Acesse: https://resend.com/api-keys
   - Crie uma nova chave ou copie uma existente

2. Configure no Supabase:
   - No Dashboard: **Project Settings** → **Edge Functions** → **Secrets**
   - Clique em **Add new secret**
   - Nome: `RESEND_API_KEY`
   - Valor: sua chave API do Resend
   - Clique em **Save**

**Nota:** Se não configurar, o código usa uma chave fallback (pode não funcionar em produção).

---

## 🧪 **PASSO 3: TESTAR O ENVIO**

1. Abra o site: http://localhost:8081/
2. Abra o DevTools (F12) → aba **Console**
3. Preencha o formulário de contacto
4. Envie o formulário
5. Observe o console:
   - ✅ **Sucesso**: Verá "✅ Email sent successfully"
   - ❌ **Erro**: Verá mensagens de erro detalhadas

---

## 📊 **PASSO 4: VERIFICAR LOGS DA EDGE FUNCTION**

Se houver erros, verifique os logs:

1. No Supabase Dashboard: **Edge Functions** → `send-contact-email` → **Logs**
2. Procure por:
   - ✅ Mensagens de sucesso
   - ❌ Mensagens de erro
   - 🔑 Se a API key está configurada

---

## ⚠️ **ERROS COMUNS E SOLUÇÕES**

### **Erro: "Function not found" ou "404"**
- **Causa**: Edge function não está deployada
- **Solução**: Faça deploy conforme PASSO 1

### **Erro: "Invalid API key"**
- **Causa**: `RESEND_API_KEY` incorreta
- **Solução**: Verifique e configure no PASSO 2

### **Erro: "Domain not verified"**
- **Causa**: Tentando usar domínio não verificado
- **Solução**: O código usa `onboarding@resend.dev` que deve funcionar para testes

### **Erro: "Failed to send email"**
- **Causa**: Problema com Resend API
- **Solução**: 
  - Verifique se a chave API está ativa no Resend
  - Verifique os logs da Edge Function para detalhes

---

## ✅ **CHECKLIST FINAL**

- [ ] Edge function `send-contact-email` está deployada no Supabase
- [ ] `RESEND_API_KEY` está configurada como secret no Supabase
- [ ] Teste o envio através do formulário
- [ ] Verifique o console do browser para logs
- [ ] Verifique os logs da Edge Function no Supabase
- [ ] Confirme que recebeu o email em `virtuousensemble@gmail.com`

---

## 📧 **CONTACTO DIRETO (Fallback)**

Se o sistema de email não funcionar, os dados ainda são salvos na base de dados. Você pode:
1. Ver os pedidos de contacto no painel administrativo
2. Ou contactar diretamente: virtuousensemble@gmail.com
