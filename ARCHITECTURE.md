# TechHive Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           PRESENTATION LAYER (UI)                        │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                           │   │
│  │  LoginScreen    RegisterScreen    HomeScreen            │   │
│  │       │              │                  │                │   │
│  │       └──────────────┴──────────────────┘                │   │
│  │                      │                                    │   │
│  │                  Provider (State)                        │   │
│  │             AuthProvider                                │   │
│  │       (isLoading, errorMessage, user)                   │   │
│  │                      │                                    │   │
│  └──────────────────────┼────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────┼────────────────────────────────────┐   │
│  │       DOMAIN LAYER (Business Logic)                      │   │
│  ├──────────────────────┼────────────────────────────────────┤   │
│  │                      ▼                                    │   │
│  │         ┌────────────────────────┐                       │   │
│  │         │  Use Cases             │                       │   │
│  │         ├────────────────────────┤                       │   │
│  │         │ RegisterUseCase        │                       │   │
│  │         │ LoginUseCase           │                       │   │
│  │         └────────────────────────┘                       │   │
│  │                      │                                    │   │
│  │         ┌────────────▼────────────┐                      │   │
│  │         │  Repository Interface   │                      │   │
│  │         └────────────┬────────────┘                      │   │
│  │                      │                                    │   │
│  └──────────────────────┼────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────┼────────────────────────────────────┐   │
│  │         DATA LAYER (Data Management)                     │   │
│  ├──────────────────────┼────────────────────────────────────┤   │
│  │                      ▼                                    │   │
│  │    ┌─────────────────────────────┐                       │   │
│  │    │  Repository Implementation  │                       │   │
│  │    └─────────────────────────────┘                       │   │
│  │              │          │                                │   │
│  │    ┌─────────▼──┐  ┌───▼──────────┐                     │   │
│  │    │  Remote    │  │  Local       │                     │   │
│  │    │  DataSource│  │  DataSource  │                     │   │
│  │    └─────────┬──┘  └───┬──────────┘                     │   │
│  │              │         │                                │   │
│  │              └─────────┤                                │   │
│  │                        │                                │   │
│  │         ┌──────────────▼──────────────┐                │   │
│  │         │    LocalStorageService      │                │   │
│  │         │  (SharedPreferences)        │                │   │
│  │         └─────────────────────────────┘                │   │
│  │                                                        │   │
│  └────────────────────────────────────────────────────────┘   │
│                         │                                      │
│  ┌──────────────────────┼──────────────────────────────────┐   │
│  │      NETWORK LAYER (HTTP & Connectivity)               │   │
│  ├──────────────────────┼──────────────────────────────────┤   │
│  │                      ▼                                  │   │
│  │         ┌──────────────────────┐                       │   │
│  │         │   APIClient          │                       │   │
│  │         │  (http requests)     │                       │   │
│  │         └──────────────────────┘                       │   │
│  │                      │                                  │   │
│  │    ┌──────────────────┼──────────────────┐             │   │
│  │    │                  │                  │             │   │
│  │    ▼                  ▼                  ▼             │   │
│  │ POST /register   POST /login   GET /health           │   │
│  │                                                       │   │
│  │      ConnectivityService    TokenManager             │   │
│  │                                                       │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                                  │
└──────────────────┬───────────────────────────────────────────────┘
                   │ HTTPS/REST API
                   │
┌──────────────────▼───────────────────────────────────────────────┐
│                  BACKEND SERVER (Node.js)                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │            EXPRESS SERVER                                  │  │
│  ├────────────────────────────────────────────────────────────┤  │
│  │                                                             │  │
│  │  Route: POST /api/v1/auth/register                         │  │
│  │  Route: POST /api/v1/auth/login                           │  │
│  │  Route: GET  /api/v1/health                               │  │
│  │                                                             │  │
│  └─────────────────────────────┬──────────────────────────────┘  │
│                                │                                  │
│  ┌─────────────────────────────┼──────────────────────────────┐  │
│  │     MIDDLEWARE & SECURITY                                 │  │
│  ├─────────────────────────────┼──────────────────────────────┤  │
│  │                             │                              │  │
│  │  Authentication (JWT)       │  Rate Limiting               │  │
│  │  CORS                       │  Helmet (Security)           │  │
│  │  XSS Protection             │  Body Parser                 │  │
│  │                                                            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │     CONTROLLER LAYER                                        │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │                                                              │ │
│  │  @register                    @login                        │ │
│  │  - Validate input            - Check credentials           │ │
│  │  - Hash password             - Generate JWT               │ │
│  │  - Create user              - Return user data            │ │
│  │  - Generate JWT             - Handle errors               │ │
│  │                                                              │ │
│  └──────────────────────────┬───────────────────────────────────┘ │
│                             │                                      │
│  ┌──────────────────────────┼───────────────────────────────────┐ │
│  │     MODEL LAYER                                             │ │
│  ├──────────────────────────┼───────────────────────────────────┤ │
│  │                          ▼                                   │ │
│  │     ┌─────────────────────────────────┐                    │ │
│  │     │  User Schema                    │                    │ │
│  │     ├─────────────────────────────────┤                    │ │
│  │     │ - name (String, required)       │                    │ │
│  │     │ - email (String, unique)        │                    │ │
│  │     │ - password (String, hashed)     │                    │ │
│  │     │ - phoneNumber (String)          │                    │ │
│  │     │ - createdAt (Date)              │                    │ │
│  │     └─────────────────────────────────┘                    │ │
│  │                                                              │ │
│  └──────────────────────────┬───────────────────────────────────┘ │
│                             │                                      │
│  ┌──────────────────────────▼───────────────────────────────────┐ │
│  │     DATABASE LAYER (MongoDB)                                │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagrams

### Registration Flow

```
┌──────────────────────────────────────────────────────────────┐
│                  USER ENTERS DATA                             │
│          (name, email, password, phoneNumber)                 │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   ValidateInput()      │
        │  - Check all fields    │
        │  - Check email format  │
        │  - Check password len  │
        └────────────────┬───────┘
                         │
           ┌─────────────┴─────────────┐
           │ Valid ✓                   │ Invalid ✗
           ▼                           ▼
      ┌────────────┐           ┌──────────────┐
      │ Show Modal │           │ Show Error   │
      │ - Loading  │           │ Message      │
      └────────┬───┘           └──────────────┘
               │
               ▼
    ┌───────────────────────┐
    │  AuthProvider.register│
    │  (name, email, pwd...) │
    └──────────┬────────────┘
               │
               ▼
    ┌───────────────────────┐
    │  RegisterUseCase()    │
    └──────────┬────────────┘
               │
               ▼
    ┌────────────────────────┐
    │  AuthRepository.       │
    │  register()            │
    └──────────┬─────────────┘
               │
               ▼
    ┌────────────────────────┐
    │  AuthRemoteDataSource  │
    │  .register()           │
    └──────────┬─────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │  APIClient.post()            │
    │  endpoint: /auth/register    │
    │  body: {...}                 │
    └──────────┬───────────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │  BACKEND                     │
    │  POST /api/v1/auth/register  │
    └──────────┬───────────────────┘
               │
    ┌──────────┴──────────┐
    │ Valid Data ✓         │ Invalid Data ✗
    ▼                      ▼
┌──────────────┐     ┌──────────────┐
│ Hash Password│     │ Return Error │
│ Create User  │     │ Message      │
│ Generate JWT │     │ (400 Status) │
└──────┬───────┘     └──────────────┘
       │
       ▼
┌──────────────────────┐
│ Return JSON Response │
│ {                    │
│   success: true,     │
│   token: "...",      │
│   data: {...}        │
│ }                    │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────┐
│  AuthRemoteDataSourceImpl │
│  .register() returns     │
│  AuthResponse            │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────┐
│  AuthRepository      │
│  returns AuthResponse│
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  RegisterUseCase     │
│  returns AuthResponse│
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────┐
│  AuthProvider updates    │
│  - authResponse = resp   │
│  - isLoading = false     │
│  - errorMessage = null   │
│  - notifyListeners()     │
└──────┬───────────────────┘
       │
       ▼
┌────────────────────┐
│  UI Rebuilds       │
│  Shows Success Msg │
│  Navigate to Login │
└────────────────────┘
```

---

## Class Relationships

```
Provider (State Management)
        │
        ├── AuthProvider
        │   └── Watches: isLoading, errorMessage, authResponse
        │
        └── Notifies: UI widgets on state change


Repository Pattern
        │
        ├── AuthRepository (Interface)
        │   ├── register()
        │   └── login()
        │
        └── AuthRepositoryImpl (Implementation)
            └── Uses: AuthRemoteDataSource


Use Case (Business Logic)
        │
        ├── RegisterUseCase
        │   └── Uses: AuthRepository
        │
        └── LoginUseCase
            └── Uses: AuthRepository


Data Sources
        │
        └── AuthRemoteDataSource (Interface)
            ├── register()
            ├── login()
            │
            └── AuthRemoteDataSourceImpl (Implementation)
                └── Uses: ApiClient


Network Layer
        │
        ├── ApiClient
        │   ├── post()
        │   └── get()
        │
        ├── ApiEndpoints
        │   ├── register
        │   └── login
        │
        ├── LocalStorageService
        │   ├── saveToken()
        │   ├── getToken()
        │   └── removeToken()
        │
        ├── ConnectivityService
        │   └── hasInternetConnection()
        │
        └── TokenManager
            ├── getToken()
            ├── saveToken()
            └── isTokenExpired()
```

---

## Request/Response Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT (Flutter App)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Screen Input ──> Provider ──> UseCase ──> Repository           │
│                                                   │              │
└───────────────────────────────────────────────────┼──────────────┘
                                                    │
                                    ┌───────────────┘
                                    │
                                    ▼
                            ┌──────────────────┐
                            │   HTTP Request   │
                            │   POST /register │
                            │   with token     │
                            └────────┬─────────┘
                                    │
                      INTERNET / NETWORK LAYER
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SERVER (Node.js Backend)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Route ──> Middleware ──> Controller ──> Model ──> Database     │
│ /register   - CORS        - Validate     User      MongoDB       │
│             - Auth        - Hash pwd     Schema    Collections   │
│             - Validate    - Create User            user          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                            ┌──────────────────┐
                            │   HTTP Response  │
                            │   200/201 OK     │
                            │   {              │
                            │     success: ..  │
                            │     token: ...   │
                            │     data: {...}  │
                            │   }              │
                            └────────┬─────────┘
                                    │
                      INTERNET / NETWORK LAYER
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT (Flutter App)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  DataSource <─ Parse JSON <─ APIClient <─ HTTP Response         │
│      │                                                          │
│      ▼                                                          │
│  AuthResponse                                                   │
│      │                                                          │
│      ▼                                                          │
│  Repository returns AuthResponse                               │
│      │                                                          │
│      ▼                                                          │
│  UseCase returns AuthResponse                                  │
│      │                                                          │
│      ▼                                                          │
│  Provider updates state + notifyListeners()                    │
│      │                                                          │
│      ▼                                                          │
│  UI Rebuilds ──> Shows Success/Error                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Management Flow

```
Provider Pattern with ChangeNotifier

┌──────────────────────────────────┐
│     AuthProvider (Notifier)      │
├──────────────────────────────────┤
│                                  │
│  Properties:                     │
│  ├─ isLoading: bool             │
│  ├─ errorMessage: String?       │
│  ├─ authResponse: AuthResponse? │
│  └─ isAuthenticated: bool       │
│                                  │
│  Methods:                        │
│  ├─ register(...)               │
│  ├─ login(...)                  │
│  ├─ clearError()                │
│  ├─ logout()                    │
│  └─ notifyListeners()           │
│                                  │
└──────────┬───────────────────────┘
           │
           │ notifyListeners() when state changes
           │
           ▼
┌──────────────────────────────────────┐
│      Widgets Listening (Watchers)    │
├──────────────────────────────────────┤
│                                      │
│  context.watch<AuthProvider>()       │
│       or                             │
│  Consumer<AuthProvider>(...)         │
│                                      │
│  Rebuild when:                       │
│  - isLoading changes                │
│  - errorMessage changes             │
│  - authResponse changes             │
│                                      │
└──────────────────────────────────────┘
```

---

## Error Handling Flow

```
┌─────────────────────────────┐
│     API Call                │
│     (HTTP Request)          │
└──────────────┬──────────────┘
               │
     ┌─────────┴────────┐
     │                  │
     ▼                  ▼
 Success           Error
     │                  │
     ├─ 200/201         ├─ Network Error
     │   Parse JSON     │   ▼
     │   Create         │   "No internet connection"
     │   Response       │
     │                  │
     │                  ├─ 400 Bad Request
     │                  │   ▼
     │                  │   "Invalid input"
     │                  │   "Email already exists"
     │                  │
     │                  ├─ 401 Unauthorized
     │                  │   ▼
     │                  │   "Invalid credentials"
     │                  │   Clear token
     │                  │
     │                  ├─ 500 Server Error
     │                  │   ▼
     │                  │   "Server error"
     │                  │
     │                  └─ Timeout
     │                      ▼
     │                      "Request timeout"
     │
     └────────┬─────────────┘
              │
              ▼
      AuthProvider
      errorMessage = message
      notifyListeners()
              │
              ▼
         UI Updates
         Shows error in
         red container
```

---

## Security Flow

```
┌────────────────────────────────────┐
│     Frontend (Flutter)             │
├────────────────────────────────────┤
│                                    │
│  1. User Input                    │
│     └─> Validate (min length)     │
│                                    │
│  2. Send Password as Plain Text   │
│     (Only over HTTPS in prod)      │
│                                    │
│  3. Receive JWT Token             │
│     └─> Save to SharedPreferences │
│                                    │
│  4. Include Token in Requests     │
│     Authorization: Bearer <token> │
│                                    │
└─────────────────────────────────────┘
                 │
            HTTPS/TLS
                 │
         ┌───────▼────────┐
         │  HTTPS Request │
         │  (Encrypted)   │
         └───────┬────────┘
                 │
         ┌───────▼──────────────────────┐
         │  Backend (Node.js)           │
         ├──────────────────────────────┤
         │                              │
         │  1. Receive Password         │
         │     (from HTTPS stream)      │
         │                              │
         │  2. Hash with bcryptjs       │
         │     rounds: 10               │
         │     └─> Never store plain    │
         │                              │
         │  3. Compare Passwords        │
         │     bcrypt.compare()         │
         │     └─> Timing-safe          │
         │                              │
         │  4. Generate JWT Token       │
         │     ├─ Header (alg, type)   │
         │     ├─ Payload (user id)    │
         │     ├─ Signature (secret)   │
         │     └─ Expires in 7 days    │
         │                              │
         │  5. Security Middleware      │
         │     ├─ Helmet                │
         │     ├─ CORS                  │
         │     ├─ XSS Protection        │
         │     └─ Rate Limiting         │
         │                              │
         └──────────────────────────────┘
```

---

## Dependency Injection (GetIt)

```
┌────────────────────────────────────┐
│     Service Locator (GetIt)        │
├────────────────────────────────────┤
│                                    │
│  Singleton Instances:             │
│                                    │
│  ├─ ApiClient                      │
│  ├─ ConnectivityService            │
│  ├─ LocalStorageService            │
│  ├─ AuthRemoteDataSource           │
│  ├─ AuthRepository                 │
│  ├─ RegisterUseCase                │
│  ├─ LoginUseCase                   │
│  └─ AuthProvider                   │
│                                    │
│  Registered in: setupServiceLocator│
│  Called in: main()                 │
│                                    │
│  Usage:                            │
│  getIt<AuthProvider>()             │
│  getIt<ApiClient>()                │
│  getIt<LocalStorageService>()      │
│                                    │
└────────────────────────────────────┘
```

---

## Database Schema (MongoDB)

```
Database: techhive
Collection: users

Document Structure:
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "John Doe",
  "email": "john@example.com",    [UNIQUE INDEX]
  "password": "$2a$10$...",       [HASHED]
  "phoneNumber": "+1234567890",
  "createdAt": ISODate("2024-01-16T10:00:00Z")
}

Indexes:
- _id (Primary Key)
- email (Unique)
- createdAt
```

---

## Complete Request Example

```
1. User Interaction
   LoginScreen
   ├─ Enter email: john@example.com
   ├─ Enter password: mypassword123
   └─ Tap "Login" button

2. Provider calls
   AuthProvider.login(
     email: "john@example.com",
     password: "mypassword123"
   )

3. Business Logic
   LoginUseCase(repository)
   └─ repository.login(email, password)

4. Data Layer
   AuthRepositoryImpl
   └─ remoteDataSource.login(email, password)

5. Network Call
   AuthRemoteDataSourceImpl
   └─ apiClient.post(
        endpoint: "http://192.168.1.100:3000/api/v1/auth/login",
        body: {
          "email": "john@example.com",
          "password": "mypassword123"
        }
      )

6. Backend Processing
   Server receives POST request
   ├─ CORS middleware: ✓ Allow
   ├─ XSS middleware: ✓ Clean
   ├─ Rate limiter: ✓ Allow
   ├─ Controller:
   │  ├─ Find user by email
   │  ├─ Compare password with bcrypt
   │  ├─ If match: Generate JWT token
   │  └─ Return response
   └─ Response: {
       "success": true,
       "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
       "data": {
         "id": "507f1f77bcf86cd799439011",
         "name": "John Doe",
         "email": "john@example.com",
         "phoneNumber": "+1234567890"
       }
     }

7. Response Processing
   ApiClient parses JSON
   ├─ Status: 200 ✓
   ├─ Body: {...}
   └─ Returns parsed Map

8. Domain Layer
   AuthRemoteDataSourceImpl
   └─ AuthResponse.fromJson(parsedMap)

9. Repository
   AuthRepositoryImpl
   └─ Returns AuthResponse

10. Use Case
    LoginUseCase
    └─ Returns AuthResponse

11. Provider Update
    AuthProvider
    ├─ Set: authResponse = response
    ├─ Set: isLoading = false
    ├─ Set: errorMessage = null
    ├─ Save token: LocalStorageService.saveToken(token)
    └─ notifyListeners()

12. UI Update
    Consumer<AuthProvider>
    ├─ isLoading: false
    ├─ authResponse: {...}
    ├─ errorMessage: null
    ├─ isAuthenticated: true
    └─ Build UI: Navigate to HomeScreen

13. Token Storage
    SharedPreferences
    └─ Save: "auth_token": "eyJhbGciOi..."

14. Future Requests
    ApiClient.setToken(token)
    ├─ Include in header: "Authorization: Bearer token"
    └─ Use for all authenticated endpoints
```

---

This architecture ensures:
✅ Separation of Concerns
✅ Testability
✅ Maintainability
✅ Scalability
✅ Security
✅ User-friendly Error Handling

