const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

/**
 * Booking Model
 * Customer bookings for cleaning services
 */
const Booking = sequelize.define('Booking', {
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
  cleaner_id: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: 'Assigned cleaner ID',
  },
  service_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'Service ID',
  },
  booking_date: {
    type: DataTypes.DATE,
    allowNull: false,
    comment: 'Date of booking',
  },
  booking_time: {
    type: DataTypes.STRING(5),
    allowNull: false,
    comment: 'Time in HH:MM format',
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  city: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Additional notes from customer',
  },
  total_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    comment: 'Final price including any surcharges',
  },
  status: {
    type: DataTypes.ENUM('pending', 'accepted', 'on_the_way', 'started', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  is_custom: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  property_type: {
    type: DataTypes.STRING(50),
    allowNull: true,
  },
  room_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  bathrooms_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  kitchens_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  cleaning_type: {
    type: DataTypes.STRING(50),
    defaultValue: 'normal',
  },
  extras: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'JSON string of extra options',
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'bookings',
  timestamps: false,
});

module.exports = Booking;
