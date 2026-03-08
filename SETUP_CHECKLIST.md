# TechHive Setup Checklist

## ✅ Backend Setup

### MongoDB Setup
- [ ] MongoDB installed locally OR MongoDB Atlas account created
- [ ] MongoDB connection string ready
- [ ] Database name: `techhive`

### Environment Variables
- [ ] Create `backend/.env` file
- [ ] Set `MONGO_URI` with your database connection string
- [ ] Set `JWT_SECRET` (min 32 characters)
- [ ] Set `JWT_EXPIRE` (default: 7d)
- [ ] Set `PORT` (default: 3000)
- [ ] Set `NODE_ENV` (development/production)

### Backend Dependencies
- [ ] `npm install` completed in backend folder
- [ ] All dependencies installed successfully
- [ ] No conflicting versions

### Backend Server
- [ ] Backend server starts without errors
- [ ] MongoDB connection established
- [ ] Server running on http://localhost:3000

### Backend Testing
- [ ] Test `/api/v1/health` endpoint
- [ ] Test Register endpoint with Postman
- [ ] Test Login endpoint with Postman
- [ ] Verify user creation in MongoDB
- [ ] Verify JWT token generation

---

## ✅ Frontend Setup

### Flutter Project
- [ ] Flutter SDK installed (v3.0+)
- [ ] Android Studio / Xcode installed
- [ ] Emulator or physical device available

### Dependencies Installation
- [ ] `flutter pub get` completed
- [ ] All packages installed successfully
- [ ] No dependency conflicts
- [ ] `pubspec.yaml` includes all required packages:
  - [ ] provider: ^6.0.0
  - [ ] http: ^1.1.0
  - [ ] connectivity_plus: ^5.0.0
  - [ ] get_it: ^7.6.0

### Configuration Files
- [ ] `lib/core/network/api_endpoints.dart` created
- [ ] `baseUrl` set to your backend IP/URL
- [ ] `lib/core/config/app_config.dart` created
- [ ] `lib/core/di/service_locator.dart` created

### Network Layer Files
- [ ] `lib/core/network/api_client.dart` ✅
- [ ] `lib/core/network/connectivity_service.dart` ✅
- [ ] `lib/core/network/local_storage_service.dart` ✅
- [ ] `lib/core/network/token_manager.dart` ✅

### Error Handling
- [ ] `lib/core/error/failures.dart` ✅

### Auth Feature - Data Layer
- [ ] `lib/features/auth/data/datasource/remote/auth_remote_datasource.dart` ✅
- [ ] `lib/features/auth/data/datasource/remote/auth_remote_datasource_impl.dart` ✅
- [ ] `lib/features/auth/data/model/auth_response_model.dart` ✅
- [ ] `lib/features/auth/data/model/user_model.dart` ✅
- [ ] `lib/features/auth/data/repositories/auth_repository_impl.dart` ✅

### Auth Feature - Domain Layer
- [ ] `lib/features/auth/domain/entities/user_entity.dart` ✅
- [ ] `lib/features/auth/domain/repositories/auth_repository.dart` ✅
- [ ] `lib/features/auth/domain/usecases/auth_usecases.dart` ✅

### Auth Feature - Presentation Layer
- [ ] `lib/features/auth/presentation/providers/auth_provider.dart` ✅
- [ ] `lib/screens/login_screen.dart` updated with API ✅
- [ ] `lib/screens/register_screen.dart` updated with API ✅

### Main Application Setup
- [ ] Update `lib/main.dart` with:
  - [ ] `LocalStorageService().init()` in main()
  - [ ] `setupServiceLocator()` called
  - [ ] `MultiProvider` wrapping the app
  - [ ] `AuthProvider` added to providers list

### UI Integration
- [ ] Login screen displays error messages
- [ ] Register screen displays error messages
- [ ] Loading states shown during API calls
- [ ] Success/error SnackBars displayed

---

## ✅ Testing

### Backend Testing (Postman/Insomnia)
- [ ] Test Register endpoint with valid data
  - [ ] Check response has `success: true`
  - [ ] Check `token` is returned
  - [ ] Check `data` contains user info
- [ ] Test Register with duplicate email
  - [ ] Check error message
- [ ] Test Register with missing fields
  - [ ] Check validation error
- [ ] Test Login with correct credentials
  - [ ] Check token is returned
- [ ] Test Login with wrong password
  - [ ] Check error message
- [ ] Test Login with non-existent email
  - [ ] Check error message

### Frontend Testing (Flutter App)
- [ ] App launches without errors
- [ ] Navigate to Register screen
  - [ ] [ ] Enter valid details
  - [ ] [ ] Click Sign Up
  - [ ] [ ] Verify success message
  - [ ] [ ] Navigate to Login screen
- [ ] Login with registered credentials
  - [ ] [ ] Enter email and password
  - [ ] [ ] Click Login
  - [ ] [ ] Verify success message
  - [ ] [ ] Navigate to Home screen
- [ ] Test error scenarios
  - [ ] [ ] Invalid email format
  - [ ] [ ] Empty fields
  - [ ] [ ] Mismatched passwords (register)
  - [ ] [ ] Wrong credentials (login)
- [ ] Test on Android Emulator
  - [ ] [ ] API calls work
  - [ ] [ ] Network connectivity checked
- [ ] Test on physical device
  - [ ] [ ] Check IP address is accessible
  - [ ] [ ] API calls work
- [ ] Test without internet
  - [ ] [ ] Error message displayed

---

## ✅ Folder Structure

### Features Auth Folder Structure
```
lib/features/auth/
├── data/
│   ├── datasource/
│   │   ├── local/ ✅
│   │   └── remote/ ✅
│   ├── model/ ✅
│   └── repositories/ ✅
├── domain/
│   ├── entities/ ✅
│   ├── repositories/ ✅
│   └── usecases/ ✅
└── presentation/
    ├── pages/ ✅
    ├── providers/ ✅
    ├── view_model/ ✅
    └── widgets/ ✅
```

### Other Features (Ready for future implementation)
- [ ] dashboard feature folders
- [ ] item feature folders
- [ ] onboarding feature folders
- [ ] splash feature folders

---

## ✅ Documentation

- [ ] `BACKEND_SETUP_GUIDE.md` created ✅
- [ ] `API_INTEGRATION_README.md` created ✅
- [ ] `QUICK_REFERENCE.md` created ✅
- [ ] This checklist created ✅

---

## ⚠️ Important Notes

### Before Running

1. **Update Backend IP in Frontend**
   - Edit `lib/core/network/api_endpoints.dart`
   - Find your machine's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Update `baseUrl` accordingly

2. **MongoDB Setup**
   - Ensure MongoDB is running
   - Test connection with MongoDB Compass (optional)

3. **Backend Dependencies**
   - Run `npm install` in backend folder
   - No need to install globally

4. **Flutter Dependencies**
   - Run `flutter pub get`
   - Might take some time on first run

5. **Emulator Setup**
   - Use `10.0.2.2:3000` for Android Emulator
   - Use actual IP for physical devices

---

## 🔧 Troubleshooting Tips

### Backend Won't Start
- [ ] Check MongoDB is running
- [ ] Check port 3000 is not in use
- [ ] Verify .env file exists and has correct values
- [ ] Run `npm install` again

### Frontend API Calls Fail
- [ ] Verify backend is running
- [ ] Check IP address in `api_endpoints.dart`
- [ ] Check both devices are on same network
- [ ] Check Android target SDK is 28+

### Database Errors
- [ ] Verify MongoDB connection string
- [ ] Check MongoDB is accessible
- [ ] For MongoDB Atlas: Verify IP whitelist
- [ ] Check database and collection names

### CORS Issues
- [ ] Cors is already enabled in backend
- [ ] If issues persist, check browser console

### Token Not Saving
- [ ] Ensure `LocalStorageService().init()` called in main()
- [ ] Check SharedPreferences package installed
- [ ] Verify token is returned from backend

---

## 📋 Final Verification

Before considering setup complete:

- [ ] Run `flutter run` successfully
- [ ] See app running on emulator/device
- [ ] Able to register new user
- [ ] Able to login with registered user
- [ ] Token saved and retrieved
- [ ] Error messages display correctly
- [ ] No console errors or warnings
- [ ] Database has registered user
- [ ] API endpoints respond correctly

---

## 🚀 Next Steps After Setup

1. Test all functionality thoroughly
2. Create integration tests
3. Set up CI/CD pipeline
4. Deploy backend to server
5. Update production API URL
6. Implement additional features
7. Add push notifications
8. Implement analytics
9. Set up error reporting
10. Plan for scalability

---

## 📞 Support Resources

- Flutter Docs: https://flutter.dev/docs
- Provider Docs: https://pub.dev/packages/provider
- Express Docs: https://expressjs.com
- MongoDB Docs: https://docs.mongodb.com
- JWT Guide: https://jwt.io

---

**Setup Date**: _______________
**Setup By**: _______________
**Status**: [ ] Complete [ ] In Progress [ ] Pending

---

Version: 1.0.0
Created: January 16, 2026
