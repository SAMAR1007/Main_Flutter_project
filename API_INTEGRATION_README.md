# TechHive API Integration Guide

## Overview
This document provides comprehensive information about the TechHive backend and frontend API integration.

## Architecture

### Backend (Node.js + MongoDB)
- **Framework**: Express.js
- **Database**: MongoDB
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcryptjs

### Frontend (Flutter)
- **Architecture**: Clean Architecture (Data → Domain → Presentation)
- **State Management**: Provider
- **Dependency Injection**: GetIt
- **HTTP Client**: http package

## File Organization

### Backend Files
```
backend/
├── models/User.js          - MongoDB User schema
├── controllers/authController.js - Business logic
├── routes/authRoutes.js    - API routes
├── config/config.env       - Environment config
└── server.js               - Express app setup
```

### Frontend Files
```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart              ✅ HTTP request handler
│   │   ├── api_endpoints.dart           ✅ API base URL & endpoints
│   │   ├── connectivity_service.dart    ✅ Internet connection check
│   │   ├── local_storage_service.dart   ✅ Token & user data storage
│   │   └── token_manager.dart           ✅ JWT token management
│   ├── config/
│   │   └── app_config.dart              ✅ App configuration
│   ├── error/
│   │   └── failures.dart                ✅ Error classes
│   └── di/
│       └── service_locator.dart         ✅ Dependency injection setup
├── features/auth/
│   ├── data/
│   │   ├── datasource/
│   │   │   └── remote/
│   │   │       ├── auth_remote_datasource.dart          ✅ Interface
│   │   │       └── auth_remote_datasource_impl.dart     ✅ API calls
│   │   ├── model/
│   │   │   ├── auth_response_model.dart    ✅ Login/Register response
│   │   │   └── user_model.dart             ✅ User data model
│   │   └── repositories/
│   │       └── auth_repository_impl.dart   ✅ Repository implementation
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_entity.dart            ✅ User entity
│   │   ├── repositories/
│   │   │   └── auth_repository.dart        ✅ Repository interface
│   │   └── usecases/
│   │       └── auth_usecases.dart          ✅ Business logic (Register, Login)
│   └── presentation/
│       ├── providers/
│       │   └── auth_provider.dart          ✅ State management (Provider)
│       └── pages/
│           ├── login_screen.dart           ✅ Login UI
│           └── register_screen.dart        ✅ Register UI
```

## Setup Instructions

### 1. Backend Setup

```bash
cd backend
npm install
```

Create `.env` file:
```env
MONGO_URI=mongodb://localhost:27017/techhive
JWT_SECRET=your_secure_secret_key_min_32_chars
JWT_EXPIRE=7d
PORT=3000
NODE_ENV=development
```

Start server:
```bash
npm run dev
```

### 2. Frontend Setup

Update `lib/core/network/api_endpoints.dart`:
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
```

Update `lib/main.dart` to include:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  setupServiceLocator();
  runApp(const MyApp());
}
```

Wrap app with Provider:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
  ],
  child: MaterialApp(...),
)
```

Run app:
```bash
flutter pub get
flutter run
```

## API Endpoints

### Register User
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phoneNumber": "+1234567890"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "id": "64f5a3b8c1234567890abcd",
    "name": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "+1234567890"
  }
}
```

### Login User
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "id": "64f5a3b8c1234567890abcd",
    "name": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "+1234567890"
  }
}
```

## Data Flow

### Registration Flow
```
RegisterScreen
    ↓ (user input)
AuthProvider.register()
    ↓
RegisterUseCase
    ↓
AuthRepositoryImpl
    ↓
AuthRemoteDataSourceImpl
    ↓
ApiClient.post()
    ↓
Backend: POST /api/v1/auth/register
    ↓ (response)
ApiClient (parse JSON)
    ↓
AuthResponse
    ↓
AuthProvider (update state)
    ↓
UI Update (show success/error)
```

### Login Flow
```
LoginScreen
    ↓ (user input)
AuthProvider.login()
    ↓
LoginUseCase
    ↓
AuthRepositoryImpl
    ↓
AuthRemoteDataSourceImpl
    ↓
ApiClient.post()
    ↓
Backend: POST /api/v1/auth/login
    ↓ (response)
ApiClient (parse JSON)
    ↓
AuthResponse
    ↓
LocalStorageService.saveToken()
    ↓
AuthProvider (update state)
    ↓
Navigate to HomeScreen
```

## Key Classes & Methods

### ApiClient
```dart
// Make POST request
final response = await apiClient.post(
  endpoint: ApiEndpoints.login,
  body: {'email': 'user@example.com', 'password': 'pass123'}
);

// Set auth token
apiClient.setToken('jwt_token');

// Clear token
apiClient.clearToken();
```

### AuthProvider
```dart
// Register
bool success = await authProvider.register(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  phoneNumber: '+1234567890'
);

// Login
bool success = await authProvider.login(
  email: 'john@example.com',
  password: 'password123'
);

// Access user data
var user = authProvider.authResponse?.user;
var token = authProvider.authResponse?.token;
var isAuth = authProvider.isAuthenticated;
```

### LocalStorageService
```dart
// Save token
await storageService.saveToken('jwt_token');

// Get token
String? token = storageService.getToken();

// Remove token
await storageService.removeToken();

// Clear all
await storageService.clearAll();
```

## Error Handling

The app handles various error scenarios:

1. **Network Errors**: Shows "No internet connection" message
2. **Server Errors**: Shows server error message from response
3. **Validation Errors**: Shows field-specific error messages
4. **Timeout Errors**: Shows timeout message
5. **Unauthorized**: Automatically logs out user and clears token

Error messages are displayed in red containers on the login/register screens.

## Testing

### Manual Testing with Postman

1. Open Postman
2. Create POST request to `http://localhost:3000/api/v1/auth/register`
3. Add headers: `Content-Type: application/json`
4. Add body:
```json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "test123456",
  "phoneNumber": "+1234567890"
}
```
5. Send and verify response

### Testing from Flutter

1. Run the app
2. Tap "Sign Up" on login screen
3. Fill in all fields
4. Tap "Sign Up" button
5. On success, should redirect to login screen
6. Login with registered credentials
7. On success, should redirect to home screen

## Security Notes

✅ Passwords are hashed with bcryptjs on backend
✅ JWT tokens are stored in SharedPreferences
✅ Rate limiting enabled (100 requests per 15 minutes)
✅ XSS protection enabled
✅ CORS configured
✅ Request timeout: 30 seconds

## Best Practices Implemented

1. **Separation of Concerns**: Data, Domain, Presentation layers
2. **DRY Principle**: Reusable components and utilities
3. **Error Handling**: Comprehensive error management
4. **State Management**: Provider for state management
5. **Dependency Injection**: GetIt for service locator
6. **Constants**: Centralized API endpoints
7. **Security**: Token-based authentication

## Troubleshooting

### Issue: "Connection Refused" Error
**Solution**: Verify backend is running and check IP address in `api_endpoints.dart`

### Issue: "Email already exists" Error
**Solution**: Use a different email address for testing

### Issue: Timeout Error
**Solution**: Check if backend server is responding, increase timeout if needed

### Issue: CORS Error
**Solution**: Ensure CORS is enabled in backend (already configured)

### Issue: Token not saving
**Solution**: Ensure `LocalStorageService().init()` is called in main()

## Next Features to Implement

- [ ] Password reset functionality
- [ ] Email verification
- [ ] Profile update endpoint
- [ ] Profile picture upload
- [ ] Two-factor authentication (2FA)
- [ ] Social media login (Google, Facebook)
- [ ] Refresh token mechanism
- [ ] Rate limiting per user
- [ ] User activity logging

## Support

For issues or questions:
1. Check the error message in the app
2. Review backend logs in terminal
3. Check API response in Postman
4. Review code comments in relevant files

---

Last Updated: January 16, 2026
Version: 1.0.0
