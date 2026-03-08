# TechHive Backend & Frontend Setup Guide

## Backend Setup

### Prerequisites
- Node.js (v14 or higher)
- MongoDB (local or MongoDB Atlas)
- npm or yarn

### Backend Installation Steps

1. Navigate to backend folder:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env` file in backend folder with the following content:
   ```env
   MONGO_URI=mongodb://localhost:27017/techhive
   JWT_SECRET=your_jwt_secret_key_here
   JWT_EXPIRE=7d
   PORT=3000
   NODE_ENV=development
   ```

   **For MongoDB Atlas:**
   ```env
   MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/techhive
   ```

4. Start MongoDB (if using local):
   ```bash
   mongod
   ```

5. Start the backend server:
   ```bash
   npm run dev
   ```

   Server will run on `http://localhost:3000`

### Backend API Endpoints

#### Register
- **URL**: `POST /api/v1/auth/register`
- **Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "phoneNumber": "+1234567890"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "token": "jwt_token_here",
    "data": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "phoneNumber": "+1234567890"
    }
  }
  ```

#### Login
- **URL**: `POST /api/v1/auth/login`
- **Body**:
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- **Response**: Same as Register

---

## Flutter Frontend Setup

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Android Studio / Xcode (for emulator)
- A running backend server

### Frontend Installation Steps

1. Navigate to project folder:
   ```bash
   cd Main_Flutter_project
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. **Update API Endpoint** in `lib/core/network/api_endpoints.dart`:
   
   Replace the `baseUrl` with your backend IP/URL:
   ```dart
   static const String baseUrl = 'http://YOUR_BACKEND_IP:3000/api/v1';
   ```

   Examples:
   - Local Network: `http://192.168.1.100:3000/api/v1`
   - Android Emulator: `http://10.0.2.2:3000/api/v1`
   - Physical Device: Use your machine's IP on same network
   - Production: Your actual server URL

4. Initialize LocalStorage in `main.dart`:
   ```dart
   import 'core/network/local_storage_service.dart';
   import 'core/di/service_locator.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await LocalStorageService().init();
     setupServiceLocator();
     runApp(const MyApp());
   }
   ```

5. Wrap your app with Provider in `main.dart`:
   ```dart
   import 'package:provider/provider.dart';

   return MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
     ],
     child: MaterialApp(...),
   );
   ```

6. Run the app:
   ```bash
   flutter run
   ```

---

## Project Structure

### Backend (Node.js)
```
backend/
├── models/
│   └── User.js          # User schema with password hashing
├── controllers/
│   └── authController.js # Register & Login logic
├── routes/
│   └── authRoutes.js    # Auth endpoints
├── config/
│   └── config.env       # Environment variables
└── server.js            # Main server file
```

### Frontend (Flutter)
```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart          # HTTP client
│   │   ├── api_endpoints.dart       # API endpoints
│   │   ├── connectivity_service.dart # Connectivity check
│   │   └── local_storage_service.dart # Token storage
│   ├── config/
│   │   └── app_config.dart          # App configuration
│   └── di/
│       └── service_locator.dart     # Dependency injection
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasource/
│       │   │   └── remote/
│       │   │       ├── auth_remote_datasource.dart
│       │   │       └── auth_remote_datasource_impl.dart
│       │   ├── repositories/
│       │   │   └── auth_repository_impl.dart
│       │   └── model/
│       │       └── auth_response_model.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user_entity.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       └── auth_usecases.dart
│       └── presentation/
│           ├── providers/
│           │   └── auth_provider.dart
│           ├── pages/
│           └── widgets/
├── screens/
│   ├── login_screen.dart     # Login UI with API integration
│   └── register_screen.dart  # Register UI with API integration
└── main.dart                 # App entry point
```

---

## Key Features Implemented

### Backend Features
✅ User Registration with email & phone
✅ User Login with JWT authentication
✅ Password hashing with bcryptjs
✅ Email uniqueness validation
✅ Input validation
✅ Error handling
✅ Security middleware (helmet, XSS protection, rate limiting)

### Frontend Features
✅ Login Screen with API integration
✅ Register Screen with API integration
✅ API client with error handling
✅ Connectivity checking
✅ Local token storage
✅ Clean Architecture (MVVM pattern)
✅ Dependency Injection with GetIt
✅ State management with Provider

---

## Testing the Integration

### Using Postman/Insomnia

1. **Register User**:
   ```
   POST http://localhost:3000/api/v1/auth/register
   Headers: Content-Type: application/json
   Body:
   {
     "name": "Test User",
     "email": "test@example.com",
     "password": "password123",
     "phoneNumber": "+1234567890"
   }
   ```

2. **Login User**:
   ```
   POST http://localhost:3000/api/v1/auth/login
   Headers: Content-Type: application/json
   Body:
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```

### From Flutter App
- Run the app and navigate to Register screen
- Fill in all fields and tap "Sign Up"
- After successful registration, login with credentials
- Token will be saved locally and used for future API calls

---

## Troubleshooting

### Connection Issues
- **"No internet connection"**: Check if backend is running
- **"Connection refused"**: Verify backend IP/port in `api_endpoints.dart`
- **Timeout errors**: Check if backend server is responding

### Backend Issues
- **MongoDB connection error**: Verify MongoDB is running and connection string is correct
- **Port already in use**: Kill process on port 3000 or change PORT in .env

### Frontend Issues
- **Dependency issues**: Run `flutter pub get` and `flutter pub upgrade`
- **Build errors**: Run `flutter clean` then `flutter pub get`

---

## Next Steps

1. Implement password reset functionality
2. Add user profile management
3. Implement refresh token mechanism
4. Add request/response interceptors
5. Implement user profile picture upload
6. Add two-factor authentication (2FA)
7. Implement role-based access control

---

## Security Notes

- Never hardcode API keys or passwords
- Always use HTTPS in production
- Implement token refresh mechanism
- Add request rate limiting
- Validate all inputs on both frontend and backend
- Keep sensitive data encrypted at rest

---

For more information, refer to the individual file comments and documentation.
