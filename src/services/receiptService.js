const { fileToBase64, getMimeType } = require('../utils/fileHelper');
const claudeService                  = require('./claudeService');

/**
 * Parse a receipt image file using Claude Vision.
 * @param {Express.Multer.File} file
 * @returns {Promise<{ merchant, date, items, total }>}
 */
const parseReceiptImage = async (file) => {
  const base64Image = fileToBase64(file.path);
  const mimeType    = getMimeType(file.path);

  const rawText = await claudeService.extractReceiptData(base64Image, mimeType);

  const parsed = parseClaudeResponse(rawText);
  return sanitizeReceipt(parsed);
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Strip markdown fences and parse JSON from Claude response.
 */
const parseClaudeResponse = (rawText) => {
  const cleaned = rawText.replace(/```json|```/g, '').trim();

  try {
    return JSON.parse(cleaned);
  } catch {
    throw new Error(`Claude returned invalid JSON: ${cleaned}`);
  }
};

/**
 * Sanitize and normalize parsed receipt data.
 */
const sanitizeReceipt = (data) => ({
  merchant: String(data.merchant || 'Unknown'),
  date:     data.date || new Date().toISOString().split('T')[0],
  items:    Array.isArray(data.items)
    ? data.items.map(item => ({
        name:   String(item.name || ''),
        amount: parseFloat(item.amount) || 0,
      }))
    : [],
  total: parseFloat(data.total) || 0,
});

module.exports = { parseReceiptImage };
