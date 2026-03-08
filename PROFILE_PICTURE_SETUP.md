# Profile Picture Upload Feature - Setup Guide

## Overview
This feature allows users to upload and manage their profile pictures in the Edit Profile screen using camera or gallery. The images are saved to the backend in `public/item_photos` directory and displayed on the profile screen.

## Changes Made

### 1. Flutter Frontend Changes

#### Dependencies Added (pubspec.yaml)
```yaml
image_picker: ^1.0.0          # For picking images from camera/gallery
permission_handler: ^11.4.3   # For runtime permissions
```

#### New Files Created
- **[lib/screens/edit_profile_screen.dart](lib/screens/edit_profile_screen.dart)** - Edit profile screen with image picker functionality

#### Updated Files
- **[lib/data/models/user.dart](lib/data/models/user.dart)** 
  - Added `profilePicture` field to User model
  - Updated UserAdapter serialization/deserialization

- **[lib/core/auth_service.dart](lib/core/auth_service.dart)**
  - Added `uploadProfilePicture(File imageFile)` method
  - Handles multipart file upload to backend
  - Updates local user data with image URL

- **[lib/screens/bottom_screen/profile_screen.dart](lib/screens/bottom_screen/profile_screen.dart)**
  - Added edit profile button
  - Displays profile picture (if available)
  - Shows user information
  - Navigation to edit profile screen

#### Android Permissions
**File:** [.android/app/src/main/AndroidManifest.xml](.android/app/src/main/AndroidManifest.xml)

Added permissions:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

#### iOS Permissions
**File:** [.ios/Runner/Info.plist](.ios/Runner/Info.plist)

Added keys:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera to take profile pictures.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select profile pictures.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for video recording.</string>
```

### 2. Backend Changes

#### Dependencies Added (backend/package.json)
```json
"express-fileupload": "^1.5.0"  # For handling file uploads
```

#### Updated Files
- **[backend/models/User.js](backend/models/User.js)**
  - Added `profilePicture` field to User schema

- **[backend/controllers/authController.js](backend/controllers/authController.js)**
  - Added `uploadProfilePicture` endpoint
  - Validates file type (JPEG, PNG, GIF, WebP)
  - Saves files to `public/item_photos` directory
  - Updates user document with image URL

- **[backend/routes/authRoutes.js](backend/routes/authRoutes.js)**
  - Added POST `/api/v1/auth/upload-profile-picture` route

- **[backend/server.js](backend/server.js)**
  - Added express-fileupload middleware
  - Added static file serving for uploaded images
  - Changed PORT from 3000 to 5000

#### Image Storage
- Images are stored in: `backend/public/item_photos/`
- File naming: `{email_sanitized}_{timestamp}.jpg`
- Access URL: `http://localhost:5000/api/v1/public/item_photos/{filename}`

## Installation & Setup

### 1. Flutter Setup

#### Install dependencies:
```bash
cd c:\TECH-HIVE\Main_Flutter_project
flutter pub get
```

#### Build for Android:
```bash
flutter build apk --release
# or
flutter run
```

#### Build for iOS:
```bash
cd .ios
pod install
cd ..
flutter run
```

### 2. Backend Setup

#### Install dependencies:
```bash
cd backend
npm install
```

#### Create public directories:
```bash
mkdir -p public/item_photos
```

#### Start the server:
```bash
npm start
# or for development with auto-reload
npm run dev
```

The backend will run on `http://localhost:5000`

## Features

### Edit Profile Screen
1. **View Profile Picture**
   - Displays current profile picture (if available)
   - Shows default person icon if no picture

2. **Change Picture**
   - Click camera icon to open image picker bottom sheet
   - Choose between Camera or Gallery
   - Camera requires runtime permission request

3. **Image Upload**
   - Images are compressed (max 800x800, 85% quality)
   - Validates file type on backend
   - Displays upload progress
   - Shows success/error messages

4. **Profile Information**
   - Edit name (email is read-only)
   - Save changes button

### Profile Screen
1. **Display Profile Picture**
   - Shows uploaded profile picture in circular container
   - Displays with border and default icon fallback

2. **User Information**
   - Name and email
   - Account status
   - Edit profile button

## API Endpoints

### Upload Profile Picture
```
POST /api/v1/auth/upload-profile-picture
Content-Type: multipart/form-data

Parameters:
- profilePicture: File (image)
- email: string

Response:
{
  "success": true,
  "message": "Profile picture uploaded successfully",
  "imageUrl": "/api/v1/public/item_photos/{filename}"
}
```

## Runtime Permissions Flow

### Android
1. User clicks camera icon
2. App requests CAMERA permission
3. User approves/denies
4. If approved, image picker opens
5. User selects from camera or gallery

### iOS
1. First-time access triggers permission dialog
2. User grants/denies permission
3. Dialog shown only once (unless app is reinstalled)
4. Can manage permissions in Settings > App Permissions

## Troubleshooting

### Camera Permission Not Showing
- **Android**: Check AndroidManifest.xml has all permissions
- **iOS**: Check Info.plist has camera/photo library descriptions
- Clear app cache and reinstall

### Images Not Uploading
1. Check backend is running on port 5000
2. Verify `public/item_photos` directory exists
3. Check backend logs for error messages
4. Ensure file size is under 50MB limit

### Images Not Displaying in Profile
1. Check image URL in database
2. Verify images exist in `backend/public/item_photos`
3. Check CORS settings in backend
4. Check network error in app logs

### Permission Handler Issues
- Ensure permissions are added to manifest/plist
- Request permissions before opening image picker
- Handle permission denial gracefully

## Image Specifications
- **Supported Formats**: JPEG, PNG, GIF, WebP
- **Max Size**: 50MB
- **Compression**: 800x800 resolution, 85% quality
- **Storage**: Backend public folder

## Security Considerations
1. File type validation on backend
2. File size limits (50MB max)
3. File naming includes timestamp for uniqueness
4. CORS protection
5. Runtime permission checks on mobile

## Testing Checklist

- [ ] Flutter app builds without errors
- [ ] Image picker opens on camera icon click
- [ ] Camera permission request appears on first access
- [ ] Can take photo with camera
- [ ] Can select image from gallery
- [ ] Image displays before upload
- [ ] Upload button works and shows progress
- [ ] Image saved to backend public folder
- [ ] Image URL stored in database
- [ ] Profile screen displays uploaded image
- [ ] Image persists after app restart
- [ ] Backend handles file validation
- [ ] Error messages display properly
- [ ] Works on both Android and iOS

## Notes
- Ensure backend is running before testing upload functionality
- Use `http://localhost:5000` for local testing
- Images are stored temporarily; implement cleanup for old images if needed
- Consider implementing image compression library for better performance
