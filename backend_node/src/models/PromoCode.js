const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * PromoCode Model
 * Represents dynamic discount codes
 */
const PromoCode = sequelize.define('PromoCode', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  code: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  type: {
    type: DataTypes.STRING(50),
    allowNull: false,
    comment: 'e.g. percentage, free_addon',
  },
  value: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  conditions: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'JSON string of conditions (e.g. cleaning_type requirement)',
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
  },
}, {
  tableName: 'promo_codes',
  timestamps: false,
});

module.exports = PromoCode;
