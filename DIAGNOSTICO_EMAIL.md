# Diagnóstico e Correção do Envio de Emails

## 🔍 **PROBLEMA IDENTIFICADO**

O envio de emails pelo formulário de contacto não está funcionando. Possíveis causas:

### **1. Edge Function Não Está Deployada**
A função `send-contact-email` precisa estar deployada no Supabase.

### **2. RESEND_API_KEY Não Configurada**
A chave da API do Resend precisa estar configurada como secret no Supabase.

### **3. Domínio de Email Não Verificado**
O Resend requer um domínio verificado para enviar emails reais. O domínio padrão `onboarding@resend.dev` funciona apenas para testes locais.

---

## ✅ **SOLUÇÕES**

### **SOLUÇÃO 1: Verificar se a Edge Function está Deployada**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Verifique se `send-contact-email` está na lista
3. Se não estiver, faça o deploy usando o Supabase CLI ou Dashboard

### **SOLUÇÃO 2: Configurar RESEND_API_KEY**

1. Obtenha sua chave API do Resend: https://resend.com/api-keys
2. No Supabase Dashboard:
   - Vá em: **Project Settings** → **Edge Functions** → **Secrets**
   - Adicione: `RESEND_API_KEY` = `sua_chave_aqui`
   - OU use a chave já hardcoded no código (temporária)

### **SOLUÇÃO 3: Verificar Domínio de Email**

O código atual usa `onboarding@resend.dev`, que é um domínio de teste do Resend. Para emails reais funcionarem:

**Opção A: Usar domínio verificado**
1. No Resend Dashboard, verifique seu domínio
2. Atualize o código para usar seu domínio verificado

**Opção B: Verificar se o email de teste funciona**
- O `onboarding@resend.dev` deve funcionar, mas pode ter limitações

---

## 🔧 **MELHORIAS NO CÓDIGO**

Atualizei o código para:
- ✅ Melhor tratamento de erros
- ✅ Logs mais detalhados no console
- ✅ Validação aprimorada

---

## 📋 **TESTAR O ENVIO**

1. Abra o DevTools do navegador (F12)
2. Vá para a aba **Console**
3. Preencha e envie o formulário de contacto
4. Verifique os logs no console:
   - Se aparecer "Email sent successfully", o email foi enviado
   - Se aparecer erros, anote os detalhes

5. Verifique os logs da Edge Function:
   - No Supabase Dashboard → Edge Functions → `send-contact-email` → Logs

---

## ⚠️ **CHECKLIST DE VERIFICAÇÃO**

- [ ] Edge function `send-contact-email` está deployada
- [ ] `RESEND_API_KEY` está configurada no Supabase Secrets
- [ ] Domínio de email está verificado no Resend (ou usando domínio de teste)
- [ ] Console do browser não mostra erros ao enviar formulário
- [ ] Logs da Edge Function no Supabase mostram sucesso ou erro detalhado

---

## 🚨 **ERROS COMUNS**

### **Erro: "Edge function not found"**
- **Causa**: Edge function não está deployada
- **Solução**: Faça deploy da função

### **Erro: "Invalid API key"**
- **Causa**: `RESEND_API_KEY` incorreta ou não configurada
- **Solução**: Verifique e configure a chave correta

### **Erro: "Domain not verified"**
- **Causa**: Tentando usar domínio não verificado
- **Solução**: Use `onboarding@resend.dev` para testes ou verifique seu domínio no Resend

---

## 📧 **CONFIGURAÇÃO RECOMENDADA PARA PRODUÇÃO**

Para produção, você deve:

1. **Verificar seu domínio no Resend:**
   - Adicione um domínio (ex: `virtuousensemble.com`)
   - Configure os registros DNS conforme instruções
   - Use esse domínio no envio de emails

2. **Atualizar o código:**
   - Altere `from: 'onboarding@resend.dev'` para `from: 'noreply@virtuousensemble.com'` (ou seu domínio)

3. **Configurar variáveis de ambiente:**
   - Use apenas secrets do Supabase para `RESEND_API_KEY`
   - Remova chaves hardcoded do código
