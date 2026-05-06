const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * Review Model
 * Customer ratings and reviews for completed services
 */
const Review = sequelize.define('Review', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  booking_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Reference to booking',
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Customer ID',
  },
  cleaner_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Cleaner ID',
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5,
    },
    comment: 'Rating from 1-5',
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'reviews',
  timestamps: false,
});

module.exports = Review;
