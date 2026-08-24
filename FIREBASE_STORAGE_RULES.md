# Firebase Storage Security Rules - FIX UNAUTHORIZED ERROR

## Problem
You're getting this error:
```
[firebase_storage/unauthorized] User is not authorized to perform the desired action.
```

This happens because Firebase Storage security rules are blocking PDF uploads.

## Solution: Update Storage Rules

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **vidhyakaandhi-foundation**
3. Navigate to **Storage** (left sidebar)
4. Click on the **Rules** tab

### Step 2: Copy and Paste These Rules

**For Development/Testing (Allows authenticated users to upload):**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to read and write receipts
    match /receipts/{year}/{allPaths=**} {
      allow read: if true; // Anyone can read (download PDFs)
      allow write: if request.auth != null; // Only authenticated users can upload
      allow delete: if false; // Prevent deletions
    }
    
    // Allow authenticated users to read/write other files if needed
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**OR for Quick Testing (Less Secure - Allows anyone to upload):**

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

### Step 3: Publish Rules
1. Click the **Publish** button at the top
2. Wait for confirmation that rules are published
3. Rules take effect immediately

### Step 4: Test Again
1. Go back to your app
2. Try generating a PDF again
3. The error should be resolved

## Important Notes

- **For Production**: Use the authenticated-only rules (first option)
- **For Testing**: You can use the public rules (second option) temporarily
- Make sure you're logged in to the app before generating PDFs
- The rules allow uploads to `receipts/{year}/{donationId}.pdf` path

## Verify Authentication

Make sure you're logged in:
1. Check if you see the logout button in the app
2. If not logged in, you'll see the login screen
3. Login with your Firebase Authentication credentials

## Still Having Issues?

If you still get errors after updating rules:
1. Check Firebase Console → Authentication → Users (make sure you have a user)
2. Verify you're logged in the app (check for logout button)
3. Check Storage → Rules tab to confirm rules were published
4. Try logging out and logging back in
