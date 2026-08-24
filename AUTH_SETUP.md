# Firebase Authentication Setup

## Enable Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **vidhyakaandhi-foundation**
3. Navigate to **Authentication** → **Get Started**
4. Click on **Sign-in method** tab
5. Enable **Email/Password** provider:
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"

## Create User Accounts

### Option 1: Using Firebase Console (Recommended)

1. Go to **Authentication** → **Users** tab
2. Click **Add user**
3. Enter:
   - **Email**: e.g., `admin@vidhyakaandhi.org`
   - **Password**: (must be at least 6 characters)
4. Click **Add user**

### Option 2: Using Firebase CLI

```bash
firebase auth:import users.json --project vidhyakaandhi-foundation
```

## Update Firestore Security Rules (Optional)

If you want to require authentication for certain operations, update your Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Projects collection
    match /projects/{projectId} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users
    }
    
    // Donations collection
    match /donations/{donationId} {
      allow read: if true;
      allow create: if request.auth != null; // Only authenticated users can create
      allow update: if request.auth != null; // Only authenticated users can update
      allow delete: if false;
    }
  }
}
```

## Update Storage Security Rules (Optional)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /receipts/{year}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can upload
      allow delete: if false;
    }
  }
}
```

## Login Credentials

After creating users in Firebase Console, you can login to the app using:
- **Email**: The email you registered
- **Password**: The password you set

## Features

✅ Login screen with email/password authentication
✅ Automatic session management (stays logged in)
✅ Logout functionality
✅ Protected routes (main app only accessible after login)
✅ Error handling for invalid credentials

## Notes

- Users must be created in Firebase Console before they can login
- Passwords must be at least 6 characters
- The app will remember the login session until logout
- All existing functionality (projects, donations, PDF generation) works the same after login
