const express = require('express');
const router = express.Router();
const addonController = require('../controllers/addonController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

// Public: list active add-ons
router.get('/', addonController.getPublicAddOns);

// Admin CRUD
const adminAuth = [authMiddleware, authorizationMiddleware(['admin'])];
router.get('/admin', adminAuth, addonController.getAllAddOns);
router.post('/admin', adminAuth, addonController.createAddOn);
router.put('/admin/:id', adminAuth, addonController.updateAddOn);
router.delete('/admin/:id', adminAuth, addonController.deleteAddOn);

module.exports = router;
