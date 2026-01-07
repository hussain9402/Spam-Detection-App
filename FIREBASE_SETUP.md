# Firebase Authentication Setup Guide

This guide will help you set up Firebase Authentication for your Chatbox app.

## Prerequisites

1. A Firebase account (create one at https://firebase.google.com/)
2. FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
3. Your Flutter project set up

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard
4. Enable Google Analytics (optional but recommended)

## Step 2: Add Firebase to Your Flutter App

### For Android:

1. In Firebase Console, click the Android icon to add an Android app
2. Register your app with package name: `com.example.spamdetection`
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### For iOS:

1. In Firebase Console, click the iOS icon to add an iOS app
2. Register your app with bundle ID: `com.example.spamdetection`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag `GoogleService-Info.plist` into the Runner project

## Step 3: Enable Authentication Methods

In Firebase Console, go to **Authentication > Sign-in method** and enable:

### Email/Password:
1. Click on "Email/Password"
2. Enable "Email/Password" provider
3. Click "Save"

### Google Sign-In:
1. Click on "Google"
2. Enable the provider
3. Set support email
4. Click "Save"

### Facebook Sign-In:
1. Click on "Facebook"
2. Enable the provider
3. You'll need:
   - App ID from [Facebook Developers](https://developers.facebook.com/)
   - App Secret from Facebook Developers
4. Add these to Firebase Console
5. Click "Save"

### Apple Sign-In:
1. Click on "Apple"
2. Enable the provider
3. Configure Apple Developer settings (requires Apple Developer account)
4. Click "Save"

## Step 4: Configure Social Sign-In

### Google Sign-In Setup:

**Android:**
- Add SHA-1 fingerprint to Firebase Console
- Get SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
- Add SHA-1 in Firebase Console > Project Settings > Your Android app

**iOS:**
- Configure URL scheme in `ios/Runner/Info.plist`
- Add reverse client ID as URL scheme

### Facebook Sign-In Setup:

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use existing
3. Add Facebook Login product
4. Configure OAuth redirect URIs:
   - Android: `fb{APP_ID}://authorize`
   - iOS: `fb{APP_ID}://authorize`
5. Get App ID and App Secret
6. Add to Firebase Console

### Apple Sign-In Setup:

1. Requires Apple Developer account ($99/year)
2. Configure in Apple Developer Portal
3. Set up Service ID and Key
4. Configure in Firebase Console

## Step 5: Initialize Firebase in Your App

The app is already configured to initialize Firebase in `lib/main.dart`. Make sure you have:

1. `google-services.json` (Android) in `android/app/`
2. `GoogleService-Info.plist` (iOS) in `ios/Runner/`
3. Firebase initialized in `main()` function

## Step 6: Test the Authentication

1. Run the app: `flutter run`
2. Test email/password signup and login
3. Test Google Sign-In
4. Test Facebook Sign-In (if configured)
5. Test Apple Sign-In (if configured)

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error:**
   - Make sure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
   - Run `flutter clean` and `flutter pub get`
   - Rebuild the app

2. **Google Sign-In not working:**
   - Check SHA-1 fingerprint is added to Firebase Console
   - Verify OAuth client IDs are configured

3. **Facebook Sign-In not working:**
   - Verify App ID and App Secret in Firebase Console
   - Check OAuth redirect URIs are correct

4. **Apple Sign-In not working:**
   - Requires physical iOS device (doesn't work on simulator)
   - Verify Apple Developer configuration

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

## Notes

- The app uses GetX for state management
- Authentication state is automatically managed by Firebase Auth
- User data is stored in `AuthController` and synced with Firebase
- All authentication methods are async and show loading states



