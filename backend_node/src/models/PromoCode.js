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
  description: {
    type: DataTypes.STRING(255),
    allowNull: true,
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
  is_hot_offer: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    allowNull: false,
    comment: 'Flag for Hot Offer promotions',
  },
}, {
  tableName: 'promo_codes',
  timestamps: false,
});

module.exports = PromoCode;
