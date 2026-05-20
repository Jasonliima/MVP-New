require('dotenv').config();

module.exports = {
  development: {
    username: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'mvp_db',
    host: process.env.DB_HOST || 'localhost',
    dialect: 'mysql',
    logging: false
  }
  // Aqui você pode adicionar configurações de "production" no futuro
};