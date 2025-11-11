# Resolver Erro: "vite: command not found" no cPanel

## Problema

Ao executar o script `dev` ou `build:dev` via "Run JS Script" no cPanel, aparece o erro:

```
returncode: 127
stderr: sh: vite: command not found
```

## Causa

O erro acontece porque:
1. **As dependências não estão instaladas** - O diretório `node_modules` não existe ou está incompleto
2. **O npm/vite não está no PATH** - Quando o cPanel executa o script, o ambiente não tem acesso ao npm
3. **O ambiente Node.js não está configurado** - O cPanel precisa ter o Node.js configurado via "Setup Node.js App"

## Solução Passo a Passo

### Passo 1: Verificar Configuração do Node.js no cPanel

1. No cPanel, procure por **"Setup Node.js App"** (na barra de pesquisa ou em Software/Advanced)
2. Verifique se existe uma aplicação configurada para o seu projeto
3. Se não existir, crie uma:
   - **Node.js Version**: Escolha **18.x** ou **20.x** (Vite 5 requer Node.js 18+)
   - **Application Root**: `/home/virtuou2/repositories/virtuous-harmony-hub`
   - **Application URL**: (pode deixar em branco)
   - **Application Startup File**: (não necessário para build)

### Passo 2: Instalar Dependências ANTES de Executar Scripts

**IMPORTANTE:** Antes de executar qualquer script (`dev`, `build`, etc.), você precisa instalar as dependências primeiro.

#### Opção A: Via Terminal SSH (Recomendado)

Se tiver acesso SSH:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Encontrar o npm do ambiente virtual do cPanel
NPM_PATH="/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/20/bin/npm"
# Ou tente versão 18:
# NPM_PATH="/home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/npm"

# Se não encontrar, tente:
# NPM_PATH="/opt/cpanel/ea-nodejs20/bin/npm"
# ou
# NPM_PATH="/opt/cpanel/ea-nodejs18/bin/npm"

# Verificar se o npm existe
if [ -f "$NPM_PATH" ]; then
    echo "npm encontrado em: $NPM_PATH"
    "$NPM_PATH" --version
else
    echo "npm não encontrado. Verifique a configuração do Node.js no cPanel."
    exit 1
fi

# Instalar dependências
"$NPM_PATH" install

# Agora pode executar os scripts
"$NPM_PATH" run build:dev
```

#### Opção B: Via "Run JS Script" no cPanel

1. No cPanel, vá para **"Setup Node.js App"**
2. Clique na sua aplicação
3. Na secção **"Run Script"**, execute primeiro:

```bash
npm install
```

4. Aguarde a conclusão (pode demorar alguns minutos)
5. Depois execute:

```bash
npm run build:dev
```

### Passo 3: Usar o Caminho Completo do npm nos Scripts

Se continuar a ter problemas, você pode modificar os scripts do `package.json` para usar o caminho completo do npm. Mas a melhor solução é garantir que o ambiente Node.js está configurado corretamente.

## Verificação Rápida

Para verificar se tudo está configurado:

1. **Verificar se Node.js está instalado:**
   ```bash
   /opt/cpanel/ea-nodejs20/bin/node --version
   # ou
   /opt/cpanel/ea-nodejs18/bin/node --version
   ```

2. **Verificar se npm está disponível:**
   ```bash
   /opt/cpanel/ea-nodejs20/bin/npm --version
   # ou
   /opt/cpanel/ea-nodejs18/bin/npm --version
   ```

3. **Verificar se node_modules existe:**
   ```bash
   ls -la /home/virtuou2/repositories/virtuous-harmony-hub/node_modules | head -10
   ```

## Solução Alternativa: Usar Deploy Automático

Em vez de executar scripts manualmente, use o **deploy automático** do cPanel:

1. No cPanel, vá para **"Git™ Version Control"**
2. Clique em **"Deploy HEAD Commit"**
3. O script `.cpanel.yml` será executado automaticamente
4. Ele instala as dependências e faz o build automaticamente

Isso é mais confiável porque o `.cpanel.yml` já está configurado para:
- Encontrar o npm em várias localizações
- Instalar dependências automaticamente
- Fazer o build do projeto
- Copiar os arquivos para `public_html`

## Erros Comuns

### Erro: "npm: command not found"
- **Solução**: Configure o Node.js via "Setup Node.js App" no cPanel

### Erro: "Node.js version too old"
- **Solução**: Atualize para Node.js 18 ou 20 no "Setup Node.js App"

### Erro: "Permission denied"
- **Solução**: Verifique as permissões do diretório do projeto

## Resumo

1. ✅ Configure Node.js 18+ via "Setup Node.js App"
2. ✅ Execute `npm install` ANTES de executar qualquer script
3. ✅ Use o deploy automático (recomendado) em vez de executar scripts manualmente
4. ✅ Se precisar executar manualmente, use o caminho completo do npm

---

**Nota:** O deploy automático via `.cpanel.yml` é a forma mais confiável, pois já está configurado para lidar com todos esses problemas automaticamente.



