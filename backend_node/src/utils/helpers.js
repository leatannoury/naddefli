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
const calculatePrice = (basePrice, isUrgent = false) => {
  let finalPrice = basePrice;

  // Add 20% surcharge for urgent same-day bookings
  if (isUrgent) {
    finalPrice = finalPrice * 1.2;
  }

  return finalPrice;
};

module.exports = {
  hashPassword,
  comparePassword,
  generateToken,
  calculatePrice,
};
