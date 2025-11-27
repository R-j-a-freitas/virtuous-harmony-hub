# Corrigir .cpanel.yml no Servidor

## 🔴 Problema Identificado

O `.cpanel.yml` no servidor ainda tem a versão antiga:

```yaml
- /bin/bash -lc "cd $APPROOT && ... npm run build"
```

Isso causa o erro `vite: command not found` durante o deploy.

## ✅ Solução: Sincronizar com GitHub

### Passo 1: Sincronizar .cpanel.yml

No terminal do cPanel, execute:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
```

### Passo 2: Verificar se foi atualizado

```bash
cat .cpanel.yml | grep -i build
```

**NÃO deve mostrar nada** (ou mostrar apenas comentários).

### Passo 3: Verificar conteúdo completo

```bash
cat .cpanel.yml
```

Deve mostrar algo como:

```yaml
---
deployment:
  tasks:
    - export APPROOT=/home/virtuou2/repositories/virtuous-harmony-hub
    # IMPORTANTE: Build é feito LOCALMENTE...
    - /bin/bash -lc "cd $APPROOT && ... npm ci --production"
    - /bin/bash -lc "cd $APPROOT && if [ ! -d 'dist' ]..."
    - /bin/bash -lc "mkdir -p $APPROOT/tmp && touch $APPROOT/tmp/restart.txt..."
```

**NÃO** deve ter `npm run build` ou `vite build`.

### Passo 4: Verificar se dist/ existe (já existe ✅)

```bash
ls -la dist/index.html
```

Deve mostrar o arquivo (já confirmado que existe).

### Passo 5: Fazer Deploy

No cPanel:
1. **Git Version Control** → **Manage**
2. Clique em **Update from Remote**
3. Clique em **Deploy HEAD Commit**

Agora deve funcionar sem tentar fazer build!

---

## 🔍 Verificação Final

Após o deploy, verifique:

```bash
# Health check
curl https://virtuousensemble.pt/__health

# Deve retornar: ok
```

---

## 📝 Comandos Rápidos (Copiar e Colar)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
cat .cpanel.yml | grep -i build
# Não deve mostrar nada (ou apenas comentários)
ls -la dist/index.html
# Deve mostrar o arquivo
```


