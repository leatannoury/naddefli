const { User, Booking, Cleaner, Review } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');

/**
 * Admin Controller
 * Handles admin operations
 */

/**
 * Get dashboard statistics
 */
exports.getDashboard = async (req, res) => {
  try {
    // Total users
    const totalUsers = await User.count({
      where: { role: 'customer' },
    });

    // Total cleaners
    const totalCleaners = await User.count({
      where: { role: 'cleaner' },
    });

    // Total bookings
    const totalBookings = await Booking.count();

    // Completed bookings
    const completedBookings = await Booking.count({
      where: { status: 'completed' },
    });

    // Total revenue
    const totalRevenue = await Booking.findAll({
      where: { status: 'completed' },
      attributes: [
        [sequelize.fn('SUM', sequelize.col('total_price')), 'total'],
      ],
      raw: true,
    });

    const revenue = parseFloat(totalRevenue[0]?.total || 0);

    // Pending bookings
    const pendingBookings = await Booking.count({
      where: { status: 'pending' },
    });

    sendSuccess(res, {
      totalUsers,
      totalCleaners,
      totalBookings,
      completedBookings,
      totalRevenue: revenue.toFixed(2),
      pendingBookings,
    });
  } catch (error) {
    console.error('Get dashboard error:', error);
    sendError(res, 'Failed to fetch dashboard', 500, error);
  }
};

/**
 * Get all users
 */
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      where: { role: 'customer' },
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, users);
  } catch (error) {
    console.error('Get users error:', error);
    sendError(res, 'Failed to fetch users', 500, error);
  }
};

/**
 * Get all cleaners
 */
exports.getAllCleaners = async (req, res) => {
  try {
    const cleaners = await User.findAll({
      where: { role: 'cleaner' },
      include: [
        {
          model: Cleaner,
          as: 'cleanerProfile',
        },
      ],
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, cleaners);
  } catch (error) {
    console.error('Get cleaners error:', error);
    sendError(res, 'Failed to fetch cleaners', 500, error);
  }
};

/**
 * Get all bookings
 */
exports.getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      include: [
        {
          model: User,
          as: 'customer',
          attributes: { exclude: ['password'] },
        },
        {
          model: User,
          as: 'cleaner',
          attributes: { exclude: ['password'] },
        },
      ],
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, bookings);
  } catch (error) {
    console.error('Get bookings error:', error);
    sendError(res, 'Failed to fetch bookings', 500, error);
  }
};
