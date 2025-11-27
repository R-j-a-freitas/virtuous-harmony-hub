# Resolver: node_modules deve ser symlink no CloudLinux

## 🔴 Problema

O CloudLinux NodeJS Selector exige que `node_modules` seja um **symlink** para o ambiente virtual, não uma pasta real.

Erro:
```
Cloudlinux NodeJS Selector demands to store node modules for application in separate folder (virtual environment) pointed by symlink called "node_modules". That's why application should not contain folder/file with such name in application root
```

## ✅ Solução

### Passo 1: Remover node_modules existente

No terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Remover a pasta node_modules real
rm -rf node_modules
```

### Passo 2: Instalar dependências novamente

O CloudLinux criará automaticamente o symlink correto:

```bash
# Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Instalar dependências (CloudLinux criará o symlink)
npm ci --omit=dev
```

### Passo 3: Verificar se é symlink

```bash
ls -la node_modules
```

Deve mostrar algo como:
```
lrwxrwxrwx 1 virtuou2 virtuou2 89 Nov 11 10:00 node_modules -> /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

Se mostrar `l` no início, é um symlink (correto).

### Passo 4: Verificar se express está instalado

```bash
npm list express
```

Agora deve funcionar sem erros.

---

## 🔍 Verificação Completa

```bash
# 1. Verificar se node_modules é symlink
ls -la node_modules | head -1
# Deve mostrar: lrwxrwxrwx (o 'l' indica symlink)

# 2. Verificar se express está instalado
npm list express

# 3. Verificar se server.js existe
ls -la server.js

# 4. Verificar se dist/ existe
ls -la dist/index.html
```

---

## 📝 Comandos Rápidos (Copiar e Colar)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -rf node_modules
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm ci --omit=dev
ls -la node_modules
npm list express
```

---

## 🐛 Se ainda não funcionar

### Verificar se o ambiente virtual está correto

```bash
# Verificar caminho do ambiente virtual
echo $VIRTUAL_ENV
# Deve mostrar: /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18

# Verificar se o diretório existe
ls -la /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

### Recriar ambiente virtual (se necessário)

No cPanel:
1. **Setup Node.js App**
2. Clique na aplicação
3. Clique em **RESTART**
4. Isso recria o ambiente virtual e o symlink

---

## ✅ Após Resolver

Após resolver o problema do symlink:

1. ✅ `node_modules` é um symlink (não uma pasta)
2. ✅ `express` está instalado
3. ✅ `dist/` existe
4. ✅ Pronto para fazer deploy

---

## 📝 Nota Importante

**NUNCA** faça commit do `node_modules` no Git. Ele deve ser um symlink criado automaticamente pelo CloudLinux.

O `.gitignore` já tem `node_modules` ignorado, então está correto.


