const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * Service Model
 * Available cleaning services
 */
const Service = sequelize.define('Service', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: 'Service name (Kitchen Cleaning, etc)',
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  base_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    comment: 'Base price for the service',
  },
  duration_hours: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: false,
    comment: 'Estimated duration in hours',
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: 'Image URL or file path',
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'services',
  timestamps: false,
});

module.exports = Service;
