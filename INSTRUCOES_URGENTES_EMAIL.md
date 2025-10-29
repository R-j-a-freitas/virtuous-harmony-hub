# 🔴 INSTRUÇÕES URGENTES: Corrigir Envio de Email

## ⚠️ **PROBLEMA**

O erro "Failed to send a request to the Edge Function" indica que a função não está respondendo.

---

## ✅ **SOLUÇÃO IMEDIATA (FAÇA AGORA)**

### **PASSO 1: Substituir Código da Função no Supabase**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Clique na função **`resend-email`**
3. **DELETE TODO O CÓDIGO ATUAL**
4. **Copie TODO o conteúdo** do arquivo: `EDGE_FUNCTION_MINIMA_FUNCIONA.ts`
5. **Cole no editor do Supabase**
6. **Clique em "Deploy"**
7. Aguarde confirmação

---

### **PASSO 2: Verificar Logs**

Após fazer deploy:

1. Envie o formulário novamente
2. No Supabase Dashboard:
   - **Edge Functions** → `resend-email` → **Logs**
   - Veja os últimos logs
   - Procure por:
     - ✅ "📧 Function called" → função está sendo chamada
     - ✅ "📧 Email sent successfully" → email foi enviado
     - ❌ Qualquer erro em vermelho

---

### **PASSO 3: Testar**

1. Preencha o formulário
2. Envie
3. Verifique:
   - Console do browser (F12) → veja os logs
   - Supabase Logs → veja se a função foi executada
   - Email em `virtuousensemble@gmail.com`

---

## 🔍 **VERIFICAR SE FUNCIONOU**

### **No Console do Browser (F12):**
- ✅ Deve aparecer: "📧 Response received"
- ✅ Deve aparecer: "✅ Email sent successfully"

### **Nos Logs da Edge Function:**
- ✅ Deve aparecer: "📧 Function called"
- ✅ Deve aparecer: "✅ Email sent successfully"

### **No Email:**
- 📧 Você recebe o email em `virtuousensemble@gmail.com`

---

## ⚠️ **SE AINDA NÃO FUNCIONAR**

### **Diagnóstico:**

1. **Verifique se a função existe:**
   - Supabase Dashboard → Edge Functions
   - Deve aparecer `resend-email` na lista

2. **Verifique os logs da função:**
   - Veja se há erros de sintaxe
   - Veja se a função está sendo chamada

3. **Verifique o Network no browser:**
   - F12 → Network
   - Envie o formulário
   - Procure por requisição a `/functions/v1/resend-email`
   - Clique nela e veja:
     - **Status**: 200 (sucesso) ou 500 (erro)?
     - **Response**: O que retornou?

4. **Verifique a chave API:**
   - A chave no código é: `re_faU39bCe_LTtaa6azqp4PYmEj6Ezgprom`
   - Se quiser usar Secrets:
     - Supabase Dashboard → Settings → Edge Functions → Secrets
     - Adicione: `RESEND_API_KEY` = sua chave

---

## 📋 **CHECKLIST FINAL**

Execute na ordem:

- [ ] Código de `EDGE_FUNCTION_MINIMA_FUNCIONA.ts` foi copiado para Supabase?
- [ ] Função foi deployada com sucesso?
- [ ] Testou enviar o formulário?
- [ ] Verificou console do browser (F12)?
- [ ] Verificou logs da Edge Function no Supabase?
- [ ] Verificou Network tab para ver requisição?
- [ ] Recebeu email em `virtuousensemble@gmail.com`?

---

## 🎯 **CÓDIGO MÍNIMO DE TESTE**

Se ainda não funcionar, teste este código MUITO SIMPLES primeiro:

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers });
  }

  try {
    const body = await req.json();
    return new Response(
      JSON.stringify({ success: true, received: body }),
      { status: 200, headers }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers }
    );
  }
});
```

**Se este código funcionar** (retornar `{success: true}`), então o problema está no código de envio de email.

**Se não funcionar**, pode ser problema de deploy ou configuração do Supabase.
