const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

/**
 * Review Routes
 */

router.post(
  '/create',
  authMiddleware,
  authorizationMiddleware(['customer']),
  reviewController.createReview
);

router.get(
  '/cleaner/:cleanerId',
  reviewController.getCleanerReviews
);

module.exports = router;
