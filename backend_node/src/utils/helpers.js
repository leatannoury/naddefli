const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

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
 * Calculate dynamic price based on service, duration, add-ons, and discounts
 */
const calculatePrice = (options = {}) => {
  const {
    duration_hours = 1,
    cleaning_type = 'normal',
    extras = '',
    is_custom = false,
    room_count = 0,
    bathrooms_count = 0,
    kitchens_count = 0,
    isUrgent = false,
    discount_amount = 0,
    redeem_loyalty = false,
  } = options;

  // Hourly base rate: Normal = $4, Deep = $6
  const hourlyRate = cleaning_type === 'deep' ? 6.0 : 4.0;
  
  // Base cleaning price
  let baseCleaningPrice = redeem_loyalty ? 0.0 : (hourlyRate * parseFloat(duration_hours));

  // Add-ons dictionary
  const ADDON_PRICES = {
    'windows cleaning': 10.0,
    'inside windows': 10.0,
    'oven cleaning': 8.0,
    'inside oven': 8.0,
    'fridge cleaning': 8.0,
    'inside fridge': 8.0,
    'balcony cleaning': 6.0,
    'balcony': 6.0,
    'inside cabinets': 5.0,
    'laundry folding': 7.0,
    'ironing': 7.0,
  };

  let addOnsPrice = 0.0;
  
  // Parse extras (can be comma-separated string or array)
  const extrasList = Array.isArray(extras)
    ? extras
    : String(extras || '')
        .split(',')
        .map(e => e.trim().toLowerCase())
        .filter(Boolean);

  extrasList.forEach(extra => {
    let matched = false;
    for (const [key, price] of Object.entries(ADDON_PRICES)) {
      if (extra.includes(key) || key.includes(extra)) {
        addOnsPrice += price;
        matched = true;
        break;
      }
    }
    // Default fallback price for other extras
    if (!matched) {
      addOnsPrice += 15.0;
    }
  });

  let customRoomsPrice = 0.0;
  if (is_custom) {
    // Custom property room rates
    customRoomsPrice += (parseInt(room_count, 10) || 0) * 20.0;
    customRoomsPrice += (parseInt(bathrooms_count, 10) || 0) * 30.0;
    customRoomsPrice += (parseInt(kitchens_count, 10) || 0) * 40.0;
  }

  let finalPrice = baseCleaningPrice + addOnsPrice + customRoomsPrice;

  // Add 20% surcharge for urgent same-day bookings (less than 24h)
  if (isUrgent) {
    finalPrice *= 1.2;
  }

  // Deduct discount
  finalPrice -= parseFloat(discount_amount) || 0.0;

  // Enforce minimum price of $0
  return Math.max(0.0, Math.round(finalPrice * 100) / 100);
};

module.exports = {
  hashPassword,
  comparePassword,
  generateToken,
  calculatePrice,
};
