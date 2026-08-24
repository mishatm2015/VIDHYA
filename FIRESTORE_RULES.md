# Firestore Security Rules

## Setup Instructions

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **vidhyakaandhi-foundation**
3. Navigate to **Firestore Database** → **Rules** tab
4. Replace the existing rules with the rules below
5. Click **Publish**

## Security Rules (FIXED - For Development/Testing)

**USE THIS FOR NOW** - Allows public read, authenticated write:

Copy and paste these rules into your Firestore Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Projects collection - public read, authenticated write
    match /projects/{projectId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Donations collection - public read, authenticated write
    match /donations/{donationId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }
  }
}
```

## Alternative: Authenticated Users Only (More Secure)

If you want to require authentication for all operations:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users only
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Alternative: Public Read, Authenticated Write (If you need public read access)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Projects collection
    match /projects/{projectId} {
      allow read: if true; // Public read
      allow write: if request.auth != null; // Only authenticated users
    }
    
    // Donations collection
    match /donations/{donationId} {
      allow read: if true; // Public read
      allow create: if request.auth != null; // Only authenticated users can create
      allow update: if request.auth != null; // Only authenticated users can update
      allow delete: if false; // Prevent deletions
    }
  }
}
```

## Alternative: More Secure Rules (Recommended for Production)

If you want to add authentication later, use these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Projects collection - read only
    match /projects/{projectId} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users
    }
    
    // Donations collection
    match /donations/{donationId} {
      allow read: if true;
      allow create: if true;
      allow update: if request.auth != null; // Only authenticated users can update
      allow delete: if false;
    }
  }
}
```

## Storage Security Rules

**⚠️ IMPORTANT: This fixes the "unauthorized" error when uploading PDFs!**

For Firebase Storage (PDF receipts), go to **Storage** → **Rules** and use:

**For Authenticated Users (Recommended):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /receipts/{year}/{allPaths=**} {
      allow read: if true; // Anyone can read/download PDFs
      allow write: if request.auth != null; // Only authenticated users can upload
      allow delete: if false; // Prevent deletions
    }
  }
}
```

**For Quick Testing (Less Secure - Allows anyone to upload):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /receipts/{year}/{allPaths=**} {
      allow read, write: if true; // Public access for testing
      allow delete: if false;
    }
  }
}
```

**See `FIREBASE_STORAGE_RULES.md` for detailed instructions.**

## Important Notes:

- The rules above allow **public read/write access** for development
- For production, consider adding authentication
- Make sure to click **Publish** after updating the rules
- Rules take effect immediately after publishing
