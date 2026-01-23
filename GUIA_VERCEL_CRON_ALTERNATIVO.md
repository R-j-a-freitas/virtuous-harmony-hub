# 🔄 Alternativa: Usar Serviços Externos para Chamar a Edge Function

Se o pg_cron do Supabase não estiver disponível, você pode usar serviços externos para chamar a Edge Function `keep-db-active` periodicamente.

## 📋 Opções Disponíveis

### Opção 1: GitHub Actions (Gratuito)

Crie um workflow que executa diariamente:

1. Crie o ficheiro `.github/workflows/keep-db-active.yml`:

```yaml
name: Keep DB Active

on:
  schedule:
    - cron: '0 2 * * *'  # Todos os dias às 02:00 UTC
  workflow_dispatch:  # Permite execução manual

jobs:
  keepalive:
    runs-on: ubuntu-latest
    steps:
      - name: Call Supabase Edge Function
        run: |
          curl -X POST \
            'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active' \
            -H 'Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}' \
            -H 'Content-Type: application/json'
```

2. Configure o secret no GitHub:
   - Repositório → **Settings** → **Secrets and variables** → **Actions**
   - Adicione `SUPABASE_ANON_KEY` com sua chave anon do Supabase

### Opção 2: cron-job.org (Gratuito)

1. Aceda a: https://cron-job.org
2. Crie uma conta gratuita
3. Crie um novo cron job:
   - **URL**: `https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active`
   - **Método**: POST
   - **Headers**: 
     - `Authorization: Bearer SUA_ANON_KEY`
     - `Content-Type: application/json`
   - **Schedule**: Diariamente às 02:00 UTC
   - **Body**: `{}`

### Opção 3: EasyCron (Gratuito)

1. Aceda a: https://www.easycron.com
2. Crie uma conta gratuita
3. Configure:
   - **URL**: `https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active`
   - **Método**: POST
   - **Headers**: Adicione `Authorization: Bearer SUA_ANON_KEY`
   - **Cron Expression**: `0 2 * * *`

### Opção 4: Vercel Cron (Se usar Vercel)

Se o seu projeto estiver no Vercel, pode criar uma API route simples que chama a Edge Function:

1. Crie `api/cron-keepalive.ts`:

```typescript
export default async function handler(req: any, res: any) {
  // Verificar se é uma chamada do cron (Vercel adiciona header especial)
  const authHeader = req.headers['authorization'];
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const response = await fetch(
      'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    const data = await response.json();
    return res.status(200).json(data);
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
}
```

2. Configure no `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron-keepalive",
      "schedule": "0 2 * * *"
    }
  ]
}
```

3. Configure as variáveis de ambiente no Vercel:
   - `CRON_SECRET`: Uma chave secreta qualquer
   - `SUPABASE_ANON_KEY`: Sua chave anon do Supabase

## 🔍 Testar Manualmente

Antes de configurar o cron, teste a Edge Function manualmente:

```bash
curl -X POST \
  'https://mhzhxwmxnofltgdmshcq.supabase.co/functions/v1/keep-db-active' \
  -H 'Authorization: Bearer SUA_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{}'
```

Deve retornar:
```json
{
  "success": true,
  "message": "Base de dados mantida ativa com sucesso",
  "timestamp": "2025-01-29T02:00:00.000Z",
  "operations": {
    "insert": "success",
    "delete": "success",
    "cleanup": "success"
  }
}
```

## 📝 Notas Importantes

- Use a chave **anon** (não service_role) para chamar a Edge Function externamente
- A Edge Function usa service_role internamente para bypass RLS
- Todos os serviços acima são gratuitos para uso básico
- Recomendamos usar **GitHub Actions** se o código já estiver no GitHub

---

**Última atualização**: Janeiro 2025
