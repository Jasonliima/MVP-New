const express = require('express');
const router = express.Router();
const { sequelize } = require('../models');

const authRoutes = require('./auth');
const chatRoutes = require('./chat');

// Mapeia os caminhos para os seus respectivos arquivos
router.use('/auth', authRoutes);
router.use('/chat', chatRoutes);

// Rota para testar a conexão com o banco de dados
router.get('/db-status', async (req, res) => {
  try {
    await sequelize.authenticate();
    res.json({ status: 'Conectado', message: 'Conexão com o banco de dados (MySQL) bem-sucedida!' });
  } catch (error) {
    res.status(500).json({ status: 'Erro', message: 'Falha ao conectar no banco de dados', details: error.message });
  }
});

module.exports = router;