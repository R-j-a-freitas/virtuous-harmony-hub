# Por que o botão "Deploy HEAD Commit" está inativo?

## Requisitos do cPanel para Deploy

O cPanel exige **2 requisitos** para permitir o deploy:

1. ✅ **Um arquivo `.cpanel.yml` válido existe** (já temos)
2. ❌ **Não há mudanças não commitadas no branch** (provavelmente o problema)

## Causas Comuns

### 1. Arquivos Modificados no Servidor

O cPanel verifica o repositório **no servidor**, não no GitHub. Se houver arquivos modificados ou não rastreados no servidor, o deploy será bloqueado.

### 2. Arquivos Não Rastreados

Arquivos criados manualmente no servidor (como `app.js` que removemos) podem causar problemas.

## Solução Passo a Passo

### Opção 1: Verificar e Limpar Mudanças no Servidor (Recomendado)

**Via File Manager:**

1. No cPanel, vá para **File Manager**
2. Navegue até: `/home/virtuou2/repositories/virtuous-harmony-hub`
3. Procure por arquivos que não deveriam estar lá:
   - Arquivos temporários
   - Arquivos `.backup`
   - Arquivos criados manualmente
4. **Delete arquivos suspeitos** (ou mova para uma pasta de backup)

**Via Terminal SSH (se tiver acesso):**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git status
```

Isso mostrará:
- Arquivos modificados
- Arquivos não rastreados
- Arquivos staged

**Para limpar:**

```bash
# Ver mudanças não commitadas
git status

# Descartar mudanças em arquivos rastreados (CUIDADO!)
git checkout -- .

# Remover arquivos não rastreados (CUIDADO - verifique primeiro!)
git clean -n  # Mostra o que será removido (dry-run)
git clean -f  # Remove arquivos não rastreados
```

### Opção 2: Fazer Commit das Mudanças no Servidor

Se houver mudanças legítimas no servidor:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git add .
git commit -m "Sincronizar mudanças do servidor"
git push origin main
```

### Opção 3: Reset Hard (CUIDADO - Perde mudanças locais)

**⚠️ ATENÇÃO: Isso apagará TODAS as mudanças não commitadas no servidor!**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
```

Isso força o repositório do servidor a ficar idêntico ao GitHub.

## Verificar se o .cpanel.yml está Válido

O cPanel pode não reconhecer o `.cpanel.yml` se:

1. **Está na raiz do repositório** ✅ (correto)
2. **Tem sintaxe YAML válida** ✅ (verificado)
3. **Está commitado no Git** ✅ (já commitado)

**Para verificar no servidor:**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
ls -la .cpanel.yml
cat .cpanel.yml | head -5
```

## Solução Rápida (Recomendada)

1. **No cPanel, vá para Git™ Version Control**
2. Clique em **"Update from Remote"** (se ainda não clicou)
3. Aguarde a conclusão
4. Se ainda estiver inativo, siga os passos acima para limpar mudanças

## Após Limpar as Mudanças

1. O botão **"Deploy HEAD Commit"** deve ficar ativo
2. Clique nele para fazer o deploy
3. O script do `.cpanel.yml` será executado automaticamente

## Verificar Logs de Erro

Se o problema persistir, verifique:

1. **Logs do cPanel:** Procure por mensagens de erro na interface
2. **Arquivo de log do deploy:** `/home/virtuou2/public_html/deploy_log.txt` (se existir)

---

**Nota:** O problema mais comum é ter arquivos modificados ou não rastreados no servidor que não estão no repositório Git. A solução é limpar esses arquivos ou fazer commit deles.

