# Solução: "Failed to send a request to the Edge Function"

## 🔍 **PROBLEMA**

O erro "Failed to send a request to the Edge Function" indica que a função não está respondendo corretamente. Isso pode ser causado por:

1. **Erro de sintaxe no código** - A função crasha antes de responder
2. **Problema de CORS** - O browser bloqueia a resposta
3. **Dependências não carregando** - Imports falhando
4. **Função não deployada corretamente**

---

## ✅ **SOLUÇÃO PASSOS**

### **PASSO 1: Use o Código Simplificado para Teste**

Primeiro, teste com a versão simplificada:

1. No Supabase Dashboard, abra a função `send-contact-email`
2. **Substitua TODO o código** pelo conteúdo de `EDGE_FUNCTION_SIMPLIFICADA.ts`
3. Clique em **Deploy**
4. Teste o formulário novamente

**Se funcionar** → O problema está nas dependências ou complexidade do código completo.

**Se não funcionar** → Continue para o PASSO 2.

---

### **PASSO 2: Verificar Erros na Função**

1. No Supabase Dashboard:
   - Vá em: **Edge Functions** → `send-contact-email` → **Logs**
   - Procure por erros vermelhos
   - Veja a última execução

2. **Erros comuns:**
   - `Cannot find module` → Dependência não carregando
   - `SyntaxError` → Erro no código
   - `ReferenceError` → Variável não definida

---

### **PASSO 3: Verificar Console do Browser**

1. Abra o DevTools (F12)
2. Vá na aba **Network**
3. Envie o formulário
4. Procure por uma requisição para `/functions/v1/send-contact-email`
5. Clique nela e veja:
   - **Status**: Qual o código HTTP (200, 500, etc)?
   - **Response**: O que a função retornou?
   - **Preview**: Conteúdo da resposta

---

### **PASSO 4: Testar Código Mínimo**

Se ainda não funcionar, teste este código MÍNIMO:

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        received: body,
        message: 'Function is working!' 
      }),
      { 
        status: 200,
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ 
        error: 'Error',
        message: error instanceof Error ? error.message : 'Unknown'
      }),
      { 
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    );
  }
});
```

**Se este código funcionar** → O problema está no código completo.
**Se não funcionar** → Pode ser problema de deploy ou configuração do Supabase.

---

## 📋 **CHECKLIST DE VERIFICAÇÃO**

Execute na ordem:

1. [ ] Função `send-contact-email` existe no Supabase Dashboard?
2. [ ] Código simplificado foi deployado?
3. [ ] Não há erros de sintaxe no editor (código em vermelho)?
4. [ ] Console do browser mostra requisição sendo feita?
5. [ ] Logs da Edge Function mostram execução?
6. [ ] Testou o código mínimo primeiro?

---

## 🔧 **PRÓXIMOS PASSOS**

Depois de identificar onde está o problema:

- **Se erro de sintaxe**: Corrija e faça redeploy
- **Se erro de dependência**: Use a versão simplificada
- **Se não há resposta**: Verifique se a função está deployada
- **Se erro de CORS**: Os headers CORS já estão no código

---

## 📧 **ALTERNATIVA TEMPORÁRIA**

Enquanto resolve, os dados do formulário são **sempre salvos na base de dados**. Você pode:

1. Ver os pedidos no painel administrativo: `/admin`
2. Contactar os clientes diretamente usando os dados salvos

O email é um extra, mas não é crítico - os dados estão sendo guardados.
