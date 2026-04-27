const path = require('path');

module.exports = {
  PORT: process.env.PORT || 3000,

  ANTHROPIC: {
    API_KEY: process.env.ANTHROPIC_API_KEY,
    MODEL:   'claude-opus-4-5',
    MAX_TOKENS: 1024,
  },

  UPLOAD: {
    DIR:       path.join(__dirname, '../../uploads'),
    MAX_SIZE:  10 * 1024 * 1024, // 10 MB
    ALLOWED_MIME_TYPES: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
  },

  STORAGE: {
    DIR: path.join(__dirname, '../../receipts'),
  },
};
