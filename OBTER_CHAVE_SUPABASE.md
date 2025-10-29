# 🔧 **INSTRUÇÕES PARA OBTER A CHAVE CORRETA DO SUPABASE**

## **Passo 1: Acessar o Dashboard**
1. Vá para: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto "virtuous-harmony-hub"

## **Passo 2: Obter a Chave API**
1. No menu lateral, clique em **"Settings"**
2. Clique em **"API"**
3. Na secção **"Project API keys"**, copie a chave **"anon public"**

## **Passo 3: Atualizar o Código**
1. Abra o ficheiro: `src/integrations/supabase/client.ts`
2. Substitua a linha 6:
   ```typescript
   const SUPABASE_ANON_KEY = 'SUA_CHAVE_AQUI';
   ```
3. Cole a chave que copiou do dashboard

## **Passo 4: Verificar a URL**
A URL já está correta:
```
https://mhzhxwmxnofltgdmshcq.supabase.co
```

## **Passo 5: Reiniciar o Servidor**
Após fazer as alterações:
1. Pare o servidor (Ctrl+C)
2. Execute novamente: `node_modules\.bin\vite.cmd`

## **🔍 Debug Adicional**
Se ainda não funcionar, adicione este código temporário no componente Admin.tsx para debug:

```typescript
// Adicionar no início do componente Admin
console.log('Supabase URL:', supabase.supabaseUrl);
console.log('Supabase Key:', supabase.supabaseKey?.substring(0, 20) + '...');
```

## **📋 Checklist**
- [ ] Chave API copiada do dashboard
- [ ] Chave atualizada no código
- [ ] Servidor reiniciado
- [ ] Testado o login novamente
