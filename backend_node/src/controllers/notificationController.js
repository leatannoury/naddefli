/**
 * NADDEFLI — notificationController.js
 * Layer: Backend — Controller
 * Purpose: List notifications, unread count, mark read.
 * Connects to: Notification model
 */

const { Notification } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * Notification Controller
 * Handles notification operations
 */

/**
 * Get user notifications
 */
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: { user_id: req.user.id },
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, notifications);
  } catch (error) {
    console.error('Get notifications error:', error);
    sendError(res, 'Failed to fetch notifications', 500, error);
  }
};

/**
 * Mark notification as read
 */
exports.markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findByPk(id);
    if (!notification) {
      return sendError(res, 'Notification not found', 404);
    }

    // Check if user owns notification
    if (notification.user_id !== req.user.id) {
      return sendError(res, 'Unauthorized', 403);
    }

    notification.is_read = true;
    await notification.save();

    sendSuccess(res, notification);
  } catch (error) {
    console.error('Mark as read error:', error);
    sendError(res, 'Failed to mark notification as read', 500, error);
  }
};

/**
 * Mark all notifications as read
 */
exports.getUnreadCount = async (req, res) => {
  try {
    const unreadCount = await Notification.count({
      where: { user_id: req.user.id, is_read: false },
    });
    sendSuccess(res, { unreadCount });
  } catch (error) {
    console.error('Get unread count error:', error);
    sendError(res, 'Failed to fetch unread count', 500, error);
  }
};

exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.update(
      { is_read: true },
      { where: { user_id: req.user.id } }
    );

    sendSuccess(res, {}, 'All notifications marked as read');
  } catch (error) {
    console.error('Mark all as read error:', error);
    sendError(res, 'Failed to mark notifications as read', 500, error);
  }
};
