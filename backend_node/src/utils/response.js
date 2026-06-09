/**
 * NADDEFLI — response.js
 * Layer: Backend — Utility
 * Purpose: Standardized success/error JSON response helpers.
 * Connects to: Controllers
 */

/**
 * Standard API Response Format
 */
const sendSuccess = (res, data, message = 'Success', statusCode = 200) => {
  res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

/**
 * Standard Error Response Format
 */
const sendError = (res, message = 'Error', statusCode = 500, error = null) => {
  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? error : null,
  });
};

module.exports = {
  sendSuccess,
  sendError,
};
