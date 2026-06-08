const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

/**
 * Hash password using bcrypt
 */
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
};

/**
 * Compare password with hashed password
 */
const comparePassword = async (password, hashedPassword) => {
  return bcrypt.compare(password, hashedPassword);
};

/**
 * Generate JWT token
 */
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRY || '7d' }
  );
};

/**
 * Read settings from file
 * @returns {Object} settings object with normalHourlyRate and deepHourlyRate
 */
const readSettings = () => {
  try {
    const settingsPath = path.join(__dirname, '../config/settings.json');
    if (fs.existsSync(settingsPath)) {
      const raw = fs.readFileSync(settingsPath);
      const settings = JSON.parse(raw);
      return {
        normalHourlyRate: settings.normalHourlyRate || 4.0,
        deepHourlyRate: settings.deepHourlyRate || 6.0
      };
    }
  } catch (err) {
    console.error('Error reading settings file for calculatePrice:', err);
  }
  // Fallback to default rates
  return { normalHourlyRate: 4.0, deepHourlyRate: 6.0 };
};

/**
 * Calculate dynamic price based on service, duration, add-ons, and discounts
 */
const calculatePrice = (options = {}) => {
  const {
    duration_hours = 1,
    cleaning_type = 'normal',
    add_ons_price = 0,
    discount_amount = 0,
    redeem_loyalty = false,
  } = options;

  // Get hourly rates from settings
  const { normalHourlyRate, deepHourlyRate } = readSettings();
  const hourlyRate = cleaning_type === 'deep' ? deepHourlyRate : normalHourlyRate;
   
  // Base cleaning price
  let baseCleaningPrice = redeem_loyalty ? 0.0 : (hourlyRate * parseFloat(duration_hours));

  // Room counts are informational only — no price impact
  let finalPrice = baseCleaningPrice + (parseFloat(add_ons_price) || 0.0);

  // Deduct discount
  finalPrice -= parseFloat(discount_amount) || 0.0;

  // Enforce minimum price of $0
  return Math.max(0.0, Math.round(finalPrice * 100) / 100);
};

/**
 * Parse admin dashboard / analytics date filters (local day boundaries).
 */
const parseDashboardDateRange = (query = {}) => {
  const filterMode = String(query.filterMode || '').toLowerCase();
  let startDate = query.startDate ? new Date(`${query.startDate}T00:00:00.000`) : null;
  let endDate = query.endDate ? new Date(`${query.endDate}T23:59:59.999`) : null;

  if (filterMode === 'today' || (!query.startDate && !query.endDate && filterMode !== 'all' && filterMode !== 'trend')) {
    const today = new Date();
    startDate = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0, 0);
    endDate = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59, 999);
  }

  if (startDate && !endDate) {
    endDate = new Date(startDate);
    endDate.setHours(23, 59, 59, 999);
  }

  if (!startDate && endDate) {
    startDate = new Date(endDate);
    startDate.setHours(0, 0, 0, 0);
  }

  const hasRange = filterMode !== 'all' && !!(startDate && endDate);
  const dateField = query.dateField === 'created_at' ? 'created_at' : 'booking_date';

  return { startDate, endDate, hasRange, filterMode, dateField };
};

/**
 * Resolve stored service image path to a fetchable URL.
 */
const resolveServiceImageUrl = (image) => {
  if (!image || typeof image !== 'string') return null;
  const trimmed = image.trim();
  if (!trimmed) return null;
  if (/^https?:\/\//i.test(trimmed) || trimmed.startsWith('data:image')) {
    return trimmed;
  }
  const base = (process.env.PUBLIC_BASE_URL || 'http://localhost:5000').replace(/\/$/, '');
  const normalized = trimmed.replace(/^\//, '');
  if (normalized.startsWith('uploads/')) {
    return `${base}/${normalized}`;
  }
  return `${base}/uploads/${normalized}`;
};

/**
 * Normalize promo condition stored as plain string or JSON.
 */
const normalizePromoCondition = (raw) => {
  if (!raw) return null;
  if (typeof raw === 'object') {
    return raw.rule || raw.condition || raw.type || null;
  }
  let value = String(raw).trim();
  if (!value) return null;
  try {
    const parsed = JSON.parse(value);
    if (typeof parsed === 'string') return parsed;
    if (parsed && typeof parsed === 'object') {
      return parsed.rule || parsed.condition || parsed.type || null;
    }
  } catch (_) {
    // not JSON — use raw string
  }
  return value.replace(/^"|"$/g, '');
};

/**
 * Validate promo business rules. Returns { ok, message }.
 */
const evaluatePromoConditions = async ({
  conditions,
  cleaning_type,
  subtotal,
  booking_date,
  userId,
  Booking,
}) => {
  const rule = normalizePromoCondition(conditions);
  if (!rule) return { ok: true };

  const sub = parseFloat(subtotal || 0);
  const cleaningType = String(cleaning_type || 'normal').toLowerCase();

  switch (rule) {
    case 'minimum_order_50':
      if (sub < 50) {
        return { ok: false, message: 'Minimum order of $50 required to use this promo code' };
      }
      break;
    case 'minimum_order_100':
      if (sub < 100) {
        return { ok: false, message: 'Minimum order of $100 required to use this promo code' };
      }
      break;
    case 'deep_cleaning_only':
      if (cleaningType !== 'deep') {
        return { ok: false, message: 'This promo code only works for Deep Cleaning services' };
      }
      break;
    case 'standard_cleaning_only':
      if (!['normal', 'standard'].includes(cleaningType)) {
        return { ok: false, message: 'This promo code only works for Standard Cleaning services' };
      }
      break;
    case 'first_time_customers':
    case 'new_customers': {
      const completedCount = await Booking.count({
        where: { user_id: userId, status: 'completed' },
      });
      if (completedCount > 0) {
        return { ok: false, message: 'This promo code only works for new customers' };
      }
      break;
    }
    case 'recurring_customers': {
      const completedCountRecur = await Booking.count({
        where: { user_id: userId, status: 'completed' },
      });
      if (completedCountRecur === 0) {
        return { ok: false, message: 'This promo code only works for returning customers' };
      }
      break;
    }
    case 'weekend_only': {
      if (!booking_date) {
        return { ok: false, message: 'Please select a booking date before applying this promo code' };
      }
      const day = new Date(booking_date).getDay();
      if (day !== 0 && day !== 6) {
        return { ok: false, message: 'This promo code is only valid for weekend bookings' };
      }
      break;
    }
    default:
      break;
  }

  return { ok: true };
};

const formatServiceRecord = (service) => {
  const plain = service.toJSON ? service.toJSON() : { ...service };
  return {
    ...plain,
    image_url: resolveServiceImageUrl(plain.image),
  };
};

const getBookingDisplayName = (booking) => {
  const plain = booking?.toJSON ? booking.toJSON() : { ...(booking || {}) };
  const isCustom = plain.is_custom === true || plain.is_custom === 1 || plain.is_custom === 'true';

  if (isCustom) {
    const type = String(plain.cleaning_type || 'normal').toLowerCase() === 'deep' ? 'Deep' : 'Normal';
    return `Custom Cleaning (${type})`;
  }

  if (plain.service?.name) return plain.service.name;
  if (plain.service_name) return plain.service_name;
  return 'Cleaning Service';
};

const formatBookingRecord = (booking) => {
  const plain = booking?.toJSON ? booking.toJSON() : { ...(booking || {}) };
  return {
    ...plain,
    display_service_name: getBookingDisplayName(booking),
  };
};

module.exports = {
  hashPassword,
  comparePassword,
  generateToken,
  calculatePrice,
  parseDashboardDateRange,
  resolveServiceImageUrl,
  normalizePromoCondition,
  evaluatePromoConditions,
  formatServiceRecord,
  getBookingDisplayName,
  formatBookingRecord,
};
