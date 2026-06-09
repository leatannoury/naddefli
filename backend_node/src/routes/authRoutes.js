/**
 * NADDEFLI — authRoutes.js
 * Layer: Backend — Routes
 * Purpose: Maps /api/auth URLs to authController (register, login, google, profile).
 * Connects to: authController.js
 */

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authMiddleware } = require('../middleware/auth');

/**
 * Authentication Routes
 */

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/google', authController.googleLogin);

// Protected routes
router.get('/profile', authMiddleware, authController.getProfile);
router.put('/profile', authMiddleware, authController.updateProfile);

module.exports = router;
