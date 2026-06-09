/**
 * NADDEFLI — reviewController.js
 * Layer: Backend — Controller
 * Purpose: Create review after completed booking; list cleaner reviews.
 * Connects to: Review model
 */

const { Review, Booking, Cleaner } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');

/**
 * Review Controller
 * Handles review operations
 */

/**
 * Create a review
 */
exports.createReview = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { booking_id, rating, comment } = req.body;

    // Validate input
    if (!booking_id || !rating) {
      return sendError(res, 'Booking ID and rating are required', 400);
    }

    // Validate rating
    if (rating < 1 || rating > 5) {
      return sendError(res, 'Rating must be between 1 and 5', 400);
    }

    // Check if booking exists and is completed
    const booking = await Booking.findByPk(booking_id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    if (booking.status !== 'completed') {
      await t.rollback();
      return sendError(res, 'Only completed bookings can be reviewed', 400);
    }

    // Check if user is the customer
    if (booking.user_id !== req.user.id) {
      await t.rollback();
      return sendError(res, 'Unauthorized', 403);
    }

    // Check if review already exists
    const existingReview = await Review.findOne({
      where: { booking_id },
      transaction: t,
    });

    if (existingReview) {
      await t.rollback();
      return sendError(res, 'Review already exists for this booking', 400);
    }

    // Create review
    const review = await Review.create(
      {
        booking_id,
        user_id: booking.user_id,
        cleaner_id: booking.cleaner_id,
        rating,
        comment,
      },
      { transaction: t }
    );

    // Update cleaner rating
    const reviews = await Review.findAll({
      where: { cleaner_id: booking.cleaner_id },
      attributes: [
        [sequelize.fn('AVG', sequelize.col('rating')), 'averageRating'],
      ],
      transaction: t,
    });

    const averageRating = reviews[0]?.dataValues?.averageRating || 5;

    await Cleaner.update(
      { rating: averageRating },
      {
        where: { id: booking.cleaner_id },
        transaction: t,
      }
    );

    await t.commit();

    sendSuccess(res, review, 'Review created successfully', 201);
  } catch (error) {
    await t.rollback();
    console.error('Create review error:', error);
    sendError(res, 'Failed to create review', 500, error);
  }
};

/**
 * Get reviews for a cleaner
 */
exports.getCleanerReviews = async (req, res) => {
  try {
    const { cleanerId } = req.params;

    const reviews = await Review.findAll({
      where: { cleaner_id: cleanerId },
      include: [
        {
          model: User,
          as: 'reviewer',
          attributes: { exclude: ['password'] },
        },
      ],
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, reviews);
  } catch (error) {
    console.error('Get reviews error:', error);
    sendError(res, 'Failed to fetch reviews', 500, error);
  }
};
