# Receipt Parser Backend (Structured)

Node.js + Express backend with a clean layered architecture.

## Folder Structure

```
src/
├── app.js                      ← Entry point, registers middleware & routes
├── config/
│   └── index.js                ← All env vars & constants in one place
├── routes/
│   ├── healthRoutes.js         ← GET /health
│   └── receiptRoutes.js        ← All /receipts/* routes
├── controllers/
│   ├── healthController.js     ← Health check handler
│   └── receiptController.js    ← Request/response logic only
├── services/
│   ├── claudeService.js        ← Claude Vision API wrapper
│   ├── receiptService.js       ← Parse + sanitize business logic
│   └── storageService.js       ← File-based CRUD for saved receipts
├── middleware/
│   ├── uploadMiddleware.js     ← Multer config (file type, size limits)
│   └── errorHandler.js        ← Global Express error handler
└── utils/
    └── fileHelper.js           ← base64, MIME type, cleanup helpers
```

## Setup

```bash
npm install
cp .env.example .env     # fill in your Anthropic API key
npm run dev
```

## Environment Variables

| Variable            | Description                          |
|---------------------|--------------------------------------|
| `ANTHROPIC_API_KEY` | Your key from console.anthropic.com  |
| `PORT`              | Server port (default: 3000)          |

## API Reference

| Method   | Endpoint          | Description                         |
|----------|-------------------|-------------------------------------|
| GET      | /health           | Health check                        |
| POST     | /receipts/parse   | Upload image → extracted JSON       |
| POST     | /receipts/save    | Save corrected receipt to disk      |
| GET      | /receipts         | List all saved receipts             |
| GET      | /receipts/:id     | Get single receipt                  |
| DELETE   | /receipts/:id     | Delete receipt                      |

### POST /receipts/parse
- **Body:** `multipart/form-data`, field name `file` (JPEG/PNG/WEBP/GIF, max 10MB)
- **Response:**
```json
{
  "merchant": "Reliance Fresh",
  "date": "2024-01-15",
  "items": [
    { "name": "Milk 1L", "amount": 62.0 },
    { "name": "Bread",   "amount": 45.0 }
  ],
  "total": 107.0
}
```

### POST /receipts/save
- **Body:**
```json
{
  "merchant": "Reliance Fresh",
  "date": "2024-01-15",
  "items": [{ "name": "Milk 1L", "amount": 62.0 }],
  "total": 62.0
}
```
- **Response:** `{ "success": true, "id": "uuid", "savedAt": "ISO date" }`

## Flutter Integration

In `receipt_repository.dart`:
```dart
// Android emulator
ReceiptRepository({this.baseUrl = 'http://10.0.2.2:3000'});

// iOS simulator / web
ReceiptRepository({this.baseUrl = 'http://localhost:3000'});
```

Update the endpoint path:
```dart
Uri.parse('$baseUrl/receipts/parse')   // was /parse-receipt
Uri.parse('$baseUrl/receipts/save')    // was /save-receipt
```
