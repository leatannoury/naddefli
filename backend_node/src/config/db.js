const { Sequelize } = require('sequelize');
const config = require('./database');

// Initialize Sequelize
const sequelize = new Sequelize(
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
