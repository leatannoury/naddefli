const { Service } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');
const { formatServiceRecord } = require('../utils/helpers');

/**
 * Service Controller
 * Handles service operations
 */

/**
 * Get all services
 */
exports.getAllServices = async (req, res) => {
  try {
    const services = await Service.findAll({
      where: { is_active: true },
    });
    sendSuccess(res, services.map(formatServiceRecord));
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

    sendSuccess(res, formatServiceRecord(service));
  } catch (error) {
    console.error('Get service error:', error);
    sendError(res, 'Failed to fetch service', 500, error);
  }
};
