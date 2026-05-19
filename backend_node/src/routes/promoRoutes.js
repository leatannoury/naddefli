const express = require('express');
const router = express.Router();
const promoController = require('../controllers/promoController');
const { authMiddleware } = require('../middleware/auth');

/**
 * Promo Code Routes
 */

router.post('/validate', authMiddleware, promoController.validatePromoCode);

module.exports = router;
