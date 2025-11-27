# Criar Symlink node_modules Manualmente no CloudLinux

## 🔴 Problema

Mesmo após remover `node_modules` e reinstalar, ainda são diretórios e não symlinks.

## ✅ Solução: Criar Symlink Manualmente

### Passo 1: Remover node_modules existente

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -rf node_modules
```

### Passo 2: Verificar caminho do ambiente virtual

```bash
# Verificar caminho do ambiente virtual
echo $VIRTUAL_ENV
# Deve mostrar: /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18

# Ou verificar diretamente
ls -la /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

### Passo 3: Criar symlink manualmente

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Criar symlink apontando para o ambiente virtual
ln -s /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules
```

### Passo 4: Verificar se é symlink

```bash
ls -la node_modules
```

Deve mostrar:
```
lrwxrwxrwx 1 virtuou2 virtuou2 89 Nov 11 10:00 node_modules -> /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

O `l` no início indica que é um symlink.

### Passo 5: Instalar dependências no ambiente virtual

```bash
# Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Instalar dependências (agora vai instalar no ambiente virtual, não na pasta local)
npm ci --omit=dev
```

### Passo 6: Verificar se express está instalado

```bash
npm list express
```

Agora deve funcionar sem erros.

---

## 🔄 Script Completo (Copiar e Colar)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# 1. Remover node_modules real
rm -rf node_modules

# 2. Criar symlink
ln -s /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules

# 3. Verificar se é symlink
ls -la node_modules | head -1

# 4. Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# 5. Instalar dependências
npm ci --omit=dev

# 6. Verificar express
npm list express
```

---

## 🐛 Se o symlink não funcionar

### Verificar se o caminho do ambiente virtual está correto

```bash
# Verificar se o diretório existe
ls -la /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules

# Se não existir, criar
mkdir -p /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

### Verificar permissões

```bash
# Verificar permissões do diretório do ambiente virtual
ls -ld /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules

# Se necessário, ajustar permissões
chmod 755 /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

### Recriar aplicação Node.js no cPanel

Se nada funcionar, recrie a aplicação:

1. No cPanel → **Setup Node.js App**
2. Clique na aplicação
3. Clique em **DELETE** (cuidado!)
4. Crie uma nova aplicação:
   - **Node.js version:** `18.20.8`
   - **Application root:** `repositories/virtuous-harmony-hub`
   - **Application startup file:** `server.js`
5. Isso recriará o ambiente virtual e o symlink

---

## ✅ Verificação Final

```bash
# 1. Verificar se é symlink
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

## 📝 Nota Importante

O symlink deve apontar para:
```
/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules
```

Se o caminho for diferente, ajuste o comando `ln -s` acima.


