# Solução: Build Local + Upload (Resolve Erro de Memória)

## 🔴 Problema

O build no servidor falha com erro de memória WebAssembly devido aos limites LVE do CloudLinux:

```
[RangeError: WebAssembly.instantiate(): Out of memory: wasm memory]
```

## ✅ Solução: Build Local + Upload

Como o servidor não tem memória suficiente para fazer o build, vamos fazer o build **localmente** e fazer upload apenas da pasta `dist/`.

---

## 📋 Passo a Passo

### 1. Fazer Build Localmente (Windows)

No seu computador Windows, execute:

```powershell
.\build-and-deploy.ps1
```

Isso vai:
- Instalar dependências
- Fazer build do projeto
- Criar `dist/` com os arquivos compilados
- Criar `dist-virtuous-harmony-hub.zip` para upload

### 2. Fazer Upload da Pasta dist/ para o Servidor

**Opção A: Via File Manager do cPanel (Recomendado)**

1. No cPanel, vá para **File Manager**
2. Navegue até: `/home/virtuou2/repositories/virtuous-harmony-hub`
3. **Delete a pasta `dist/` existente** (se houver)
4. Faça upload do arquivo `dist-virtuous-harmony-hub.zip`
5. Clique com botão direito no ZIP → **Extract**
6. Verifique se a pasta `dist/` foi criada com os arquivos

**Opção B: Via Terminal do cPanel**

1. Faça upload do `dist-virtuous-harmony-hub.zip` via File Manager
2. No Terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -rf dist
unzip -q dist-virtuous-harmony-hub.zip -d .
rm dist-virtuous-harmony-hub.zip
ls -la dist/
```

### 3. Reiniciar o Passenger

No Terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
mkdir -p tmp
touch tmp/restart.txt
```

Ou no cPanel:
- **Setup Node.js App** → Clique em **RESTART**

### 4. Verificar se Funcionou

```bash
# Health check
curl https://virtuousensemble.pt/__health

# Verificar site
curl -I https://virtuousensemble.pt/
```

---

## 🔄 Workflow Completo para Atualizações

Sempre que fizer alterações no código:

1. **Localmente (Windows):**
   ```powershell
   .\build-and-deploy.ps1
   ```

2. **No cPanel - File Manager:**
   - Delete `dist/` antiga
   - Upload do novo `dist-virtuous-harmony-hub.zip`
   - Extract
   - Delete o ZIP

3. **No cPanel - Terminal:**
   ```bash
   cd /home/virtuou2/repositories/virtuous-harmony-hub
   touch tmp/restart.txt
   ```

4. **Verificar:**
   - Acesse `https://virtuousensemble.pt/`

---

## 🚀 Script Automatizado para Upload (Opcional)

Crie um script `upload-dist.sh` no servidor:

```bash
#!/bin/bash
# Script para fazer upload e extrair dist/

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"
ZIPFILE="dist-virtuous-harmony-hub.zip"

cd "$APPROOT" || exit 1

if [ ! -f "$ZIPFILE" ]; then
    echo "ERRO: $ZIPFILE nao encontrado!"
    echo "Faca upload do ZIP via File Manager primeiro."
    exit 1
fi

echo "==== Extraindo dist/ ===="
rm -rf dist
unzip -q "$ZIPFILE" -d .
rm "$ZIPFILE"

echo "==== Verificando dist/ ===="
if [ -d "dist" ]; then
    echo "✓ Build extraido com sucesso!"
    ls -la dist/ | head -10
else
    echo "✗ ERRO: dist/ nao foi criada!"
    exit 1
fi

echo "==== Reiniciando Passenger ===="
mkdir -p tmp
touch tmp/restart.txt

echo "==== Concluido! ===="
```

**Para usar:**

1. Faça upload do `dist-virtuous-harmony-hub.zip` via File Manager
2. No Terminal:

```bash
chmod +x upload-dist.sh
./upload-dist.sh
```

---

## 📝 Notas Importantes

- ✅ A pasta `dist/` **não** está no `.gitignore` para este método (mas pode ser adicionada depois)
- ✅ O build é feito **localmente** onde há memória suficiente
- ✅ Apenas os arquivos compilados são enviados ao servidor
- ✅ O `server.js` serve os arquivos estáticos de `dist/`
- ✅ O Passenger reinicia automaticamente quando `tmp/restart.txt` é atualizado

---

## 🐛 Troubleshooting

### Erro: "dist/ não encontrada"

Verifique se o ZIP foi extraído corretamente:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
ls -la dist/
```

### Erro: "Cannot find module"

Verifique se as dependências do Node.js estão instaladas:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm ci --production
```

### Site não atualiza

Reinicie o Passenger:

```bash
touch tmp/restart.txt
```

Ou no cPanel: **Setup Node.js App** → **RESTART**

---

## 💡 Alternativa: Aumentar Limites LVE

Se preferir fazer build no servidor, entre em contato com o suporte da Dominios.pt para aumentar os limites LVE (memória e CPU).

Veja o arquivo `EMAIL_SUPORTE.txt` para um modelo de email.


