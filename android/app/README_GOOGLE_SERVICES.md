# Firebase Configuration

## Place google-services.json here

1. Download `google-services.json` from Firebase Console:
   - Go to Firebase Console → Your Project → Project Settings
   - Under "Your apps", find your Android app
   - Click "Download google-services.json"

2. Place the downloaded file in this directory:
   ```
   android/app/google-services.json
   ```

3. The file should be at:
   ```
   E:\flutterprojects\vidhyakandhi_foundation\android\app\google-services.json
   ```

## Important Notes:

- The package name in Firebase must match: `com.example.vidhyakandhi_foundation`
- If you used a different package name in Firebase, update `applicationId` in `android/app/build.gradle.kts`
- The Google Services plugin is already configured in the build files
- After placing the file, run `flutter clean` and `flutter pub get`
