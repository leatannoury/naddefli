const { buildRecommendation } = require('../utils/serviceRecommendationEngine');
const { generateAdvisorSummary } = require('../services/geminiService');
const { sendSuccess, sendError } = require('../utils/response');

exports.getServiceRecommendation = async (req, res) => {
  try {
    const answers = req.body?.answers || req.body || {};
    const required = ['propertyType', 'bedrooms', 'bathrooms', 'kitchens', 'situation'];

    for (const field of required) {
      if (!answers[field]) {
        return sendError(res, `Missing required answer: ${field}`, 400);
      }
    }

    const recommendation = buildRecommendation(answers);
    const aiSummary = await generateAdvisorSummary(answers, recommendation);

    sendSuccess(res, {
      ...recommendation,
      summary: aiSummary,
      poweredByAi: !!process.env.GEMINI_API_KEY,
    });
  } catch (error) {
    console.error('Service recommendation error:', error);
    sendError(res, 'Failed to generate service recommendation', 500, error);
  }
};
