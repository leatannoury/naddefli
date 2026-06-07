const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');

router.post('/service-recommendation', aiController.getServiceRecommendation);

module.exports = router;
