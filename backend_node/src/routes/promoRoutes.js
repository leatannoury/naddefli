const express = require('express');
const router = express.Router();
const promoController = require('../controllers/promoController');
const { authMiddleware } = require('../middleware/auth');

/**
 * Promo Code Routes
 */

router.get('/hot-offers', promoController.getHotOffers);
router.post('/validate', authMiddleware, promoController.validatePromoCode);

module.exports = router;
