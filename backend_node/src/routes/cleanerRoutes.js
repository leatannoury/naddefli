const express = require('express');
const router = express.Router();
const cleanerController = require('../controllers/cleanerController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

/**
 * Cleaner Routes
 */

router.get(
  '/jobs',
  authMiddleware,
  authorizationMiddleware(['cleaner']),
  cleanerController.getCleanerJobs
);

router.put(
  '/accept/:id',
  authMiddleware,
  authorizationMiddleware(['cleaner']),
  cleanerController.acceptBooking
);

router.put(
  '/status/:id',
  authMiddleware,
  authorizationMiddleware(['cleaner']),
  cleanerController.updateBookingStatus
);

router.get(
  '/earnings',
  authMiddleware,
  authorizationMiddleware(['cleaner']),
  cleanerController.getEarnings
);

router.put(
  '/availability',
  authMiddleware,
  authorizationMiddleware(['cleaner']),
  cleanerController.updateAvailability
);

module.exports = router;
