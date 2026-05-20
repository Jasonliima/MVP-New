const { Sequelize, DataTypes } = require('sequelize');
require('dotenv').config();

// Inicializa a conexão com o banco buscando as variáveis de ambiente ou valores padrão
const sequelize = new Sequelize(
  process.env.DB_NAME || 'mvp_db',
  process.env.DB_USER || 'root',
  process.env.DB_PASS || '',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'mysql',
    logging: false, // Oculta os logs excessivos do Sequelize no terminal
  }
);

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Importa os Modelos
db.User = require('./User')(sequelize, DataTypes);

module.exports = db;