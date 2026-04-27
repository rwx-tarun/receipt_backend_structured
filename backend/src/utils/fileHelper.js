const fs   = require('fs');
const path = require('path');
const config = require('../config');

/**
 * Ensure all required directories exist at startup.
 */
const ensureDirectories = () => {
  [config.UPLOAD.DIR, config.STORAGE.DIR].forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      console.log(`📁 Created directory: ${dir}`);
    }
  });
};

/**
 * Read a file and return its base64 encoded content.
 */
const fileToBase64 = (filePath) => {
  const buffer = fs.readFileSync(filePath);
  return buffer.toString('base64');
};

/**
 * Return the MIME type for a given file path based on extension.
 */
const getMimeType = (filePath) => {
  const ext = path.extname(filePath).toLowerCase();
  const map = {
    '.jpg':  'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png':  'image/png',
    '.webp': 'image/webp',
    '.gif':  'image/gif',
  };
  return map[ext] || 'image/jpeg';
};

/**
 * Silently delete a file (used to clean up temp uploads).
 */
const cleanupFile = (filePath) => {
  if (!filePath) return;
  fs.unlink(filePath, (err) => {
    if (err) console.warn(`⚠️  Could not delete temp file: ${filePath}`);
  });
};

module.exports = { ensureDirectories, fileToBase64, getMimeType, cleanupFile };
