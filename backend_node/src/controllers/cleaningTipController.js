const { CleaningTip } = require('../models');
const { sendSuccess, sendError } = require('../utils/response');

const hashDate = (dateStr) => {
  let hash = 0;
  for (let i = 0; i < dateStr.length; i += 1) {
    hash = ((hash << 5) - hash) + dateStr.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash);
};

exports.getTipOfTheDay = async (req, res) => {
  try {
    const tips = await CleaningTip.findAll({
      where: { is_active: true },
      order: [['created_at', 'ASC']],
    });

    if (!tips.length) {
      return sendSuccess(res, null, 'No tips available');
    }

    const today = new Date().toISOString().split('T')[0];
    const index = hashDate(today) % tips.length;
    sendSuccess(res, tips[index]);
  } catch (error) {
    console.error('Get tip of the day error:', error);
    sendError(res, 'Failed to fetch cleaning tip', 500, error);
  }
};

exports.getPublicTips = async (req, res) => {
  try {
    const tips = await CleaningTip.findAll({
      where: { is_active: true },
      order: [['created_at', 'ASC']],
    });
    sendSuccess(res, tips);
  } catch (error) {
    console.error('Get public tips error:', error);
    sendError(res, 'Failed to fetch cleaning tips', 500, error);
  }
};

exports.getAllTips = async (req, res) => {
  try {
    const tips = await CleaningTip.findAll({ order: [['created_at', 'DESC']] });
    sendSuccess(res, tips);
  } catch (error) {
    console.error('Get tips error:', error);
    sendError(res, 'Failed to fetch cleaning tips', 500, error);
  }
};

exports.createTip = async (req, res) => {
  try {
    const { title, content, image_url, gradient_start, gradient_end, is_active } = req.body;
    if (!title || !content) return sendError(res, 'Title and content are required', 400);

    const tip = await CleaningTip.create({
      title: title.toString().trim(),
      content: content.toString().trim(),
      image_url: image_url ? image_url.toString().trim() : null,
      gradient_start: gradient_start || '#0F766E',
      gradient_end: gradient_end || '#14B8A6',
      is_active: is_active !== false,
    });

    sendSuccess(res, tip, 'Cleaning tip created', 201);
  } catch (error) {
    console.error('Create tip error:', error);
    sendError(res, 'Failed to create cleaning tip', 500, error);
  }
};

exports.updateTip = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, image_url, gradient_start, gradient_end, is_active } = req.body;
    const tip = await CleaningTip.findByPk(id);
    if (!tip) return sendError(res, 'Cleaning tip not found', 404);

    if (title !== undefined) tip.title = title.toString().trim();
    if (content !== undefined) tip.content = content.toString().trim();
    if (image_url !== undefined) tip.image_url = image_url ? image_url.toString().trim() : null;
    if (gradient_start !== undefined) tip.gradient_start = gradient_start;
    if (gradient_end !== undefined) tip.gradient_end = gradient_end;
    if (is_active !== undefined) tip.is_active = !!is_active;

    await tip.save();
    sendSuccess(res, tip, 'Cleaning tip updated');
  } catch (error) {
    console.error('Update tip error:', error);
    sendError(res, 'Failed to update cleaning tip', 500, error);
  }
};

exports.deleteTip = async (req, res) => {
  try {
    const { id } = req.params;
    const tip = await CleaningTip.findByPk(id);
    if (!tip) return sendError(res, 'Cleaning tip not found', 404);
    await tip.destroy();
    sendSuccess(res, null, 'Cleaning tip deleted');
  } catch (error) {
    console.error('Delete tip error:', error);
    sendError(res, 'Failed to delete cleaning tip', 500, error);
  }
};
