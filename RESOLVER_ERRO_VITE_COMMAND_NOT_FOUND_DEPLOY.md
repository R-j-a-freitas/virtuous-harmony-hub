# Resolver Erro "vite: command not found" no Deploy

## 🔴 Problema

Durante o deploy, aparece o erro:

```
returncode: 127
stdout: > vite_react_shadcn_ts@0.0.0 build > vite build
stderr: sh: vite: command not found
```

## 🔍 Causa

Algum processo está tentando executar `npm run build` no servidor, mas:
1. O `vite` não está instalado (não precisa estar, pois build é feito localmente)
2. Mesmo se estivesse, falharia por falta de memória WebAssembly

## ✅ Solução

### Passo 1: Verificar .cpanel.yml no Servidor

No terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
cat .cpanel.yml
```

O arquivo **NÃO** deve conter `npm run build` ou `vite build`. Deve conter apenas:
- `npm ci --production`
- Verificação se `dist/` existe
- `touch tmp/restart.txt`

### Passo 2: Sincronizar com GitHub

Se o `.cpanel.yml` no servidor estiver desatualizado:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
cat .cpanel.yml
```

### Passo 3: Garantir que dist/ Existe

O deploy vai falhar se `dist/` não existir. Faça upload da pasta `dist/`:

1. **No Windows:** Execute `.\build-and-deploy.ps1` para criar o ZIP
2. **No cPanel - File Manager:**
   - Navegue até `/home/virtuou2/repositories/virtuous-harmony-hub`
   - Faça upload do `dist-virtuous-harmony-hub.zip`
   - Extract o ZIP
   - Delete o ZIP

3. **Verificar no terminal:**
   ```bash
   ls -la dist/index.html
   ```
   Deve mostrar o arquivo.

### Passo 4: Fazer Deploy Novamente

No cPanel:
1. **Git Version Control** → **Manage**
2. Clique em **Update from Remote**
3. Clique em **Deploy HEAD Commit**

Agora deve funcionar sem tentar fazer build.

---

## 🐛 Se o Erro Persistir

### Verificar se há outros processos tentando fazer build

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
grep -r "npm run build" .cpanel.yml package.json
```

Não deve encontrar nada em `.cpanel.yml`.

### Verificar logs do deploy

No cPanel, após fazer deploy, verifique se há mensagens de erro específicas.

### Verificar se package.json tem script de build

O `package.json` pode ter `"build": "vite build"`, mas isso é normal - o `.cpanel.yml` não deve chamar esse script.

---

## ✅ Checklist

- [ ] `.cpanel.yml` no servidor está atualizado (sem `npm run build`)
- [ ] `dist/` existe no servidor (feito upload via File Manager)
- [ ] `dist/index.html` existe
- [ ] `npm ci --production` executado com sucesso
- [ ] Deploy feito via cPanel (Update from Remote → Deploy HEAD Commit)

---

## 📝 Nota Importante

**NUNCA** tente fazer `npm run build` no servidor. Sempre falha por:
1. `vite` não está no PATH (mesmo após `npm install`)
2. Falta de memória WebAssembly (limites LVE)

**SEMPRE** faça build localmente e faça upload da pasta `dist/`.

