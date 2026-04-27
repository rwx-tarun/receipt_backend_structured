const express           = require('express');
const receiptController = require('../controllers/receiptController');
const uploadMiddleware   = require('../middleware/uploadMiddleware');

const router = express.Router();

// Parse a receipt image using Claude Vision
router.post('/parse', uploadMiddleware, receiptController.parse);

// Save a corrected receipt to disk
router.post('/save', receiptController.save);

// Get all saved receipts
router.get('/', receiptController.getAll);

// Get a single receipt by ID
router.get('/:id', receiptController.getById);

// Delete a receipt by ID
router.delete('/:id', receiptController.remove);

module.exports = router;
