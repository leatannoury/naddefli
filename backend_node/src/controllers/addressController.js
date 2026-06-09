/**
 * NADDEFLI — addressController.js
 * Layer: Backend — Controller
 * Purpose: Address CRUD for logged-in customer.
 * Connects to: Address model
 */

const { Address } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * Address Controller
 * Handles user saved addresses
 */

// Get all saved addresses for current user
exports.getAddresses = async (req, res) => {
  try {
    const addresses = await Address.findAll({
      where: { user_id: req.user.id },
      order: [['created_at', 'DESC']],
    });
    sendSuccess(res, addresses, 'Addresses fetched successfully');
  } catch (error) {
    console.error('Get addresses error:', error);
    sendError(res, 'Failed to fetch addresses', 500, error);
  }
};

// Add new address
exports.addAddress = async (req, res) => {
  try {
    const { label, address, city, building, floor, notes } = req.body;

    if (!label || !address || !city) {
      return sendError(res, 'Label, address, and city are required', 400);
    }

    const newAddress = await Address.create({
      user_id: req.user.id,
      label,
      address,
      city,
      building: building || null,
      floor: floor || null,
      notes: notes || null,
    });

    sendSuccess(res, newAddress, 'Address saved successfully', 201);
  } catch (error) {
    console.error('Add address error:', error);
    sendError(res, 'Failed to save address', 500, error);
  }
};

// Edit address
exports.updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const { label, address, city, building, floor, notes } = req.body;

    const existingAddress = await Address.findByPk(id);
    if (!existingAddress) {
      return sendError(res, 'Address not found', 404);
    }

    if (existingAddress.user_id !== req.user.id) {
      return sendError(res, 'Unauthorized', 403);
    }

    if (label) existingAddress.label = label;
    if (address) existingAddress.address = address;
    if (city) existingAddress.city = city;
    existingAddress.building = building !== undefined ? building : existingAddress.building;
    existingAddress.floor = floor !== undefined ? floor : existingAddress.floor;
    existingAddress.notes = notes !== undefined ? notes : existingAddress.notes;

    await existingAddress.save();

    sendSuccess(res, existingAddress, 'Address updated successfully');
  } catch (error) {
    console.error('Update address error:', error);
    sendError(res, 'Failed to update address', 500, error);
  }
};

// Delete address
exports.deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;

    const existingAddress = await Address.findByPk(id);
    if (!existingAddress) {
      return sendError(res, 'Address not found', 404);
    }

    if (existingAddress.user_id !== req.user.id) {
      return sendError(res, 'Unauthorized', 403);
    }

    await existingAddress.destroy();

    sendSuccess(res, null, 'Address deleted successfully');
  } catch (error) {
    console.error('Delete address error:', error);
    sendError(res, 'Failed to delete address', 500, error);
  }
};
