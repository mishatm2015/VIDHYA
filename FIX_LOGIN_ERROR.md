# Fix Login Channel Error

## The Error
```
channel-error - "dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi.signInWithEmailAndPassword"
```

This error means Firebase Authentication is not properly enabled or configured.

## Step-by-Step Fix

### 1. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **vidhyakaandhi-foundation**
3. Click **Authentication** in the left menu
4. If you see "Get Started", click it
5. Go to **Sign-in method** tab
6. Click on **Email/Password**
7. Toggle **Enable** to ON
8. Click **Save**

### 2. Verify google-services.json

1. Make sure `google-services.json` is in `android/app/` folder
2. If not, download it again:
   - Firebase Console → Project Settings → Your apps
   - Find Android app → Download `google-services.json`
   - Place it in `android/app/google-services.json`

### 3. Clean and Rebuild

Run these commands:

```bash
flutter clean
flutter pub get
flutter run
```

**IMPORTANT**: Do a full rebuild, not just hot reload!

### 4. Create Test User

1. Firebase Console → Authentication → Users
2. Click **Add user**
3. Enter:
   - Email: `admin@test.com`
   - Password: `password123`
4. Click **Add user**

### 5. Test Login

Use the credentials you just created to login.

## Still Not Working?

### Check Firebase Console:
- ✅ Authentication is enabled
- ✅ Email/Password sign-in method is enabled
- ✅ At least one user exists

### Check Your Code:
- ✅ `google-services.json` is in `android/app/`
- ✅ `firebase_auth` package is in `pubspec.yaml`
- ✅ Firebase is initialized in `main.dart`

### Try This:
1. Stop the app completely
2. Delete `build/` folder: `rm -rf build/` (or delete manually)
3. Delete `android/.gradle/` folder
4. Run: `flutter clean`
5. Run: `flutter pub get`
6. Run: `flutter run`

## Alternative: Check if Auth is Enabled

You can verify Authentication is enabled by checking:
- Firebase Console → Authentication → Should show "Users" tab
- If you see "Get Started", Authentication is NOT enabled yet
