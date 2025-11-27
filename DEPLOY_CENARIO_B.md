# 🚀 Deploy - Cenário B: Node.js com Passenger

Este guia explica como fazer o deploy da aplicação React + Vite como **app Node.js** no cPanel da Dominios.pt usando Passenger.

## 📋 Pré-requisitos

- ✅ Node.js 18.20.8 configurado no cPanel (Setup Node.js App)
- ✅ Repositório Git conectado ao cPanel
- ✅ Arquivo `server.js` na raiz do projeto
- ✅ Express em `dependencies` do `package.json`

## 🔧 Configuração no cPanel

### 1. Setup Node.js App

1. Acesse **cPanel → Setup Node.js App**
2. Clique na sua aplicação (`virtuousensemble.pt`) ou crie uma nova:
   - **Node.js version:** `18.20.8`
   - **Application root:** `repositories/virtuous-harmony-hub`
   - **Application startup file:** `server.js`
   - **Application URL:** `virtuousensemble.pt`
   - **Application mode:** `Production`
   - **Passenger log file:** `/home/virtuou2/logs/passenger.log`
3. Clique em **SAVE**

### 2. Git Version Control

1. Acesse **cPanel → Git Version Control**
2. Se ainda não tiver, conecte o repositório:
   - **Repository URL:** `https://github.com/R-j-a-freitas/virtuous-harmony-hub.git`
   - **Repository Root:** `repositories/virtuous-harmony-hub`
   - **Branch:** `main`
3. Clique em **Create**
4. Após criar, clique em **Manage**
5. Vá para a aba **Pull or Deploy**
6. Clique em **Update from Remote**
7. Clique em **Deploy HEAD Commit**

O `.cpanel.yml` irá automaticamente:
- ✅ Ativar o ambiente virtual Node.js 18
- ✅ Instalar dependências (`npm ci --include=dev`)
- ✅ Fazer o build (`npm run build`)
- ✅ Reiniciar o Passenger (`touch tmp/restart.txt`)

## ✅ Verificação

Após o deploy, verifique:

### 1. Health Check
```bash
curl https://virtuousensemble.pt/__health
```
Deve retornar: `ok` (200 OK)

### 2. Site Principal
```bash
curl -I https://virtuousensemble.pt/
```
Deve retornar: `200 OK` com `Content-Type: text/html`

### 3. Logs do Passenger
Se houver problemas, verifique:
```bash
cat /home/virtuou2/logs/passenger.log
```

## 🔄 Atualizações Futuras

Sempre que fizer push para o GitHub:

1. No cPanel → Git Version Control → Manage
2. Clique em **Update from Remote**
3. Clique em **Deploy HEAD Commit**

O Passenger será reiniciado automaticamente.

## 🐛 Troubleshooting

### Erro: "Application failed to start"

1. Verifique os logs:
   ```bash
   cat /home/virtuou2/logs/passenger.log
   ```

2. Verifique se o build foi feito:
   ```bash
   ls -la /home/virtuou2/repositories/virtuous-harmony-hub/dist/
   ```

3. Verifique se o server.js existe:
   ```bash
   ls -la /home/virtuou2/repositories/virtuous-harmony-hub/server.js
   ```

### Erro: "Module not found"

1. Verifique se as dependências foram instaladas:
   ```bash
   cd /home/virtuou2/repositories/virtuous-harmony-hub
   source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
   npm list express
   ```

2. Reinstale as dependências:
   ```bash
   npm ci --include=dev
   ```

### Health Check não funciona

1. Verifique se o server.js tem a rota `/__health`
2. Verifique se o Passenger está a executar:
   ```bash
   ps aux | grep passenger
   ```
3. Reinicie a aplicação no cPanel (Setup Node.js App → RESTART)

## 📝 Notas Importantes

- O build é feito **no servidor** durante o deploy (via `.cpanel.yml`)
- A pasta `dist/` **não** deve ser commitada (está no `.gitignore`)
- O Passenger reinicia automaticamente quando `tmp/restart.txt` é atualizado
- O health check em `/__health` é necessário para o Node.js Selector funcionar corretamente


