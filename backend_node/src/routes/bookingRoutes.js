/**
 * NADDEFLI — bookingRoutes.js
 * Layer: Backend — Routes
 * Purpose: POST create, GET my-bookings, PUT cancel — customer booking endpoints.
 * Connects to: bookingController.js + authMiddleware
 */

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

router.put(
  '/complete/:id',
  authMiddleware,
  bookingController.completeBooking
);

module.exports = router;
