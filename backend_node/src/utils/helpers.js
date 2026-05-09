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
 * Calculate dynamic price based on service and conditions
 */
const calculatePrice = (basePrice, options = {}) => {
  let finalPrice = parseFloat(basePrice);
  const { 
    isUrgent = false, 
    is_custom = false, 
    room_count = 0, 
    bathrooms_count = 0, 
    kitchens_count = 0,
    cleaning_type = 'normal',
    extras_count = 0
  } = options;

  if (is_custom) {
    // Basic rooms (living/bed) are $20 each
    finalPrice += (room_count * 20);
    // Bathrooms are $30 each
    finalPrice += (bathrooms_count * 30);
    // Kitchens are $40 each
    finalPrice += (kitchens_count * 40);
  }

  // Deep cleaning adds 50% to the total
  if (cleaning_type === 'deep') {
    finalPrice = finalPrice * 1.5;
  }

  finalPrice += (extras_count * 15);

  // Add 20% surcharge for urgent same-day bookings
  if (isUrgent) {
    finalPrice = finalPrice * 1.2;
  }

  return Math.round(finalPrice * 100) / 100; // Round to 2 decimal places
};

module.exports = {
  hashPassword,
  comparePassword,
  generateToken,
  calculatePrice,
};
