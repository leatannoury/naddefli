const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');

/**
 * Service Routes
 */

router.get('/', serviceController.getAllServices);
router.get('/:id', serviceController.getServiceById);

module.exports = router;
