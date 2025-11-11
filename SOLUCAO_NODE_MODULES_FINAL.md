# Solução Final: node_modules Symlink no CloudLinux

## 🔴 Problema

O `npm ci` transforma o symlink em diretório real, causando erro do CloudLinux.

## ✅ Solução: Instalar no Ambiente Virtual Primeiro

### Passo 1: Remover node_modules completamente

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -rf node_modules
```

### Passo 2: Instalar dependências DIRETAMENTE no ambiente virtual

```bash
# Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Navegar para o diretório do ambiente virtual
cd /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib

# Copiar package.json e package-lock.json para o ambiente virtual (temporariamente)
cp /home/virtuou2/repositories/virtuous-harmony-hub/package.json .
cp /home/virtuou2/repositories/virtuous-harmony-hub/package-lock.json .

# Instalar dependências DIRETAMENTE no ambiente virtual
npm ci --omit=dev

# Voltar para o diretório do projeto
cd /home/virtuou2/repositories/virtuous-harmony-hub
```

### Passo 3: Criar symlink APÓS instalação

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Criar symlink apontando para o ambiente virtual (onde as dependências estão)
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules

# Verificar se é symlink
ls -ld node_modules
```

Deve mostrar `lrwxrwxrwx` (o `l` indica symlink).

### Passo 4: Verificar express

```bash
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm list express
```

---

## 🔄 Método Alternativo: Usar --prefix

### Passo 1: Remover node_modules

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -rf node_modules
```

### Passo 2: Instalar usando --prefix diretamente no ambiente virtual

```bash
# Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Instalar usando --prefix para instalar diretamente no ambiente virtual
npm ci --omit=dev --prefix /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib

# Criar symlink
cd /home/virtuou2/repositories/virtuous-harmony-hub
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules

# Verificar
ls -ld node_modules
```

---

## 🎯 Método Recomendado: Script Completo

Crie um script `install-deps.sh`:

```bash
#!/bin/bash
# Script para instalar dependências no ambiente virtual e criar symlink

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"
NODEVENV="/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18"

echo "==== Instalando dependências no ambiente virtual ===="

# 1. Remover node_modules
cd "$APPROOT"
rm -rf node_modules

# 2. Ativar ambiente virtual
source "$NODEVENV/bin/activate"

# 3. Instalar dependências diretamente no ambiente virtual usando --prefix
npm ci --omit=dev --prefix "$NODEVENV/lib"

# 4. Criar symlink
cd "$APPROOT"
ln -sf "$NODEVENV/lib/node_modules" node_modules

# 5. Verificar
echo ""
echo "==== Verificando ===="
ls -ld node_modules
echo ""
npm list express --prefix "$NODEVENV/lib"

echo ""
echo "==== Concluido! ===="
```

**Para executar:**

```bash
chmod +x install-deps.sh
./install-deps.sh
```

---

## 🔧 Solução Definitiva: Atualizar .cpanel.yml

Atualize o `.cpanel.yml` para instalar diretamente no ambiente virtual:

```yaml
---
deployment:
  tasks:
    - export APPROOT=/home/virtuou2/repositories/virtuous-harmony-hub
    - export NODEVENV=/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18
    # Remover node_modules se existir
    - /bin/bash -lc "cd $APPROOT && rm -rf node_modules"
    # Instalar dependências diretamente no ambiente virtual
    - /bin/bash -lc "cd $APPROOT && source $NODEVENV/bin/activate && npm ci --omit=dev --prefix $NODEVENV/lib"
    # Criar symlink
    - /bin/bash -lc "cd $APPROOT && ln -sf $NODEVENV/lib/node_modules node_modules"
    # Verificar se dist/ existe
    - /bin/bash -lc "cd $APPROOT && if [ ! -d 'dist' ] || [ ! -f 'dist/index.html' ]; then echo 'ERRO: dist/ nao encontrada.'; exit 1; fi"
    # Reiniciar Passenger
    - /bin/bash -lc "mkdir -p $APPROOT/tmp && touch $APPROOT/tmp/restart.txt"
```

---

## 📝 Comandos Rápidos (Copiar e Colar)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -rf node_modules
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm ci --omit=dev --prefix /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules
ls -ld node_modules
npm list express
```

---

## ✅ Verificação Final

```bash
# 1. Verificar se é symlink
ls -ld node_modules
# Deve mostrar: lrwxrwxrwx (o 'l' indica symlink)

# 2. Verificar se express está instalado
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm list express
# Não deve dar erro

# 3. Verificar se server.js pode acessar express
node -e "require('express')"
# Não deve dar erro
```

---

## 🎯 Resumo

**O problema:** `npm ci` cria `node_modules` localmente mesmo com symlink.

**A solução:** Instalar diretamente no ambiente virtual usando `--prefix`, depois criar o symlink.

**Ordem correta:**
1. Remover `node_modules`
2. Instalar com `npm ci --prefix /caminho/do/ambiente/virtual/lib`
3. Criar symlink apontando para o ambiente virtual
4. Verificar

