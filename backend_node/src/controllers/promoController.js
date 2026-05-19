const { PromoCode, Booking } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * Promo Controller
 * Validates promo codes and checks rules
 */

exports.validatePromoCode = async (req, res) => {
  try {
    const { code, cleaning_type, extras, subtotal } = req.body;

    if (!code) {
      return sendError(res, 'Promo code is required', 400);
    }

    const promo = await PromoCode.findOne({
      where: { code: code.toUpperCase().trim() },
    });

    if (!promo) {
      return sendError(res, 'Invalid promo code', 404);
    }

    // Check expiration
    if (promo.expires_at && new Date(promo.expires_at) < new Date()) {
      return sendError(res, 'Promo code has expired', 400);
    }

    // Validate rules based on code
    const conditions = promo.conditions ? JSON.parse(promo.conditions) : {};
    let discountAmount = 0;
    let message = 'Promo code applied successfully!';

    if (promo.code === 'DEEP20') {
      if (cleaning_type !== 'deep') {
        return sendError(res, 'This promo code only works for Deep Cleaning services', 400);
      }
      discountAmount = (parseFloat(subtotal) || 0) * 0.20;
    } else if (promo.code === 'FIRST10') {
      // Check user completed bookings
      const completedCount = await Booking.count({
        where: { user_id: req.user.id, status: 'completed' },
      });
      if (completedCount > 0) {
        return sendError(res, 'This promo code only works on your first booking', 400);
      }
      discountAmount = (parseFloat(subtotal) || 0) * 0.10;
    } else if (promo.code === 'WINDOWFREE') {
      // Check if windows cleaning is in extras list
      const extrasList = Array.isArray(extras)
        ? extras
        : String(extras || '')
            .split(',')
            .map(e => e.trim().toLowerCase())
            .filter(Boolean);

      const hasWindows = extrasList.some(item =>
        item.includes('window') || item.includes('windows')
      );

      if (!hasWindows) {
        return sendError(res, 'Please add Windows Cleaning add-on to apply this promo code', 400);
      }
      // Windows cleaning adds $10, so make it free
      discountAmount = 10.0;
      message = 'Free Windows Cleaning add-on applied!';
    } else {
      // Generic percentage discount
      if (promo.type === 'percentage') {
        discountAmount = (parseFloat(subtotal) || 0) * (parseFloat(promo.value) / 100);
      } else {
        discountAmount = parseFloat(promo.value);
      }
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
