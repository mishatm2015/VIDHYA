# Firebase Configuration for iOS

## Place GoogleService-Info.plist here

1. Download `GoogleService-Info.plist` from Firebase Console:
   - Go to Firebase Console → Your Project → Project Settings
   - Under "Your apps", find your iOS app
   - Click "Download GoogleService-Info.plist"

2. Place the downloaded file in this directory:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

3. The file should be at:
   ```
   E:\flutterprojects\vidhyakandhi_foundation\ios\Runner\GoogleService-Info.plist
   ```

## Important Notes:

- The bundle ID in Firebase must match: `com.vidhyakandhi.vidhyakandhiFoundation`
- The bundle ID is already configured in the Xcode project
- After placing the file, you may need to add it to the Xcode project:
  - Open `ios/Runner.xcworkspace` in Xcode
  - Right-click on "Runner" folder → "Add Files to Runner"
  - Select `GoogleService-Info.plist`
  - Make sure "Copy items if needed" is checked
  - Click "Add"

## Alternative (Using FlutterFire CLI):

After placing the file, you can also run:
```bash
flutterfire configure
```

This will automatically configure Firebase for all platforms.
