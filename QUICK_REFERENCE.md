# TechHive Quick Reference Guide

## Quick Start (5 Minutes)

### Backend
```bash
cd backend
npm install
# Create .env file with MongoDB URI, JWT_SECRET, PORT
npm run dev
```

### Frontend
1. Update `lib/core/network/api_endpoints.dart` with backend IP
2. Add to `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  setupServiceLocator();
  runApp(const MyApp());
}
```
3. Wrap app with Provider
4. `flutter run`

---

## File Changes Made

### New Files Created ✅
- `lib/core/network/api_client.dart` - HTTP client
- `lib/core/network/api_endpoints.dart` - API endpoints
- `lib/core/network/connectivity_service.dart` - Internet check
- `lib/core/network/local_storage_service.dart` - Token storage
- `lib/core/network/token_manager.dart` - Token management
- `lib/core/config/app_config.dart` - App config
- `lib/core/di/service_locator.dart` - Dependency injection
- `lib/core/error/failures.dart` - Error classes
- `lib/features/auth/data/datasource/remote/auth_remote_datasource.dart`
- `lib/features/auth/data/datasource/remote/auth_remote_datasource_impl.dart`
- `lib/features/auth/data/model/auth_response_model.dart`
- `lib/features/auth/data/model/user_model.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/entities/user_entity.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/domain/usecases/auth_usecases.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `BACKEND_SETUP_GUIDE.md` - Backend setup instructions
- `API_INTEGRATION_README.md` - Detailed API documentation

### Updated Files ✅
- `lib/screens/login_screen.dart` - Added API integration
- `lib/screens/register_screen.dart` - Added API integration
- `pubspec.yaml` - Added dependencies (provider, http, connectivity_plus, get_it)

---

## Folder Structure Created ✅

```
features/
├── auth/
│   ├── data/
│   │   ├── datasource/
│   │   │   ├── local/
│   │   │   └── remote/
│   │   ├── model/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── pages/
│       ├── providers/
│       ├── view_model/
│       └── widgets/
├── dashboard/
│   ├── data/
│   │   ├── datasource/
│   │   │   ├── local/
│   │   │   └── remote/
│   │   ├── model/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── pages/
│       ├── providers/
│       ├── view_model/
│       └── widgets/
├── item/
│   ├── data/
│   │   ├── datasource/
│   │   │   ├── local/
│   │   │   └── remote/
│   │   ├── model/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── pages/
│       ├── providers/
│       ├── view_model/
│       └── widgets/
├── onboarding/
│   ├── data/
│   │   ├── datasource/
│   │   │   ├── local/
│   │   │   └── remote/
│   │   ├── model/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── pages/
│       ├── providers/
│       ├── view_model/
│       └── widgets/
└── splash/
    ├── data/
    │   ├── datasource/
    │   │   ├── local/
    │   │   └── remote/
    │   ├── model/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── pages/
        ├── providers/
        ├── view_model/
        └── widgets/
```

---

## API Endpoints

### Register
```
POST http://your-backend:3000/api/v1/auth/register
Body: {
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phoneNumber": "+1234567890"
}
```

### Login
```
POST http://your-backend:3000/api/v1/auth/login
Body: {
  "email": "john@example.com",
  "password": "password123"
}
```

---

## Dependencies Added to pubspec.yaml

```yaml
provider: ^6.0.0          # State management
http: ^1.1.0             # HTTP requests
connectivity_plus: ^5.0.0 # Internet connectivity
get_it: ^7.6.0          # Service locator
```

---

## How It Works

1. **User enters credentials** in login/register screen
2. **AuthProvider receives input** and calls appropriate usecase
3. **UseCase calls Repository** with the data
4. **Repository calls DataSource** (API)
5. **DataSource makes HTTP request** using ApiClient
6. **Backend processes request** and returns JWT token
7. **Response is parsed** into AuthResponse object
8. **Token is saved** to SharedPreferences
9. **Provider updates state** and notifies UI
10. **UI shows success/error message** and navigates

---

## Common Usage Examples

### In a Screen
```dart
// Access auth provider
final authProvider = context.watch<AuthProvider>();

// Check if loading
if (authProvider.isLoading) {
  // Show loading indicator
}

// Check if authenticated
if (authProvider.isAuthenticated) {
  // User is logged in
}

// Access error message
if (authProvider.errorMessage != null) {
  // Show error
}
```

### Making API Call
```dart
final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password123'
);

if (success) {
  // Navigate to home
} else {
  // Show error
}
```

---

## Backend Credentials Schema

```javascript
// User Model
{
  name: String,           // Required
  email: String,          // Required, unique
  password: String,       // Required, min 6 chars, hashed
  phoneNumber: String,    // Required
  createdAt: Date         // Auto-generated
}
```

---

## Response Format

All API responses follow this format:

```json
{
  "success": true/false,
  "token": "jwt_token_string",
  "data": {
    "id": "user_id",
    "name": "User Name",
    "email": "user@example.com",
    "phoneNumber": "+1234567890"
  },
  "message": "Optional error message"
}
```

---

## Environment Configuration

### Local Development
```env
MONGO_URI=mongodb://localhost:27017/techhive
JWT_SECRET=your_secret_key_32_chars_min
JWT_EXPIRE=7d
PORT=3000
NODE_ENV=development
```

### Production
```env
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/techhive
JWT_SECRET=strong_random_32_char_secret
JWT_EXPIRE=7d
PORT=3000
NODE_ENV=production
```

---

## IP Address Configuration

### For Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

### For Physical Device (Local Network)
```dart
// Find your machine IP: ipconfig (Windows) or ifconfig (Mac/Linux)
static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
```

### For Web
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

### For Production
```dart
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
```

---

## Testing Checklist

- [ ] Backend server running on correct port
- [ ] MongoDB connected successfully
- [ ] Frontend IP address matches backend IP
- [ ] Register new user with unique email
- [ ] Verify user created in MongoDB
- [ ] Login with registered credentials
- [ ] Verify token received and stored
- [ ] Check token in SharedPreferences
- [ ] Logout clears token
- [ ] Try invalid credentials, check error message
- [ ] Test on physical device and emulator

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Connection refused | Ensure backend is running on correct port |
| Email already exists | Use different email for testing |
| Timeout error | Increase timeout or check server response |
| CORS error | Verify CORS enabled in Express |
| Token not saving | Ensure LocalStorageService initialized |
| Widget not updating | Ensure wrapped with Consumer/context.watch |

---

## Next Steps

1. Test login/register functionality
2. Implement password reset
3. Add profile management
4. Implement image upload
5. Add two-factor authentication
6. Implement user roles/permissions
7. Add refresh token mechanism
8. Deploy to production

---

Created: January 16, 2026
Version: 1.0.0
