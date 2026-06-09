/**
 * NADDEFLI — database.js
 * Layer: Backend — Config
 * Purpose: Alternate database configuration (documented for MSSQL; SQLite used in practice).
 * Connects to: Sequelize CLI migrations
 */

require('dotenv').config();

module.exports = {
  development: {
    dialect: 'sqlite',
    storage: './database.sqlite',
    logging: false,
  },
  production: {
    dialect: 'sqlite',
    storage: './database.sqlite',
    logging: false,
  },
};
