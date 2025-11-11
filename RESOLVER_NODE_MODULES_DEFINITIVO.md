# Resolver node_modules Definitivamente no CloudLinux

## 🔴 Problema Persistente

Mesmo após criar symlink, o npm ainda detecta pasta `node_modules` real e dá erro.

## ✅ Solução Definitiva

### Passo 1: Verificar se há node_modules real

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Verificar se é diretório ou symlink
ls -ld node_modules
```

Se mostrar `d` no início, é um diretório (errado). Se mostrar `l`, é symlink (correto).

### Passo 2: Remover COMPLETAMENTE node_modules

```bash
# Remover qualquer node_modules (diretório ou symlink)
rm -rf node_modules

# Verificar se foi removido
ls -la node_modules 2>&1
# Deve mostrar: "No such file or directory"
```

### Passo 3: Verificar se o diretório do ambiente virtual existe

```bash
# Verificar se o diretório do ambiente virtual existe
ls -la /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules

# Se não existir, criar
mkdir -p /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

### Passo 4: Criar symlink CORRETAMENTE

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Criar symlink (usar caminho absoluto)
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules

# Verificar se é symlink
ls -ld node_modules
```

Deve mostrar:
```
lrwxrwxrwx ... node_modules -> /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

O `l` no início confirma que é symlink.

### Passo 5: Ativar ambiente virtual e instalar

```bash
# Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Verificar se está ativo
echo $VIRTUAL_ENV
# Deve mostrar: /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18

# Instalar dependências (agora vai instalar no ambiente virtual)
npm ci --omit=dev
```

### Passo 6: Verificar express

```bash
npm list express
```

Agora deve funcionar sem erros.

---

## 🔄 Script Completo (Copiar e Colar)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# 1. Remover completamente
rm -rf node_modules

# 2. Verificar se foi removido
ls -la node_modules 2>&1 || echo "OK: node_modules removido"

# 3. Criar diretório do ambiente virtual se não existir
mkdir -p /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules

# 4. Criar symlink
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules

# 5. Verificar se é symlink
ls -ld node_modules
# Deve mostrar: lrwxrwxrwx (o 'l' indica symlink)

# 6. Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# 7. Instalar dependências
npm ci --omit=dev

# 8. Verificar express
npm list express
```

---

## 🐛 Se Ainda Não Funcionar

### Opção 1: Recriar Aplicação Node.js no cPanel

1. No cPanel → **Setup Node.js App**
2. Clique na aplicação
3. Clique em **DELETE** (⚠️ CUIDADO - isso apaga a aplicação)
4. Crie uma nova aplicação:
   - **Node.js version:** `18.20.8`
   - **Application root:** `repositories/virtuous-harmony-hub`
   - **Application startup file:** `server.js`
   - **Application URL:** `virtuousensemble.pt`
5. Isso recriará o ambiente virtual e o symlink automaticamente

### Opção 2: Verificar se há node_modules em subdiretórios

```bash
# Procurar por node_modules em qualquer lugar
find . -name "node_modules" -type d

# Se encontrar algum, remover
find . -name "node_modules" -type d -exec rm -rf {} +
```

### Opção 3: Verificar permissões

```bash
# Verificar permissões do diretório do ambiente virtual
ls -ld /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules

# Se necessário, ajustar
chmod 755 /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

---

## ✅ Verificação Final

```bash
# 1. Verificar se é symlink
ls -ld node_modules
# Deve mostrar: lrwxrwxrwx (o 'l' indica symlink)

# 2. Verificar se express está instalado
npm list express
# Não deve dar erro

# 3. Verificar se server.js existe
ls -la server.js

# 4. Verificar se dist/ existe
ls -la dist/index.html
```

---

## 📝 Nota Importante

O symlink **DEVE** ser criado ANTES de executar `npm install` ou `npm ci`. Se você executar `npm install` sem o symlink, o npm criará uma pasta real `node_modules`, o que causa o erro.

**Ordem correta:**
1. Remover `node_modules` (se existir)
2. Criar symlink
3. Ativar ambiente virtual
4. Instalar dependências

