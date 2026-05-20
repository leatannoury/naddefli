const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

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
router.post('/services', adminAuth, adminController.createService);
router.put('/services/:id', adminAuth, adminController.updateService);
router.delete('/services/:id', adminAuth, adminController.deleteService);

// Promos CRUD
router.get('/promos', adminAuth, adminController.getAllPromos);
exports.router = router; // Note: CommonJS usually does module.exports
router.post('/promos', adminAuth, adminController.createPromo);
router.put('/promos/:id', adminAuth, adminController.updatePromo);
router.delete('/promos/:id', adminAuth, adminController.deletePromo);

// Config Settings
router.get('/settings', adminAuth, adminController.getSettings);
router.put('/settings', adminAuth, adminController.updateSettings);

module.exports = router;
