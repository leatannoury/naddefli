const { Sequelize } = require('sequelize');
require('dotenv').config();

console.log('Testing SQL Server connection...');
console.log('Host:', process.env.DB_HOST);
console.log('Port:', process.env.DB_PORT);
console.log('Database:', process.env.DB_DATABASE);
console.log('User:', process.env.DB_USER || '(Windows Auth)');
console.log('Trusted:', process.env.DB_TRUSTED);

const sequelize = new Sequelize(
  process.env.DB_DATABASE,
  process.env.DB_USER || undefined,
  process.env.DB_PASSWORD || undefined,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mssql',
    dialectOptions: {
      options: {
        encrypt: false,
        trustServerCertificate: true,
        trustedConnection: process.env.DB_TRUSTED === 'true',
        connectTimeout: 30000,
        requestTimeout: 30000,
      },
    },
    logging: console.log,
  }
);

sequelize
  .authenticate()
  .then(() => {
    console.log('\n✅ Connection successful!');
    process.exit(0);
  })
  .catch(err => {
    console.error('\n❌ Connection failed:', err.message);
    process.exit(1);
  });
