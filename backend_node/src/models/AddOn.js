const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * AddOn Model
 * Global add-on options managed by admin
 */
const AddOn = sequelize.define('AddOn', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0.0,
    allowNull: false,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  }
}, {
  tableName: 'add_ons',
  timestamps: false,
});

module.exports = AddOn;
