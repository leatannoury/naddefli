/**
 * NADDEFLI — addressRoutes.js
 * Layer: Backend — Routes
 * Purpose: CRUD routes for /api/addresses.
 * Connects to: addressController.js
 */

const express = require('express');
const router = express.Router();
const addressController = require('../controllers/addressController');
const { authMiddleware } = require('../middleware/auth');

/**
 * Saved Address Routes
 */

router.get('/', authMiddleware, addressController.getAddresses);
router.post('/', authMiddleware, addressController.addAddress);
router.put('/:id', authMiddleware, addressController.updateAddress);
router.delete('/:id', authMiddleware, addressController.deleteAddress);

module.exports = router;
