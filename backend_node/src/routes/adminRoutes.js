const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const notificationController = require('../controllers/notificationController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');
const upload = require('../middleware/upload');

const adminAuth = [authMiddleware, authorizationMiddleware(['admin'])];

/**
 * Administrative Routes
 */

// Public administrative routes
router.post('/login', adminController.adminLogin);

// Protected administrative routes (Requires admin JWT token)
router.get('/dashboard', adminAuth, adminController.getDashboard);

// Booking operations
router.get('/bookings', adminAuth, adminController.getAllBookings);
router.get('/bookings/:id', adminAuth, adminController.getBookingById);
router.put('/bookings/:id/accept', adminAuth, adminController.acceptBooking);
router.put('/bookings/:id/cancel', adminAuth, adminController.cancelBooking);
router.put('/bookings/:id/complete', adminAuth, adminController.completeBooking);

// Customer operations
router.get('/customers', adminAuth, adminController.getAllUsers);
router.get('/customers/:id', adminAuth, adminController.getCustomerById);
router.post('/customers', adminAuth, adminController.createCustomer);
router.put('/customers/:id', adminAuth, adminController.updateCustomer);
router.put('/customers/:id/block', adminAuth, adminController.blockCustomer);
router.delete('/customers/:id', adminAuth, adminController.deleteCustomer);

// Cleaners list
router.get('/cleaners', adminAuth, adminController.getAllCleaners);

// Services CRUD
router.get('/services', adminAuth, adminController.getAllServices);
router.post('/services/upload', adminAuth, upload.single('image'), adminController.uploadServiceImage);
router.post('/services', adminAuth, adminController.createService);
router.put('/services/:id', adminAuth, adminController.updateService);
router.delete('/services/:id', adminAuth, adminController.deleteService);

// Promos CRUD
router.get('/promos', adminAuth, adminController.getAllPromos);
router.post('/promos', adminAuth, adminController.createPromo);
router.put('/promos/:id', adminAuth, adminController.updatePromo);
router.delete('/promos/:id', adminAuth, adminController.deletePromo);

// Notification operations
router.get('/notifications/unread', adminAuth, adminController.getNotificationUnread);
router.get('/notifications', adminAuth, notificationController.getNotifications);
router.put('/notifications/:id/read', adminAuth, notificationController.markAsRead);
router.put('/notifications/read-all', adminAuth, notificationController.markAllAsRead);

// Config Settings
router.get('/settings', adminAuth, adminController.getSettings);
router.put('/settings', adminAuth, adminController.updateSettings);

module.exports = router;
