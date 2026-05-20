const express = require('express');
require('dotenv').config();
const routes = require('./routes');
const db = require('./models');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date() });
});

// Routes
app.use('/api', routes);

// 404 handler específico para as rotas da API
app.use('/api/*', (req, res) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

// Hospeda os arquivos estáticos do Flutter Web
app.use(express.static(path.join(__dirname, 'flutter_app', 'build', 'web')));

// Redireciona acessos comuns no navegador para o aplicativo Flutter
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'flutter_app', 'build', 'web', 'index.html'));
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Erro interno do servidor' });
});

// Start server
// Nota: Manteremos o .sync() para o MVP, mas o ideal em produção é usar apenas as Migrations.
db.sequelize.sync().then(() => {
  console.log('✅ Banco de dados sincronizado.');
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor rodando em http://localhost:${PORT}`);
  });
}).catch(err => {
  console.error('❌ Erro ao sincronizar com banco de dados MySQL:', err);
});

module.exports = app;
