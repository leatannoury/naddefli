/**
 * NADDEFLI — CleaningTip.js
 * Layer: Backend — Model (DB Table: cleaning_tips)
 * Purpose: Daily tips shown on app home screen.
 * Connects to: Public API + admin CRUD
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * CleaningTip Model
 * Daily cleaning tips managed by admin, shown in the mobile app
 */
const CleaningTip = sequelize.define('CleaningTip', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING(120),
    allowNull: false,
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  image_url: {
    type: DataTypes.STRING(500),
    allowNull: true,
  },
  gradient_start: {
    type: DataTypes.STRING(20),
    defaultValue: '#0F766E',
    allowNull: false,
  },
  gradient_end: {
    type: DataTypes.STRING(20),
    defaultValue: '#14B8A6',
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
  },
}, {
  tableName: 'cleaning_tips',
  timestamps: false,
});

module.exports = CleaningTip;
