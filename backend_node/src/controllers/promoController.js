/**
 * NADDEFLI — promoController.js
 * Layer: Backend — Controller
 * Purpose: Validate promo codes, apply discounts, list hot offers.
 * Connects to: PromoCode model
 */

const { PromoCode, Booking } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');
const { evaluatePromoConditions } = require('../utils/helpers');

/**
 * Promo Controller
 * Validates promo codes and checks rules
 */

exports.getHotOffers = async (req, res) => {
  try {
    const hotOffers = await PromoCode.findAll({
      where: { is_active: true, is_hot_offer: true }
    });
    sendSuccess(res, hotOffers);
  } catch (error) {
    console.error('Get hot offers error:', error);
    sendError(res, 'Failed to fetch hot offers', 500, error);
  }
};

exports.validatePromoCode = async (req, res) => {
  try {
    const { code, cleaning_type, extras, subtotal, booking_date } = req.body;

    if (!code) {
      return sendError(res, 'Promo code is required', 400);
    }

    const promo = await PromoCode.findOne({
      where: { code: code.toUpperCase().trim(), is_active: true },
    });

    if (!promo) {
      return sendError(res, 'Invalid or inactive promo code', 404);
    }

    // Check expiration
    if (promo.expires_at && new Date(promo.expires_at) < new Date()) {
      return sendError(res, 'Promo code has expired', 400);
    }

    const conditionCheck = await evaluatePromoConditions({
      conditions: promo.conditions,
      cleaning_type,
      subtotal,
      booking_date,
      userId: req.user.id,
      Booking,
    });

    if (!conditionCheck.ok) {
      return sendError(res, conditionCheck.message, 400);
    }

    let discountAmount = 0;
    const message = 'Promo code applied successfully!';

    // Calculate discount based on promo type and value
    if (promo.type === 'percentage') {
      discountAmount = (parseFloat(subtotal || 0) * (parseFloat(promo.value) / 100));
    } else {
      discountAmount = parseFloat(promo.value);
    }

    // Ensure discount does not exceed subtotal
    if (discountAmount > parseFloat(subtotal || 0)) {
      discountAmount = parseFloat(subtotal || 0);
    }

    sendSuccess(
      res,
      {
        code: promo.code,
        type: promo.type,
        value: promo.value,
        discount_amount: Math.round(discountAmount * 100) / 100,
        message,
      },
      'Promo code validated successfully'
    );
  } catch (error) {
    console.error('Validate promo code error:', error);
    sendError(res, 'Failed to validate promo code', 500, error);
  }
};
