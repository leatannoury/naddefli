const { Booking, Service, User, Cleaner, Notification, Review, Address } = require('../models');
const { calculatePrice } = require('../utils/helpers');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');

/**
 * Helper to auto-complete past bookings and award loyalty points
 */
const autoCompletePastBookings = async (userId) => {
  const now = new Date();
  
  // Find all bookings for this user that are not completed/cancelled and whose date has passed
  const bookings = await Booking.findAll({
    where: {
      user_id: userId,
      status: ['pending', 'accepted', 'on_the_way', 'started'],
    },
  });

  for (const booking of bookings) {
    try {
      const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`);
      
      // Calculate end time
      const duration = parseFloat(booking.duration_hours) || 1.0;
      const endDateTime = new Date(bookingDateTime.getTime() + duration * 60 * 60 * 1000);

      if (endDateTime < now) {
        // Complete this booking!
        await sequelize.transaction(async (t) => {
          booking.status = 'completed';
          await booking.save({ transaction: t });

          // Award loyalty points & increment completed bookings count
          const user = await User.findByPk(userId, { transaction: t });
          if (user) {
            user.completed_bookings_count = (user.completed_bookings_count || 0) + 1;
            user.loyalty_points = (user.loyalty_points || 0) + 1;
            await user.save({ transaction: t });
          }

          // Create notification
          await Notification.create({
            user_id: userId,
            title: 'Booking Completed',
            body: `Your booking for ${booking.address} has been completed! You earned 1 loyalty point.`,
          }, { transaction: t });
        });
      }
    } catch (e) {
      console.error('Failed to auto-complete booking:', booking.id, e);
    }
  }
};

/**
 * Create a new booking
 */
exports.createBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { 
      service_id, booking_date, booking_time, start_time, end_time, duration_hours,
      address, city, notes, is_custom, property_type, room_count, bathrooms_count,
      kitchens_count, cleaning_type, extras, discount_amount, promo_code,
      redeem_loyalty, save_address, address_label
    } = req.body;

    // Validate input
    if (!service_id || !booking_date || !start_time || !end_time || !address || !city) {
      await t.rollback();
      return sendError(res, 'Missing required fields', 400);
    }

    // Check if service exists
    const service = await Service.findByPk(service_id, { transaction: t });
    if (!service) {
      await t.rollback();
      return sendError(res, 'Service not found', 404);
    }

    // Check if booking date is in the future
    const bookingDateTime = new Date(`${booking_date}T${start_time}`);
    const now = new Date();
    if (Number.isNaN(bookingDateTime.getTime()) || bookingDateTime <= now) {
      await t.rollback();
      return sendError(res, 'Please choose a future date and time', 400);
    }

    const isUrgent = (bookingDateTime - now) / (1000 * 60 * 60) < 24;

    // Loyalty Check
    const user = await User.findByPk(req.user.id, { transaction: t });
    if (redeem_loyalty) {
      if (!user || user.loyalty_points < 5) {
        await t.rollback();
        return sendError(res, 'Insufficient loyalty points to redeem a free clean', 400);
      }
      // Deduct 5 loyalty points
      user.loyalty_points = Math.max(0, user.loyalty_points - 5);
      await user.save({ transaction: t });
    }

    // Save newly entered address to customer saved addresses if flagged
    if (save_address) {
      const existingAddress = await Address.findOne({
        where: { user_id: req.user.id, address, city },
        transaction: t
      });
      if (!existingAddress) {
        await Address.create({
          user_id: req.user.id,
          label: address_label || 'Home',
          address,
          city,
        }, { transaction: t });
      }
    }

    // Calculate price
    const totalPrice = calculatePrice({
      duration_hours: duration_hours || 1,
      cleaning_type: cleaning_type || 'normal',
      extras,
      is_custom: is_custom || false,
      room_count: room_count || 0,
      bathrooms_count: bathrooms_count || 0,
      kitchens_count: kitchens_count || 0,
      isUrgent,
      discount_amount: discount_amount || 0.0,
      redeem_loyalty: redeem_loyalty || false,
    });

    // Create booking
    const booking = await Booking.create(
      {
        user_id: req.user.id,
        service_id,
        booking_date,
        booking_time: start_time,
        start_time,
        end_time,
        duration_hours: duration_hours || 1.0,
        address,
        city,
        notes,
        total_price: totalPrice,
        discount_amount: discount_amount || 0.0,
        promo_code: promo_code || null,
        status: 'pending',
        is_custom: is_custom || false,
        property_type: property_type || 'House/Apartment',
        room_count: room_count || 0,
        bathrooms_count: bathrooms_count || 0,
        kitchens_count: kitchens_count || 0,
        cleaning_type: cleaning_type || 'normal',
        extras: typeof extras === 'object' ? JSON.stringify(extras) : extras,
      },
      { transaction: t }
    );

    await Notification.create({
      user_id: req.user.id,
      title: 'Booking Pending',
      body: `Your cleaning on ${booking_date} at ${start_time} is pending approval.`,
      is_read: false,
    }, { transaction: t });

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
    // Run schema auto-completion first
    await autoCompletePastBookings(req.user.id);

    const bookings = await Booking.findAll({
      where: { user_id: req.user.id },
      include: [
        {
          model: Service,
          as: 'service',
        },
        {
          model: Cleaner,
          as: 'cleaner',
          include: [
            {
              model: User,
              as: 'user',
              attributes: { exclude: ['password'] },
            },
          ],
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
          model: Cleaner,
          as: 'cleaner',
          include: [
            {
              model: User,
              as: 'user',
              attributes: { exclude: ['password'] },
            },
          ],
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

/**
 * Mark booking as completed
 */
exports.completeBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;

    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    // Only administrators may mark bookings as completed
    if (req.user.role !== 'admin') {
      await t.rollback();
      return sendError(res, 'Unauthorized - admin only', 403);
    }

    if (booking.status === 'completed') {
      await t.rollback();
      return sendError(res, 'Booking already completed', 400);
    }

    booking.status = 'completed';
    await booking.save({ transaction: t });

    // Award loyalty points & completed count
    const customer = await User.findByPk(booking.user_id, { transaction: t });
    if (customer) {
      customer.completed_bookings_count = (customer.completed_bookings_count || 0) + 1;
      customer.loyalty_points = (customer.loyalty_points || 0) + 1;
      await customer.save({ transaction: t });
    }

    // Create notification
    await Notification.create({
      user_id: booking.user_id,
      title: 'Booking Completed',
      body: `Your booking at ${booking.address} has been completed! You earned 1 loyalty point.`,
    }, { transaction: t });

    await t.commit();

    sendSuccess(res, booking, 'Booking completed successfully');
  } catch (error) {
    await t.rollback();
    console.error('Complete booking error:', error);
    sendError(res, 'Failed to complete booking', 500, error);
  }
};
