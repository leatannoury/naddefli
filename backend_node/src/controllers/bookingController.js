const { Booking, Service, User, Notification, Review } = require('../models');
const { calculatePrice } = require('../utils/helpers');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');

/**
 * Booking Controller
 * Handles booking operations
 */

/**
 * Create a new booking
 */
exports.createBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { service_id, booking_date, booking_time, address, city, notes } = req.body;

    // Validate input
    if (!service_id || !booking_date || !booking_time || !address || !city) {
      return sendError(res, 'Missing required fields', 400);
    }

    // Check if service exists
    const service = await Service.findByPk(service_id, { transaction: t });
    if (!service) {
      await t.rollback();
      return sendError(res, 'Service not found', 404);
    }

    // Check if booking date is in the future
    const bookingDateTime = new Date(`${booking_date}T${booking_time}`);
    const now = new Date();

    const isUrgent = (bookingDateTime - now) / (1000 * 60 * 60) < 24;

    // Calculate price
    const totalPrice = calculatePrice(service.base_price, isUrgent);

    // Create booking
    const booking = await Booking.create(
      {
        user_id: req.user.id,
        service_id,
        booking_date,
        booking_time,
        address,
        city,
        notes,
        total_price: totalPrice,
        status: 'pending',
      },
      { transaction: t }
    );

    await t.commit();

    sendSuccess(
      res,
      {
        ...booking.toJSON(),
        isUrgent,
      },
      'Booking created successfully',
      201
    );
  } catch (error) {
    await t.rollback();
    console.error('Create booking error:', error);
    sendError(res, 'Failed to create booking', 500, error);
  }
};

/**
 * Get user's bookings
 */
exports.getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      where: { user_id: req.user.id },
      include: [
        {
          model: Service,
          as: 'service',
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

/**
 * Get booking by ID
 */
exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params;

    const booking = await Booking.findByPk(id, {
      include: [
        {
          model: Service,
          as: 'service',
        },
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
        {
          model: Review,
          as: 'review',
        },
      ],
    });

    if (!booking) {
      return sendError(res, 'Booking not found', 404);
    }

    // Check if user has access
    if (booking.user_id !== req.user.id && req.user.role !== 'admin' && booking.cleaner_id !== req.user.id) {
      return sendError(res, 'Unauthorized', 403);
    }

    sendSuccess(res, booking);
  } catch (error) {
    console.error('Get booking error:', error);
    sendError(res, 'Failed to fetch booking', 500, error);
  }
};

/**
 * Cancel booking
 */
exports.cancelBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;

    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    // Check if user owns the booking
    if (booking.user_id !== req.user.id) {
      await t.rollback();
      return sendError(res, 'Unauthorized', 403);
    }

    // Check if booking can be cancelled
    if (['completed', 'cancelled', 'started', 'on_the_way'].includes(booking.status)) {
      await t.rollback();
      return sendError(res, 'This booking cannot be cancelled', 400);
    }

    // Update booking status
    booking.status = 'cancelled';
    await booking.save({ transaction: t });

    // Create notification for cleaner if assigned
    if (booking.cleaner_id) {
      await Notification.create(
        {
          user_id: booking.cleaner_id,
          title: 'Booking Cancelled',
          body: `The booking for ${booking.address} has been cancelled by the customer.`,
        },
        { transaction: t }
      );
    }

    await t.commit();

    sendSuccess(res, booking, 'Booking cancelled successfully');
  } catch (error) {
    await t.rollback();
    console.error('Cancel booking error:', error);
    sendError(res, 'Failed to cancel booking', 500, error);
  }
};
