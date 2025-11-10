// server.js - Express server para Passenger/cPanel
import path from 'path';
import express from 'express';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Servir arquivos estáticos da build do Vite
const distPath = path.join(__dirname, 'dist');

app.use(express.static(distPath, {
  maxAge: '1h',
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('index.html')) {
      res.setHeader('Cache-Control', 'no-cache');
    }
  }
}));

// Health-check para o Node.js Selector/Passenger
app.get('/__health', (req, res) => {
  res.type('text/plain').status(200).send('ok');
});

// SPA fallback: tudo o resto vai para index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(distPath, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
});

