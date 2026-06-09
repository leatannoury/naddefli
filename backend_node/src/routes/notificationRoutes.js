/**
 * NADDEFLI — notificationRoutes.js
 * Layer: Backend — Routes
 * Purpose: User notification list and mark-read.
 * Connects to: notificationController.js
 */

const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { authMiddleware } = require('../middleware/auth');

/**
 * Notification Routes
 */

router.get(
  '/unread-count',
  authMiddleware,
  notificationController.getUnreadCount
);

router.get(
  '/',
  authMiddleware,
  notificationController.getNotifications
);

router.put(
  '/:id/read',
  authMiddleware,
  notificationController.markAsRead
);

router.put(
  '/read-all',
  authMiddleware,
  notificationController.markAllAsRead
);

module.exports = router;
