const { Service } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * Service Controller
 * Handles service operations
 */

/**
 * Get all services
 */
exports.getAllServices = async (req, res) => {
  try {
    const services = await Service.findAll();
    sendSuccess(res, services);
  } catch (error) {
    console.error('Get services error:', error);
    sendError(res, 'Failed to fetch services', 500, error);
  }
};

/**
 * Get service by ID
 */
exports.getServiceById = async (req, res) => {
  try {
    const { id } = req.params;

    const service = await Service.findByPk(id);
    if (!service) {
      return sendError(res, 'Service not found', 404);
    }

    sendSuccess(res, service);
  } catch (error) {
    console.error('Get service error:', error);
    sendError(res, 'Failed to fetch service', 500, error);
  }
};
