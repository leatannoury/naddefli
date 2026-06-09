/**
 * NADDEFLI — Cleaner.js
 * Layer: Backend — Model (DB Table: cleaners)
 * Purpose: Cleaner profile linked to User (experience, rating, availability).
 * Connects to: Assigned to bookings
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * Cleaner Model
 * Profile information for cleaner users
 */
const Cleaner = sequelize.define('Cleaner', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Reference to User table',
  },
  experience_years: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Years of experience',
  },
  rating: {
    type: DataTypes.DECIMAL(3, 2),
    defaultValue: 5.0,
    comment: 'Average rating from 0-5',
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: 'Whether cleaner is available for bookings',
  },
  national_id: {
    type: DataTypes.STRING(50),
    allowNull: true,
    comment: 'National ID for verification',
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'cleaners',
  timestamps: false,
});

module.exports = Cleaner;
