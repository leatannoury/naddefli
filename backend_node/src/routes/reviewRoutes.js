/**
 * NADDEFLI — reviewRoutes.js
 * Layer: Backend — Routes
 * Purpose: Create and list cleaner reviews.
 * Connects to: reviewController.js
 */

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
