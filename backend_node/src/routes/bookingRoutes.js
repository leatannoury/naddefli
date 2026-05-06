const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

/**
 * Booking Routes
 */

router.post(
  '/create',
  authMiddleware,
  authorizationMiddleware(['customer']),
  bookingController.createBooking
);

router.get(
  '/my-bookings',
  authMiddleware,
  bookingController.getMyBookings
);

router.get(
  '/:id',
  authMiddleware,
  bookingController.getBookingById
);

router.put(
  '/cancel/:id',
  authMiddleware,
  authorizationMiddleware(['customer']),
  bookingController.cancelBooking
);

module.exports = router;
