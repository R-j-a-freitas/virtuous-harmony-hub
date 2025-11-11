# Solução Rápida: Erro "vite: command not found"

## O Problema

Ao executar `build:dev` via "Run JS Script" no cPanel, aparece:
```
sh: vite: command not found
```

## A Causa

**As dependências não estão instaladas!** O diretório `node_modules` não existe ou está incompleto.

## Solução em 3 Passos

### Passo 1: Instalar Dependências PRIMEIRO

No cPanel, vá para **"Setup Node.js App"** → Clique na sua aplicação → Na secção **"Run Script"**, execute:

```bash
npm install
```

**Aguarde a conclusão** (pode demorar 2-5 minutos)

### Passo 2: Verificar se Instalou

Execute para verificar:

```bash
ls -la node_modules | head -5
```

Se aparecer arquivos, está instalado! ✅

### Passo 3: Agora Execute o Build

Depois de instalar as dependências, execute:

```bash
npm run build:dev
```

## Por Que Isso Acontece?

O cPanel executa os scripts do `package.json`, mas **não instala as dependências automaticamente**. Você precisa executar `npm install` primeiro.

## Solução Automática (Recomendada)

Em vez de executar scripts manualmente, use o **deploy automático**:

1. No cPanel, vá para **"Git™ Version Control"**
2. Clique em **"Deploy HEAD Commit"**
3. O `.cpanel.yml` instala as dependências e faz o build automaticamente ✅

## Se Ainda Não Funcionar

### Verificar Node.js

1. No cPanel, vá para **"Setup Node.js App"**
2. Verifique se a versão é **18.x** ou **20.x** (não 10.x ou 16.x)
3. Se não for, mude para 18 ou 20 e clique em **"SAVE"**

### Verificar npm

Execute no "Run Script":

```bash
which npm
npm --version
```

Se não aparecer nada, o Node.js não está configurado corretamente.

## Resumo

✅ **Sempre execute `npm install` ANTES de executar qualquer script**
✅ **Use o deploy automático** (mais confiável)
✅ **Verifique se Node.js 18+ está configurado**

---

**Nota:** Os scripts do `package.json` foram atualizados para usar `npx`, o que ajuda, mas ainda precisa das dependências instaladas primeiro.



