const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * Address Model
 * Represents a saved address for quick checkout reuse
 */
const Address = sequelize.define('Address', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Customer ID',
  },
  label: {
    type: DataTypes.STRING(50),
    allowNull: false,
    comment: 'e.g. Home, Work, Other',
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  city: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  building: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  floor: {
    type: DataTypes.STRING(50),
    allowNull: true,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'addresses',
  timestamps: false,
});

module.exports = Address;
