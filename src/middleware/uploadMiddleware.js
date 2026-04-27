const multer = require('multer');
const path   = require('path');
const { v4: uuidv4 } = require('uuid');
const config         = require('../config');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, config.UPLOAD.DIR),
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  if (config.UPLOAD.ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only JPEG, PNG, WEBP, and GIF images are allowed'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: config.UPLOAD.MAX_SIZE },
});

// Export as single-file middleware for the "file" field
module.exports = upload.single('file');
