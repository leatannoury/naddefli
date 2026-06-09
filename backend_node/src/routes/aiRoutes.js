/**
 * NADDEFLI — aiRoutes.js
 * Layer: Backend — Routes
 * Purpose: POST /api/ai/service-recommendation — AI cleaning planner.
 * Connects to: aiController.js
 */

const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');

router.post('/service-recommendation', aiController.getServiceRecommendation);

module.exports = router;
