/**
 * NADDEFLI — Notification.js
 * Layer: Backend — Model (DB Table: notifications)
 * Purpose: In-app notifications per user.
 * Connects to: Created on booking events
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * Notification Model
 * Notifications for users
 */
const Notification = sequelize.define('Notification', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Recipient user ID',
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  body: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  is_read: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'notifications',
  timestamps: false,
});

module.exports = Notification;
