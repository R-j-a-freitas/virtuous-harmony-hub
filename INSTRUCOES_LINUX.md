# Instruções Linux - Resolver Conflito e Deploy

## 🔧 Resolver Conflito do package.json

### Passo 1: Acessar o Terminal do cPanel

1. No cPanel, vá para **Terminal** (ou use SSH se tiver acesso)
2. Navegue para o diretório do projeto:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
```

### Passo 2: Verificar Status do Git

```bash
git status
```

Isso mostrará os arquivos com conflito (provavelmente `package.json`).

### Passo 3: Resolver o Conflito

**Opção A: Reset Hard (Recomendado - Perde mudanças locais)**

```bash
# Buscar alterações do GitHub
git fetch origin

# Descartar todas as mudanças locais e sincronizar com GitHub
git reset --hard origin/main
```

**Opção B: Stash das Mudanças Locais**

```bash
# Guardar mudanças locais temporariamente
git stash

# Buscar alterações do GitHub
git pull origin main
```

**Opção C: Restaurar apenas o package.json**

```bash
# Descartar mudanças apenas no package.json
git checkout -- package.json

# Buscar alterações do GitHub
git pull origin main
```

### Passo 4: Verificar se Está Sincronizado

```bash
git status
```

Deve mostrar: `Your branch is up to date with 'origin/main'`

---

## 🚀 Fazer Deploy no cPanel

### Passo 1: Atualizar do GitHub

1. No cPanel, vá para **Git™ Version Control**
2. Clique em **Manage** no seu repositório
3. Clique em **Update from Remote**
4. Aguarde a conclusão

### Passo 2: Fazer Deploy

1. Na mesma página, clique em **Deploy HEAD Commit**
2. O `.cpanel.yml` será executado automaticamente:
   - Instala dependências (`npm ci --include=dev`)
   - Faz build (`npx vite build`)
   - Reinicia Passenger (`touch tmp/restart.txt`)

---

## 🔍 Verificar se o Build Funcionou

### Verificar se a pasta dist foi criada:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
ls -la dist/
```

Deve mostrar arquivos como `index.html`, `assets/`, etc.

### Verificar se o server.js existe:

```bash
ls -la server.js
```

### Verificar logs do deploy (se houver):

```bash
cat /home/virtuou2/public_html/deploy_log.txt
```

---

## 🐛 Troubleshooting

### Erro: "vite: command not found"

Se ainda receber este erro, verifique se o vite está instalado:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm list vite
```

Se não estiver instalado:

```bash
npm install vite --save-dev
```

### Erro: "npm ci failed"

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
rm -rf node_modules package-lock.json
npm install
```

### Verificar versão do Node.js:

```bash
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
node --version
```

Deve ser `v18.x.x` ou superior.

---

## 📋 Script Automático Completo

Crie um arquivo `fix-and-deploy.sh` no servidor:

```bash
#!/bin/bash
# Script para resolver conflitos e fazer deploy

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"

echo "==== Resolvendo conflitos Git ===="
cd "$APPROOT" || exit 1

# Resolver conflitos
git fetch origin
git reset --hard origin/main

echo ""
echo "==== Verificando status ===="
git status

echo ""
echo "==== Ativando ambiente Node.js ===="
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

echo ""
echo "==== Instalando dependencias ===="
npm ci --include=dev

echo ""
echo "==== Fazendo build ===="
npx vite build

echo ""
echo "==== Verificando build ===="
if [ -d "dist" ]; then
    echo "✓ Build criado com sucesso!"
    ls -la dist/ | head -10
else
    echo "✗ ERRO: Build nao foi criado!"
    exit 1
fi

echo ""
echo "==== Reiniciando Passenger ===="
mkdir -p tmp
touch tmp/restart.txt

echo ""
echo "==== Concluido! ===="
echo "Verifique o site em: https://virtuousensemble.pt"
```

**Para executar:**

```bash
chmod +x fix-and-deploy.sh
./fix-and-deploy.sh
```

---

## ✅ Verificar se o Site Está Funcionando

### Health Check:

```bash
curl https://virtuousensemble.pt/__health
```

Deve retornar: `ok`

### Verificar se o site carrega:

```bash
curl -I https://virtuousensemble.pt/
```

Deve retornar: `200 OK`

### Verificar logs do Passenger:

```bash
cat /home/virtuou2/logs/passenger.log | tail -50
```

---

## 📝 Comandos Rápidos de Referência

```bash
# Navegar para o projeto
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Ativar ambiente Node.js
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Ver status do Git
git status

# Sincronizar com GitHub
git fetch origin
git reset --hard origin/main

# Instalar dependências
npm ci --include=dev

# Fazer build
npx vite build

# Reiniciar Passenger
touch tmp/restart.txt

# Verificar build
ls -la dist/

# Ver logs
tail -f /home/virtuou2/logs/passenger.log
```

---

**Nota:** Todos os comandos devem ser executados no Terminal do cPanel ou via SSH.


