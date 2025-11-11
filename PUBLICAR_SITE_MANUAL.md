# 📋 Passo a Passo: Publicar Site Manualmente

## 🎯 Visão Geral

Este guia explica como publicar o site React + Vite manualmente no cPanel da Dominios.pt, incluindo build local, upload e configuração.

---

## 📦 Parte 1: Build Local (Windows)

### Passo 1: Fazer Build Localmente

No seu computador Windows, execute:

```powershell
.\build-and-deploy.ps1
```

Isso vai:
- ✅ Instalar dependências (se necessário)
- ✅ Fazer build do projeto
- ✅ Criar pasta `dist/` com arquivos compilados
- ✅ Criar `404.html` e `.htaccess` para SPA
- ✅ Criar `dist-virtuous-harmony-hub.zip` para upload

### Passo 2: Verificar Build

Verifique se o ZIP foi criado:

```powershell
ls dist-virtuous-harmony-hub.zip
```

---

## 📤 Parte 2: Upload para o Servidor

### Passo 3: Acessar File Manager do cPanel

1. Acesse o **cPanel**
2. Vá para **File Manager**
3. Navegue até: `/home/virtuou2/repositories/virtuous-harmony-hub`

### Passo 4: Fazer Upload do ZIP

1. Clique em **Upload** (botão no topo)
2. Selecione o arquivo `dist-virtuous-harmony-hub.zip`
3. Aguarde o upload completar

### Passo 5: Extrair o ZIP

1. Clique com botão direito no arquivo `dist-virtuous-harmony-hub.zip`
2. Selecione **Extract**
3. Aguarde a extração
4. **Delete o arquivo ZIP** após extrair

### Passo 6: Verificar se dist/ foi criada

1. Verifique se a pasta `dist/` existe
2. Verifique se contém arquivos como:
   - `index.html`
   - `assets/` (pasta)
   - `.htaccess`
   - `404.html`

---

## 🔧 Parte 3: Configurar Node.js no Servidor

### Passo 7: Acessar Setup Node.js App

1. No cPanel, procure por **Setup Node.js App**
2. Ou vá em: **Software** → **Setup Node.js App**

### Passo 8: Criar/Editar Aplicação Node.js

Se já existe uma aplicação:
1. Clique na aplicação (`virtuousensemble.pt`)
2. Clique em **EDIT**

Se não existe:
1. Clique em **Create Application**

### Passo 9: Configurar Aplicação

Preencha os campos:

- **Node.js Version:** `18.20.8` (ou a versão disponível)
- **Application Root:** `repositories/virtuous-harmony-hub`
- **Application URL:** `virtuousensemble.pt` (ou deixe em branco)
- **Application Startup File:** `server.js`
- **Application Mode:** `Production`
- **Passenger Log File:** `/home/virtuou2/logs/passenger.log`

Clique em **SAVE**

---

## 📦 Parte 4: Instalar Dependências no Servidor

### Passo 10: Acessar Terminal do cPanel

1. No cPanel, procure por **Terminal**
2. Ou vá em: **Advanced** → **Terminal**

### Passo 11: Navegar para o Projeto

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
```

### Passo 12: Remover node_modules (se existir)

```bash
rm -rf node_modules
```

### Passo 13: Ativar Ambiente Virtual

```bash
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
```

### Passo 14: Instalar Dependências no Ambiente Virtual

```bash
npm ci --omit=dev --prefix /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib
```

### Passo 15: Criar Symlink node_modules

```bash
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules
```

### Passo 16: Verificar Symlink

```bash
ls -ld node_modules
```

Deve mostrar `lrwxrwxrwx` (o `l` indica symlink).

### Passo 17: Verificar Express

```bash
npm list express
```

Deve mostrar `express@4.x.x` sem erros.

---

## ✅ Parte 5: Verificar e Testar

### Passo 18: Verificar Arquivos Essenciais

```bash
# Verificar se server.js existe
ls -la server.js

# Verificar se dist/ existe
ls -la dist/index.html

# Verificar se node_modules é symlink
ls -ld node_modules
```

### Passo 19: Reiniciar Passenger

**Opção A: Via Terminal**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
mkdir -p tmp
touch tmp/restart.txt
```

**Opção B: Via cPanel**

1. **Setup Node.js App**
2. Clique na aplicação
3. Clique em **RESTART**

### Passo 20: Health Check

```bash
curl https://virtuousensemble.pt/__health
```

Deve retornar: `ok`

### Passo 21: Verificar Site

Abra no navegador:

```
https://virtuousensemble.pt/
```

O site deve carregar normalmente.

---

## 🔍 Parte 6: Troubleshooting

### Se o Health Check não funcionar:

```bash
# Verificar logs do Passenger
tail -50 /home/virtuou2/logs/passenger.log

# Verificar se o server.js está sendo executado
ps aux | grep node

# Verificar se express está instalado
npm list express
```

### Se o site não carregar:

1. Verifique se `dist/index.html` existe
2. Verifique se `server.js` existe
3. Verifique se `node_modules` é symlink
4. Verifique os logs do Passenger

### Se houver erro de módulo não encontrado:

```bash
# Reinstalar dependências
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm ci --omit=dev --prefix /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib
```

---

## 📝 Checklist Completo

### Build Local:
- [ ] `.\build-and-deploy.ps1` executado com sucesso
- [ ] `dist-virtuous-harmony-hub.zip` criado

### Upload:
- [ ] ZIP enviado via File Manager
- [ ] ZIP extraído
- [ ] Pasta `dist/` criada com arquivos

### Configuração Node.js:
- [ ] Aplicação Node.js criada/editada no cPanel
- [ ] `server.js` configurado como startup file
- [ ] Ambiente virtual ativado

### Dependências:
- [ ] `node_modules` removido
- [ ] Dependências instaladas no ambiente virtual
- [ ] Symlink `node_modules` criado
- [ ] `express` verificado

### Verificação:
- [ ] `server.js` existe
- [ ] `dist/index.html` existe
- [ ] `node_modules` é symlink
- [ ] Passenger reiniciado
- [ ] Health check retorna `ok`
- [ ] Site carrega no navegador

---

## 🔄 Atualizações Futuras

Sempre que fizer alterações no código:

1. **Build local:** `.\build-and-deploy.ps1`
2. **Upload:** Enviar novo `dist-virtuous-harmony-hub.zip` e extrair
3. **Reiniciar:** `touch tmp/restart.txt` ou RESTART no cPanel

---

## 📚 Comandos Rápidos de Referência

```bash
# Navegar para o projeto
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Ativar ambiente virtual
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate

# Instalar dependências
npm ci --omit=dev --prefix /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib

# Criar symlink
ln -sf /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/lib/node_modules node_modules

# Reiniciar Passenger
touch tmp/restart.txt

# Health check
curl https://virtuousensemble.pt/__health
```

---

## ✅ Resumo dos Passos Principais

1. **Build local** → `.\build-and-deploy.ps1`
2. **Upload ZIP** → File Manager → Extract
3. **Configurar Node.js** → Setup Node.js App → `server.js`
4. **Instalar dependências** → Terminal → `npm ci --prefix`
5. **Criar symlink** → `ln -sf`
6. **Reiniciar** → `touch tmp/restart.txt`
7. **Verificar** → `curl https://virtuousensemble.pt/__health`

---

**Nota:** Este processo manual é necessário porque o build no servidor falha por limitações de memória LVE. O build sempre deve ser feito localmente.

