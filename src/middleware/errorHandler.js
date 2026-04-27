/**
 * Global Express error handler.
 * Must have 4 parameters for Express to treat it as an error handler.
 */
const errorHandler = (err, req, res, next) => {
  console.error('[Error]', err.message);

  // Multer file size error
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: 'File too large. Maximum size is 10MB.' });
  }

  // Multer / validation errors (file type etc.)
  if (err.message && err.message.includes('Only')) {
    return res.status(415).json({ error: err.message });
  }

  // Claude JSON parse errors
  if (err.message && err.message.startsWith('Claude returned invalid JSON')) {
    return res.status(422).json({ error: err.message });
  }

  // Default 500
  res.status(500).json({ error: err.message || 'Internal server error' });
};

module.exports = errorHandler;
