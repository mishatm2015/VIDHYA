# Setup Instructions

## Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase account
- Android Studio / VS Code with Flutter extensions

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Vidhyakaanthi Foundation"
3. Enable Firestore Database
4. Enable Firebase Storage

### 2. Configure Firestore
1. Go to Firestore Database
2. Create the following collections:

**projects** collection:
```
projects/{projectId}
  - name: "Feed a child for a month"
  - amount: 2975
```

**donations** collection will be created automatically when you add donations.

### 3. Configure Storage
1. Go to Storage
2. Create folder structure: `receipts/` (will be created automatically)
3. Set security rules to allow authenticated access or adjust as needed

### 4. Add Firebase to Flutter App

#### For Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory

#### For iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory

#### Generate firebase_options.dart:
Run this command in the project root:
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

Or manually update `lib/firebase_options.dart` with your Firebase configuration.

## Install Dependencies

```bash
flutter pub get
```

## Add Logo (Optional)

Place your foundation logo at:
- `assets/logo/logo.png`

If logo is not provided, the app will use text "VIDHYAKAANTHI FOUNDATION" in the PDF.

## Run the App

```bash
flutter run
```

## Firestore Indexes

If you encounter query errors, you may need to create composite indexes in Firestore:
- Collection: `donations`
- Fields: `createdAt` (Ascending)

The app will work without indexes but may show warnings in console.
