/**
 * NADDEFLI — db.js
 * Layer: Backend — Config
 * Purpose: Creates Sequelize instance connected to SQLite database file.
 * Connects to: database.sqlite
 */

const { Sequelize } = require('sequelize');
const config = require('./database');

// Initialize Sequelize
const sequelize = config.development.dialect === 'sqlite'
  ? new Sequelize({
      dialect: 'sqlite',
      storage: config.development.storage,
      logging: config.development.logging,
    })
  : new Sequelize(
      config.development.database,
      config.development.username,
      config.development.password,
      {
        host: config.development.host,
        port: config.development.port,
        dialect: config.development.dialect,
        logging: config.development.logging,
        dialectOptions: config.development.dialectOptions,
      }
    );

module.exports = sequelize;
