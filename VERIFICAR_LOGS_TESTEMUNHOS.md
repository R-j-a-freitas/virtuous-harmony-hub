# 🔍 Verificar Logs: Email de Testemunhos Não Chega

## ✅ **FUNÇÃO ESTÁ SENDO CHAMADA**

A função `send-testimonial-email` está sendo executada (vejo "function called" nos logs), mas o email não está chegando.

---

## 🔍 **DIAGNÓSTICO: VERIFICAR LOGS**

### **PASSO 1: Verificar Logs Completos**

1. No Supabase Dashboard, vá para **Edge Functions** → `send-testimonial-email` → **Logs**
2. Procure pelos logs mais recentes após enviar um testemunho
3. **Procure especificamente por:**

#### **Logs que DEVEM aparecer:**
- ✅ `📧 send-testimonial-email function called`
- ✅ `📧 Method: POST` (NÃO OPTIONS)
- ✅ `📧 Processing POST request`
- ✅ `📧 Body received:`
- ✅ `📧 Data validated successfully`
- ✅ `📧 Attempting to send testimonial email to virtuousensemble@gmail.com`
- ✅ `📧 Using API key: SET`
- ✅ `📧 Sending request to Resend API...`
- ✅ `📧 Resend API request completed`
- ✅ `📧 Resend response status: 200` (ou outro código)
- ✅ `📧 Resend response: { "id": "..." }`
- ✅ `✅ Testimonial email sent successfully`

#### **Se aparecer algum destes, há problema:**
- ❌ `📧 Method: OPTIONS` (e depois não aparece POST) → Problema de CORS
- ❌ `❌ Email sending failed` → Erro do Resend
- ❌ `📧 Resend response status: 400/401/403/500` → Erro da API
- ❌ `❌ RESEND_API_KEY not configured` → Chave não configurada
- ❌ `❌ Edge function error:` → Erro no código

---

## 🔍 **PASSO 2: Verificar o Que Aconteceu**

### **Cenário 1: Só Aparece OPTIONS, Não Aparece POST**
**Problema:** A requisição POST não está chegando à função  
**Solução:** Verificar se o componente está chamando a função corretamente

### **Cenário 2: Aparece POST mas Para Antes de "Sending request to Resend API"**
**Problema:** Erro na validação ou parsing  
**Solução:** Verificar os dados sendo enviados

### **Cenário 3: Aparece "Resend response status: 200" mas Email Não Chega**
**Problema:** Resend aceitou mas email não foi entregue  
**Solução:** 
- Verificar pasta de spam
- Verificar dashboard do Resend para ver status do email
- Verificar se o domínio `onboarding@resend.dev` está funcionando

### **Cenário 4: Aparece "Resend response status: 400/401/403"**
**Problema:** Erro na API do Resend  
**Solução:** Verificar a resposta completa nos logs para ver o erro específico

### **Cenário 5: Aparece "Resend response status: 500"**
**Problema:** Erro interno do Resend  
**Solução:** Tentar novamente ou verificar status do serviço Resend

---

## 🔍 **PASSO 3: Verificar Resposta do Resend**

Nos logs, procure por:
```
📧 Resend response: { ... }
```

**Se aparecer:**
- `{ "id": "..." }` → Email foi aceito pelo Resend ✅
- `{ "error": { ... } }` → Erro do Resend ❌
- `{ "message": "..." }` → Mensagem de erro ❌

---

## 🔍 **PASSO 4: Verificar Dashboard do Resend**

1. Acesse: https://resend.com/emails
2. Verifique se há emails enviados recentemente
3. Veja o status de cada email:
   - ✅ **Delivered** → Email foi entregue (verificar spam)
   - ⏳ **Pending** → Ainda sendo processado
   - ❌ **Failed** → Falhou (ver motivo)
   - ❌ **Bounced** → Rejeitado pelo servidor de destino

---

## 🔍 **PASSO 5: Verificar Pasta de Spam**

Mesmo que o Resend diga que foi entregue, verifique:
- Pasta de spam/lixo eletrônico
- Filtros do Gmail
- Regras de encaminhamento

---

## 📋 **CHECKLIST DE DIAGNÓSTICO**

- [ ] Verifiquei os logs completos da função
- [ ] Vi a mensagem "📧 Resend response status: XXX"
- [ ] Vi a mensagem "📧 Resend response: { ... }"
- [ ] Verifiquei o dashboard do Resend
- [ ] Verifiquei a pasta de spam
- [ ] Verifiquei se `RESEND_API_KEY` está configurada

---

## 🆘 **SE PRECISAR DE AJUDA**

Copie e cole aqui:
1. Todos os logs da função após enviar um testemunho
2. A resposta completa do Resend (se aparecer nos logs)
3. O que aparece no dashboard do Resend

