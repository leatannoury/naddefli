const https = require('https');
const { User, Cleaner } = require('../models');
const { hashPassword, comparePassword, generateToken } = require('../utils/helpers');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');

/**
 * Auth Controller
 * Handles user authentication
 */

/**
 * Register new user
 */
exports.register = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { full_name, email, phone, password } = req.body;

    // Validate input
    if (!full_name || !email || !password) {
      return sendError(res, 'Full name, email, and password are required', 400);
    }

    // Check if user exists
    const existingUser = await User.findOne({ where: { email }, transaction: t });
    if (existingUser) {
      await t.rollback();
      return sendError(res, 'Email already registered', 400);
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user (registrations always create customers)
    const user = await User.create(
      {
        full_name,
        email,
        phone,
        password: hashedPassword,
        role: 'customer',
      },
      { transaction: t }
    );

    await t.commit();

    const token = generateToken(user);

    sendSuccess(
      res,
      {
        user: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          role: user.role,
        },
        token,
      },
      'Registration successful',
      201
    );
  } catch (error) {
    await t.rollback();
    console.error('Register error:', error);
    sendError(res, 'Registration failed', 500, error);
  }
};

/**
 * Login user
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return sendError(res, 'Email and password are required', 400);
    }

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return sendError(res, 'Invalid email or password', 401);
    }

    // Compare password
    const passwordMatch = await comparePassword(password, user.password);
    if (!passwordMatch) {
      return sendError(res, 'Invalid email or password', 401);
    }

    // Check if user is blocked
    if (user.is_blocked) {
      return sendError(res, 'Your account has been suspended. Please contact support.', 403);
    }

    const token = generateToken(user);

    sendSuccess(res, {
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    console.error('Login error:', error);
    sendError(res, 'Login failed', 500, error);
  }
};

const verifyGoogleIdToken = (idToken) => {
  return new Promise((resolve, reject) => {
    const url = `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode !== 200) {
          return reject(new Error(`Invalid Google token (status ${res.statusCode})`));
        }
        try {
          const payload = JSON.parse(data);
          resolve(payload);
        } catch (error) {
          reject(error);
        }
      });
    }).on('error', (error) => reject(error));
  });
};

exports.googleLogin = async (req, res) => {
  try {
    const { id_token, email, full_name, phone } = req.body;

    if (!id_token || !email) {
      return sendError(res, 'Google token and email are required', 400);
    }

    let payload;
    try {
      payload = await verifyGoogleIdToken(id_token);
    } catch (error) {
      console.error('Google token verification error:', error);
      return sendError(res, 'Invalid Google token', 401, error);
    }

    const emailVerified =
      payload.email_verified === true ||
      payload.email_verified === 'true' ||
      payload.email_verified === '1';
    const issuerValid =
      payload.iss === 'accounts.google.com' ||
      payload.iss === 'https://accounts.google.com';

    if (!emailVerified || !issuerValid || payload.email !== email) {
      return sendError(res, 'Google account email verification failed', 401);
    }

    const firebaseUid = payload.sub || email;
    let user = await User.findOne({ where: { email } });

    if (user) {
      if (user.is_blocked) {
        return sendError(res, 'Your account has been suspended. Please contact support.', 403);
      }
    } else {
      const hashedPassword = await hashPassword(firebaseUid);
      user = await User.create({
        full_name: full_name || payload.name || 'User',
        email,
        phone: phone || payload.phone_number || null,
        password: hashedPassword,
        role: 'customer',
      });
    }

    const token = generateToken(user);

    sendSuccess(res, {
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    console.error('Google login error:', error);
    sendError(res, 'Google login failed', 500, error);
  }
};

/**
 * Get current user profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      include: [
        {
          association: 'cleanerProfile',
          model: Cleaner,
        },
      ],
      attributes: { exclude: ['password'] },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    sendSuccess(res, user);
  } catch (error) {
    console.error('Get profile error:', error);
    sendError(res, 'Failed to get profile', 500, error);
  }
};

/**
 * Update user profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const { full_name, phone } = req.body;

    const user = await User.findByPk(req.user.id);
    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Update user
    if (full_name) user.full_name = full_name;
    if (phone) user.phone = phone;

    await user.save();

    sendSuccess(res, {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      phone: user.phone,
      role: user.role,
    });
  } catch (error) {
    console.error('Update profile error:', error);
    sendError(res, 'Failed to update profile', 500, error);
  }
};
