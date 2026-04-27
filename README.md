# Receipt-app-repo
- Receipt app to figure out the fields in any receipt 
# 🧾 Receipt Parser

A full-stack mobile app that uses **Claude Vision AI** to automatically extract structured data from receipt images. Snap a photo or upload from your gallery — Claude reads the merchant name, date, line items, and total, then lets you review and save the result.

---

## 🏗️ Architecture

```
┌─────────────────────────┐        ┌──────────────────────────────┐
│   Flutter Mobile App    │  HTTP  │     Node.js Express Backend  │
│                         │◄──────►│                              │
│  • Image picker / camera│        │  • Multer file upload        │
│  • BLoC state management│        │  • Claude Vision API         │
│  • Edit & save receipts │        │  • JSON file storage         │
└─────────────────────────┘        └──────────────────────────────┘
                                              │
                                              ▼
                                   ┌─────────────────────┐
                                   │  Anthropic Claude   │
                                   │  (Vision / claude-  │
                                   │   opus-4-5)         │
                                   └─────────────────────┘
```

---

## 📁 Project Structure

```
receipt-parser/
├── backend/                     # Node.js Express server
│   ├── src/
│   │   ├── config/
│   │   │   └── index.js         # App config (ports, Claude model, upload limits)
│   │   ├── controllers/
│   │   │   ├── receiptController.js
│   │   │   └── healthController.js
│   │   ├── middleware/
│   │   │   ├── uploadMiddleware.js  # Multer file handling
│   │   │   └── errorHandler.js
│   │   ├── routes/
│   │   │   ├── receiptRoutes.js
│   │   │   └── healthRoutes.js
│   │   ├── services/
│   │   │   ├── claudeService.js     # Anthropic Vision API integration
│   │   │   ├── receiptService.js    # Parse + sanitize receipt data
│   │   │   └── storageService.js    # JSON file persistence
│   │   └── utils/
│   │       └── fileHelper.js
│   ├── app.js                   # Express app setup
│   ├── index.js                 # Server entry point (via app.js)
│   ├── uploads/                 # Temp image uploads (auto-created)
│   ├── receipts/                # Saved receipt JSONs (auto-created)
│   └── .env                     # Environment variables (create this)
│
└── mobile/                      # Flutter app
    └── lib/
        ├── main.dart
        └── features/receipt/
            ├── data/
            │   └── receipt_repository.dart
            ├── domain/models/
            │   ├── receipt.dart
            │   └── line_item.dart
            └── presentation/
                ├── bloc/
                │   ├── receipt_bloc.dart
                │   ├── receipt_event.dart
                │   └── receipt_state.dart
                └── view/
                    ├── upload_view.dart
                    └── receipt_edit_view.dart
```

---

## ⚙️ Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 18+ | [nodejs.org](https://nodejs.org) |
| npm | 9+ | Bundled with Node |
| Flutter | 3.x | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Anthropic API Key | — | [console.anthropic.com](https://console.anthropic.com) |

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/receipt-parser.git
cd receipt-parser
```

---

### 2. Backend Setup

```bash
cd backend
npm install
```

Create a `.env` file in the `backend/` directory:

```env
ANTHROPIC_API_KEY=sk-ant-your-key-here
PORT=3000
```

Start the server:

```bash
node app.js
```

You should see:

```
🚀 Receipt Parser Backend → http://localhost:3000
   GET    /health
   POST   /receipts/parse
   POST   /receipts/save
   GET    /receipts
   GET    /receipts/:id
   DELETE /receipts/:id
```

> The `uploads/` and `receipts/` directories are created automatically on first run.

---

### 3. Flutter App Setup

```bash
cd mobile
flutter pub get
```

> **Android emulator note:** The backend URL in `receipt_repository.dart` is pre-configured to `http://10.0.2.2:3000`, which is the Android emulator's alias for `localhost`. Change this if running on a physical device or iOS simulator.

| Target | URL to use |
|--------|-----------|
| Android Emulator | `http://10.0.2.2:3000` (default) |
| iOS Simulator | `http://localhost:3000` |
| Physical Device | `http://<your-machine-local-ip>:3000` |

Run the app:

```bash
flutter run
```

---

## 📡 API Reference

### `GET /health`
Returns server status.

```json
{ "status": "ok", "timestamp": "2025-01-01T00:00:00.000Z" }
```

---

### `POST /receipts/parse`
Upload a receipt image → returns structured JSON extracted by Claude.

**Request:** `multipart/form-data` with field `file` (JPEG, PNG, WEBP, or GIF, max 10 MB)

**Response:**
```json
{
  "merchant": "Starbucks",
  "date": "2025-01-15",
  "items": [
    { "name": "Latte", "amount": 5.75 },
    { "name": "Blueberry Muffin", "amount": 3.25 }
  ],
  "total": 9.00
}
```

---

### `POST /receipts/save`
Save a (reviewed/corrected) receipt to disk.

**Request body:**
```json
{
  "merchant": "Starbucks",
  "date": "2025-01-15",
  "items": [{ "name": "Latte", "amount": 5.75 }],
  "total": 5.75
}
```

**Response:** `{ "success": true, "id": "uuid", "savedAt": "ISO timestamp" }`

---

### `GET /receipts`
Returns all saved receipts, newest first.

### `GET /receipts/:id`
Returns a single receipt by ID.

### `DELETE /receipts/:id`
Deletes a receipt by ID.

---

## 🔧 Configuration

All backend config lives in `backend/src/config/index.js`:

| Setting | Default | Description |
|---------|---------|-------------|
| `PORT` | `3000` | Server port |
| `ANTHROPIC.MODEL` | `claude-opus-4-5` | Claude model to use |
| `ANTHROPIC.MAX_TOKENS` | `1024` | Max tokens in Claude response |
| `UPLOAD.MAX_SIZE` | `10 MB` | Max image upload size |
| `UPLOAD.ALLOWED_MIME_TYPES` | JPEG, PNG, WEBP, GIF | Accepted image formats |

---

## 🛠️ Flutter Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.x.x
  image_picker: ^1.x.x
  dio: ^5.x.x
  pretty_dio_logger: ^1.x.x
```

---

## 🐛 Troubleshooting

**`Connection refused` on Android emulator**
Make sure the backend is running and the URL in `receipt_repository.dart` is `http://10.0.2.2:3000`.

**`Claude returned invalid JSON` error**
This is rare but can happen with low-quality or non-receipt images. Try a clearer photo.

**`Only JPEG, PNG, WEBP, and GIF images are allowed`**
The app only accepts image files. PDFs or other formats are not supported.

**`File too large`**
Images must be under 10 MB. Compress or resize the image before uploading.

---

## 📄 License

MIT
