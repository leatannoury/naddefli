/**
 * NADDEFLI — addonController.js
 * Layer: Backend — Controller
 * Purpose: List active add-ons; admin CRUD.
 * Connects to: AddOn model
 */

const { AddOn } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');

exports.getPublicAddOns = async (req, res) => {
  try {
    const addons = await AddOn.findAll({ where: { is_active: true }, order: [['name', 'ASC']] });
    sendSuccess(res, addons);
  } catch (error) {
    console.error('Get public addons error:', error);
    sendError(res, 'Failed to fetch add-ons', 500, error);
  }
};

exports.getAllAddOns = async (req, res) => {
  try {
    const addons = await AddOn.findAll({ order: [['created_at', 'DESC']] });
    sendSuccess(res, addons);
  } catch (error) {
    console.error('Get addons error:', error);
    sendError(res, 'Failed to fetch add-ons', 500, error);
  }
};

exports.createAddOn = async (req, res) => {
  try {
    const { name, price, is_active } = req.body;
    if (!name) return sendError(res, 'Name is required', 400);
    const addon = await AddOn.create({ name: name.toString().trim(), price: parseFloat(price) || 0.0, is_active: !!is_active });
    sendSuccess(res, addon, 'Add-on created', 201);
  } catch (error) {
    console.error('Create addon error:', error);
    sendError(res, 'Failed to create add-on', 500, error);
  }
};

exports.updateAddOn = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, is_active } = req.body;
    const addon = await AddOn.findByPk(id);
    if (!addon) return sendError(res, 'Add-on not found', 404);
    if (name !== undefined) addon.name = name.toString().trim();
    if (price !== undefined) addon.price = parseFloat(price) || 0.0;
    if (is_active !== undefined) addon.is_active = !!is_active;
    await addon.save();
    sendSuccess(res, addon, 'Add-on updated');
  } catch (error) {
    console.error('Update addon error:', error);
    sendError(res, 'Failed to update add-on', 500, error);
  }
};

exports.deleteAddOn = async (req, res) => {
  try {
    const { id } = req.params;
    const addon = await AddOn.findByPk(id);
    if (!addon) return sendError(res, 'Add-on not found', 404);
    await addon.destroy();
    sendSuccess(res, null, 'Add-on deleted');
  } catch (error) {
    console.error('Delete addon error:', error);
    sendError(res, 'Failed to delete add-on', 500, error);
  }
};
