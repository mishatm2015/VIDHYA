# Vidhyakaanthi Foundation

Donation Management App built with Flutter and Firebase.

## Features

- 📊 Dashboard with total collection and donor count
- 📝 Add donations with project selection or custom amount
- 📄 PDF receipt generation
- ☁️ Firebase Storage integration
- 📤 Share receipts via WhatsApp/Email
- 📋 Recent donations list

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Run `flutterfire configure` or manually add `firebase_options.dart`

3. Run the app:
```bash
flutter run
```

## Firebase Structure

### Firestore Collections

**projects**
```
projects/{projectId}
  - name: String
  - amount: Number
```

**donations**
```
donations/{donationId}
  - donorName: String
  - phone: String
  - pan: String
  - address: String
  - projectName: String (or "Custom")
  - amount: Number
  - pdfUrl: String
  - createdAt: Timestamp
```

### Storage Structure
```
receipts/
  └── 2026/
      └── {donationId}.pdf
```
