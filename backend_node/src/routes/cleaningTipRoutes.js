const express = require('express');
const router = express.Router();
const cleaningTipController = require('../controllers/cleaningTipController');
const { authMiddleware, authorizationMiddleware } = require('../middleware/auth');

router.get('/tip-of-the-day', cleaningTipController.getTipOfTheDay);
router.get('/', cleaningTipController.getPublicTips);

const adminAuth = [authMiddleware, authorizationMiddleware(['admin'])];
router.get('/admin', adminAuth, cleaningTipController.getAllTips);
router.post('/admin', adminAuth, cleaningTipController.createTip);
router.put('/admin/:id', adminAuth, cleaningTipController.updateTip);
router.delete('/admin/:id', adminAuth, cleaningTipController.deleteTip);

module.exports = router;
