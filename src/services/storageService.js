const fs   = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const config         = require('../config');

const RECEIPTS_DIR = config.STORAGE.DIR;

/**
 * Save a receipt object to disk as JSON.
 * @returns {{ id, savedAt }}
 */
const saveReceipt = (receiptData) => {
  const id      = uuidv4();
  const savedAt = new Date().toISOString();
  const receipt = { id, savedAt, ...receiptData };

  fs.writeFileSync(
    path.join(RECEIPTS_DIR, `${id}.json`),
    JSON.stringify(receipt, null, 2)
  );

  return { id, savedAt };
};

/**
 * Return all saved receipts sorted newest-first.
 */
const getAllReceipts = () => {
  const files = fs.readdirSync(RECEIPTS_DIR).filter(f => f.endsWith('.json'));

  return files
    .map(file => {
      const raw = fs.readFileSync(path.join(RECEIPTS_DIR, file), 'utf-8');
      return JSON.parse(raw);
    })
    .sort((a, b) => new Date(b.savedAt) - new Date(a.savedAt));
};

/**
 * Return a single receipt by ID, or null if not found.
 */
const getReceiptById = (id) => {
  const filePath = path.join(RECEIPTS_DIR, `${id}.json`);
  if (!fs.existsSync(filePath)) return null;

  const raw = fs.readFileSync(filePath, 'utf-8');
  return JSON.parse(raw);
};

/**
 * Delete a receipt by ID. Returns true if deleted, false if not found.
 */
const deleteReceipt = (id) => {
  const filePath = path.join(RECEIPTS_DIR, `${id}.json`);
  if (!fs.existsSync(filePath)) return false;

  fs.unlinkSync(filePath);
  return true;
};

module.exports = { saveReceipt, getAllReceipts, getReceiptById, deleteReceipt };
