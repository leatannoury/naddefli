const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

/**
 * Admin Routes
 */

router.get(
  '/dashboard',
  authMiddleware,
  authorizationMiddleware(['admin']),
  adminController.getDashboard
);

router.get(
  '/users',
  authMiddleware,
  authorizationMiddleware(['admin']),
  adminController.getAllUsers
);

router.get(
  '/cleaners',
  authMiddleware,
  authorizationMiddleware(['admin']),
  adminController.getAllCleaners
);

router.get(
  '/bookings',
  authMiddleware,
  authorizationMiddleware(['admin']),
  adminController.getAllBookings
);

module.exports = router;
