const Anthropic = require('@anthropic-ai/sdk');
const config    = require('../config');

const client = new Anthropic({ apiKey: config.ANTHROPIC.API_KEY });

/**
 * Send a receipt image (base64) to Claude Vision and get raw JSON text back.
 * @param {string} base64Image
 * @param {string} mimeType
 * @returns {Promise<string>} raw JSON string from Claude
 */
const extractReceiptData = async (base64Image, mimeType) => {
  const response = await client.messages.create({
    model:      config.ANTHROPIC.MODEL,
    max_tokens: config.ANTHROPIC.MAX_TOKENS,
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            source: { type: 'base64', media_type: mimeType, data: base64Image },
          },
          {
            type: 'text',
            text: `Analyze this receipt image and extract its data.
Return ONLY a valid JSON object — no extra text, no markdown, no code fences.

Required format:
{
  "merchant": "store name",
  "date": "YYYY-MM-DD",
  "items": [
    { "name": "item description", "amount": 0.00 }
  ],
  "total": 0.00
}

Rules:
- merchant : visible store/restaurant name, or "Unknown"
- date     : format YYYY-MM-DD; use today if not visible
- items    : every line item with numeric price
- total    : final grand total as a number
- All amounts must be numbers (float), never strings`,
          },
        ],
      },
    ],
  });

  // Collect all text blocks into one string
  return response.content
    .filter(block => block.type === 'text')
    .map(block => block.text)
    .join('');
};

module.exports = { extractReceiptData };
