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
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Image URL or file path',
  },
  add_ons: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'JSON-encoded list of add-on options and prices',
    get() {
      const rawValue = this.getDataValue('add_ons');
      if (!rawValue) return [];
      try {
        const parsed = JSON.parse(rawValue);
        return Array.isArray(parsed) ? parsed : [];
      } catch (err) {
        return [];
      }
    },
    set(value) {
      if (Array.isArray(value)) {
        this.setDataValue('add_ons', JSON.stringify(value));
      } else if (typeof value === 'string') {
        this.setDataValue('add_ons', value);
      } else {
        this.setDataValue('add_ons', null);
      }
    }
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
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
