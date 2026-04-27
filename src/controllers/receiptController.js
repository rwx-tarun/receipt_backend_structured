const receiptService = require('../services/receiptService');
const storageService = require('../services/storageService');
const { cleanupFile } = require('../utils/fileHelper');

/**
 * POST /receipts/parse
 * Upload image → Claude Vision → structured JSON
 */
const parse = async (req, res, next) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image file uploaded. Use field name "file".' });
  }

  try {
    const receipt = await receiptService.parseReceiptImage(req.file);
    res.json(receipt);
  } catch (err) {
    next(err);
  } finally {
    // Always remove the temp upload regardless of outcome
    cleanupFile(req.file.path);
  }
};

/**
 * POST /receipts/save
 * Save a corrected receipt to disk
 */
const save = async (req, res, next) => {
  const { merchant, date, items, total } = req.body;

  if (!merchant || !date || !Array.isArray(items) || total === undefined) {
    return res.status(400).json({
      error: 'Invalid body. Required fields: merchant, date, items[], total',
    });
  }

  try {
    const saved = storageService.saveReceipt({ merchant, date, items, total });
    res.json({ success: true, ...saved });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /receipts
 * Return all saved receipts, newest first
 */
const getAll = (req, res, next) => {
  try {
    const receipts = storageService.getAllReceipts();
    res.json(receipts);
  } catch (err) {
    next(err);
  }
};

/**
 * GET /receipts/:id
 * Return a single saved receipt
 */
const getById = (req, res, next) => {
  try {
    const receipt = storageService.getReceiptById(req.params.id);
    if (!receipt) {
      return res.status(404).json({ error: 'Receipt not found' });
    }
    res.json(receipt);
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /receipts/:id
 * Delete a saved receipt
 */
const remove = (req, res, next) => {
  try {
    const deleted = storageService.deleteReceipt(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Receipt not found' });
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

module.exports = { parse, save, getAll, getById, remove };
