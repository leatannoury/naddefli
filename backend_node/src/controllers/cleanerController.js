const { Booking, Cleaner, Review, User, Notification } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');
const { awardCleaningMilestone } = require('../utils/loyalty');

/**
 * Cleaner Controller
 * Handles cleaner-specific operations
 */

/**
 * Get cleaner's assigned jobs
 */
exports.getCleanerJobs = async (req, res) => {
  try {
    // Get cleaner profile
    const cleaner = await Cleaner.findOne({
      where: { user_id: req.user.id },
    });

    if (!cleaner) {
      return sendError(res, 'Cleaner profile not found', 404);
    }

    // Get assigned bookings
    const jobs = await Booking.findAll({
      where: { cleaner_id: cleaner.id },
      include: [
        {
          model: User,
          as: 'customer',
          attributes: { exclude: ['password'] },
        },
      ],
      order: [['booking_date', 'ASC']],
    });

    sendSuccess(res, jobs);
  } catch (error) {
    console.error('Get cleaner jobs error:', error);
    sendError(res, 'Failed to fetch jobs', 500, error);
  }
};

/**
 * Accept booking (assign to cleaner)
 */
exports.acceptBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;

    // Get cleaner profile
    const cleaner = await Cleaner.findOne(
      { where: { user_id: req.user.id } },
      { transaction: t }
    );

    if (!cleaner) {
      await t.rollback();
      return sendError(res, 'Cleaner profile not found', 404);
    }

    // Get booking
    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    // Check if booking is pending
    if (booking.status !== 'pending') {
      await t.rollback();
      return sendError(res, 'Booking is not available', 400);
    }

    // Check if cleaner is available
    if (!cleaner.is_available) {
      await t.rollback();
      return sendError(res, 'You are not available to accept bookings', 400);
    }

    // Assign booking to cleaner
    booking.cleaner_id = cleaner.id;
    booking.status = 'accepted';
    await booking.save({ transaction: t });

    // Create notification for customer
    await Notification.create(
      {
        user_id: booking.user_id,
        title: 'Booking Accepted',
        body: `A cleaner has accepted your booking for ${booking.address}`,
      },
      { transaction: t }
    );

    await t.commit();

    sendSuccess(res, booking, 'Booking accepted successfully');
  } catch (error) {
    await t.rollback();
    console.error('Accept booking error:', error);
    sendError(res, 'Failed to accept booking', 500, error);
  }
};

/**
 * Update booking status
 */
exports.updateBookingStatus = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Validate status
    const validStatuses = ['on_the_way', 'started', 'completed'];
    if (!validStatuses.includes(status)) {
      return sendError(res, 'Invalid status', 400);
    }

    // Get cleaner profile
    const cleaner = await Cleaner.findOne(
      { where: { user_id: req.user.id } },
      { transaction: t }
    );

    if (!cleaner) {
      await t.rollback();
      return sendError(res, 'Cleaner profile not found', 404);
    }

    // Get booking
    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    // Check if cleaner is assigned to booking
    if (booking.cleaner_id !== cleaner.id) {
      await t.rollback();
      return sendError(res, 'You are not assigned to this booking', 403);
    }

    const wasCompleted = booking.status === 'completed';
    booking.status = status;
    await booking.save({ transaction: t });
    let rewardEarned = false;
    if (status === 'completed' && !wasCompleted) {
      ({ rewardEarned } = await awardCleaningMilestone(booking.user_id, booking, t));
    }

    // Create notification for customer
    const statusMessages = {
      on_the_way: 'Cleaner is on the way',
      started: 'Cleaning service has started',
      completed: 'Cleaning service is completed',
    };

    await Notification.create(
      {
        user_id: booking.user_id,
        title: 'Booking Status Updated',
        body: rewardEarned
          ? `${statusMessages[status]} for your booking at ${booking.address}. You unlocked a free normal cleaning reward!`
          : `${statusMessages[status]} for your booking at ${booking.address}`,
      },
      { transaction: t }
    );

    await t.commit();

    sendSuccess(res, booking, `Booking status updated to ${status}`);
  } catch (error) {
    await t.rollback();
    console.error('Update booking status error:', error);
    sendError(res, 'Failed to update booking status', 500, error);
  }
};

/**
 * Get cleaner earnings
 */
exports.getEarnings = async (req, res) => {
  try {
    // Get cleaner profile
    const cleaner = await Cleaner.findOne({
      where: { user_id: req.user.id },
    });

    if (!cleaner) {
      return sendError(res, 'Cleaner profile not found', 404);
    }

    // Get completed bookings
    const completedBookings = await Booking.findAll({
      where: {
        cleaner_id: cleaner.id,
        status: 'completed',
      },
      attributes: [
        [sequelize.fn('SUM', sequelize.col('total_price')), 'totalEarnings'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'completedJobs'],
      ],
      raw: true,
    });

    const totalEarnings = completedBookings[0]?.totalEarnings || 0;
    const completedJobs = completedBookings[0]?.completedJobs || 0;

    sendSuccess(res, {
      totalEarnings: parseFloat(totalEarnings),
      completedJobs,
      averageEarningsPerJob: completedJobs > 0 ? (parseFloat(totalEarnings) / completedJobs).toFixed(2) : 0,
    });
  } catch (error) {
    console.error('Get earnings error:', error);
    sendError(res, 'Failed to fetch earnings', 500, error);
  }
};

/**
 * Update cleaner availability
 */
exports.updateAvailability = async (req, res) => {
  try {
    const { is_available } = req.body;

    // Get cleaner profile
    const cleaner = await Cleaner.findOne({
      where: { user_id: req.user.id },
    });

    if (!cleaner) {
      return sendError(res, 'Cleaner profile not found', 404);
    }

    cleaner.is_available = is_available;
    await cleaner.save();

    sendSuccess(res, cleaner, 'Availability updated successfully');
  } catch (error) {
    console.error('Update availability error:', error);
    sendError(res, 'Failed to update availability', 500, error);
  }
};
