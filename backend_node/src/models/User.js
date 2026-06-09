/**
 * NADDEFLI — User.js
 * Layer: Backend — Model (DB Table: users)
 * Purpose: User schema: name, email, bcrypt password, role, loyalty fields, is_blocked.
 * Connects to: Central to auth and bookings
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * User Model
 * Represents customers, cleaners, and admins
 */
const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  full_name: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: 'Full name of the user',
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true,
    comment: 'Email address - unique identifier',
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: 'Hashed password',
  },
  role: {
    type: DataTypes.ENUM('customer', 'cleaner', 'admin'),
    defaultValue: 'customer',
    comment: 'User role - customer, cleaner, or admin',
  },
  loyalty_progress: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false,
  },
  loyalty_rewards_available: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false,
  },
  completed_bookings_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false,
  },
  is_blocked: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    allowNull: false,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'users',
  timestamps: false,
});

module.exports = User;
