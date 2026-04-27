require('dotenv').config();

const express = require('express');
const cors    = require('cors');

const { ensureDirectories } = require('./utils/fileHelper');
const errorHandler           = require('./middleware/errorHandler');
const receiptRoutes          = require('./routes/receiptRoutes');
const healthRoutes           = require('./routes/healthRoutes');

const app  = express();
const PORT = process.env.PORT || 3000;

// ─── Ensure required directories exist ────────────────────────────────────────
ensureDirectories();

// ─── Global Middleware ─────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/health',   healthRoutes);
app.use('/receipts', receiptRoutes);

// ─── Global Error Handler (must be last) ──────────────────────────────────────
app.use(errorHandler);

// ─── Start Server ─────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🚀 Receipt Parser Backend → http://localhost:${PORT}`);
  console.log('   GET    /health');
  console.log('   POST   /receipts/parse');
  console.log('   POST   /receipts/save');
  console.log('   GET    /receipts');
  console.log('   GET    /receipts/:id');
  console.log('   DELETE /receipts/:id\n');
});
