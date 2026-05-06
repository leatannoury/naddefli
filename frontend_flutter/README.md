# Naddefli Flutter Frontend

Professional Flutter mobile application for booking cleaning services with modern UI/UX design and state management.

## 📱 Overview

Naddefli is a feature-rich cleaning service booking app built with Flutter, providing a seamless user experience for customers to book cleaners, track bookings, and rate services.

## 🏗️ Project Structure

```
frontend_flutter/
├── lib/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   └── booking_screen.dart
│   ├── widgets/
│   ├── models/
│   │   ├── user.dart
│   │   ├── service.dart
│   │   ├── booking.dart
│   │   └── response_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── service_provider.dart
│   │   └── booking_provider.dart
│   ├── services/
│   │   ├── http_service.dart
│   │   ├── auth_service.dart
│   │   ├── service_api_service.dart
│   │   └── booking_service.dart
│   ├── utils/
│   │   ├── app_styles.dart
│   │   ├── constants.dart
│   │   └── storage_service.dart
│   ├── app.dart
│   └── main.dart
├── assets/
│   └── images/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **Design**: Material Design 3
- **Architecture**: Clean Architecture with separation of concerns

## 📦 Dependencies

```yaml
provider: ^6.0.0        # State management
dio: ^5.3.1             # HTTP requests
shared_preferences: ^2.2.2  # Local storage
google_fonts: ^6.1.0    # Custom fonts
shimmer: ^3.0.0         # Loading animation
intl: ^0.19.0          # Internationalization
get_it: ^7.6.0         # Service locator
```

## 🚀 Installation

### Prerequisites
- Flutter 3.0+ installed
- Dart SDK 3.0+
- Android Studio or Xcode
- Emulator or physical device

### Setup Steps

1. **Navigate to project**
   ```bash
   cd Naddefli/frontend_flutter
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK (Android)**
   ```bash
   flutter build apk --release
   ```

5. **Build IPA (iOS)**
   ```bash
   flutter build ios --release
   ```

## 📱 Screens

### 1. Splash Screen
- App logo and branding
- Auto-redirects based on auth status
- Smooth loading animation

### 2. Onboarding Screen
- 3-page welcome flow
- Feature introduction
- Navigation to login

### 3. Login Screen
- Email and password input
- Error messages
- Link to registration
- JWT token handling

### 4. Register Screen
- Full name, email, phone, password
- Role selection (customer/cleaner)
- Password confirmation
- Form validation

### 5. Home Screen
- Welcome message with user name
- Search bar
- Popular services grid
- Bookings list
- Profile section
- Bottom navigation (3 tabs)

### 6. Booking Screen
- Service summary
- Date picker
- Time picker
- Address and city input
- Special notes
- Price calculation
- Confirm booking button

## 🎨 Design

### Color Scheme
- **Primary**: #5B9BFF (Blue)
- **Secondary**: #6C63FF (Purple)
- **Success**: #00D4AA (Green)
- **Warning**: #FFB800 (Orange)
- **Error**: #FF6B6B (Red)
- **Background**: #F5F5F5 (Light Gray)

### Typography
- Font Family: Poppins (or system default)
- Heading Large: 28px Bold
- Heading Medium: 22px Bold
- Heading Small: 18px Semi-bold
- Body: 14-16px Regular

### Components
- Rounded cards (8-16px radius)
- Clean minimalist design
- Material Design 3 components
- Responsive layout
- Smooth animations

## 🔐 Authentication Flow

```
1. User registration/login
2. Credentials sent to backend
3. JWT token received
4. Token stored in SharedPreferences
5. Token included in all API requests
6. Auto-logout on token expiry
7. Redirect to login on unauthorized
```

## 🌐 API Integration

### Service Layer
```dart
// HTTP Service - Handles all API calls
class HttpService {
  - Dio configuration
  - Auth interceptor
  - Error handling
  - Request/response logging
}

// Auth Service - Authentication APIs
class AuthService {
  - register()
  - login()
  - getProfile()
  - updateProfile()
  - logout()
}

// Service API Service - Services APIs
class ServiceApiService {
  - getServices()
  - getServiceById()
}

// Booking Service - Booking APIs
class BookingService {
  - createBooking()
  - getMyBookings()
  - getBookingById()
  - cancelBooking()
}
```

## 🔄 State Management (Provider)

### AuthProvider
Manages:
- User authentication
- Token storage
- User profile data
- Login/register/logout

### ServiceProvider
Manages:
- Services list
- Selected service
- Services loading state

### BookingProvider
Manages:
- User bookings
- Booking creation
- Booking cancellation
- Booking details

## 💾 Local Storage

Using SharedPreferences:
```dart
- auth_token: JWT authentication token
- user_id: Current user ID
- user_role: User role (customer/cleaner)
- user_data: Cached user information
```

## 📡 API Endpoints

Base URL: `http://localhost:5000/api`

All endpoints documented in backend README.

## 🧪 Testing Credentials

```
Customer:
  Email: user@test.com
  Password: 123456

Cleaner:
  Email: cleaner@test.com
  Password: 123456

Admin:
  Email: admin@test.com
  Password: 123456
```

## 🛣️ Navigation Routes

```dart
- /splash → Splash screen
- /onboarding → Onboarding flow
- /login → Login screen
- /register → Registration screen
- /home → Home/Dashboard
- /booking → Booking form
```

## 🎯 Key Features Implementation

### Token-Based Authentication
- JWT token stored locally
- Auto-refresh on app restart
- Interceptor adds token to requests
- Logout clears all stored data

### Service Listing
- Fetches from backend on home load
- Displays in 2-column grid
- Shows price and duration
- Tap to book

### Booking Management
- Date/time selection with pickers
- Address and notes input
- Price calculation
- Submit to backend
- Confirmation message

### State Persistence
- User remains logged in after app close
- Bookings list cached locally
- Services cached during session

## 🔧 Configuration

### API Base URL
Edit in `lib/utils/constants.dart`:
```dart
const String BASE_URL = 'http://localhost:5000/api';
```

### Change for production:
```dart
const String BASE_URL = 'https://api.naddefli.com/api';
```

## 🐛 Troubleshooting

### App won't connect to backend
1. Check BASE_URL in constants.dart
2. Verify backend server is running
3. Check network connectivity
4. Ensure CORS is enabled on backend

### Login fails
1. Verify credentials are correct
2. Check backend is running
3. Look for error message in app
4. Check backend logs

### Services not loading
1. Verify backend API is running
2. Check migrations were run
3. Verify seeders populated data
4. Check network errors in console

### Build issues
```bash
# Clean build
flutter clean

# Get packages again
flutter pub get

# Run
flutter run
```

## 📊 Performance Tips

- Lazy load images
- Cache API responses
- Minimize rebuilds with Provider
- Use const constructors
- Profile with DevTools

## 🚀 Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk
```

### iOS IPA
```bash
flutter build ios --release
# Follow Xcode signing process
```

### App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## 📈 Code Organization

### Models
Data classes with JSON serialization

### Providers
State management with ChangeNotifier

### Services
API communication layer

### Screens
UI pages with state binding

### Widgets
Reusable UI components

### Utils
Constants, styling, storage

## 🎨 Styling Guidelines

- Use AppColors from utils
- Use AppStyles for text styles
- Consistent spacing with AppStyles constants
- Material 3 components
- Responsive layout

## 📝 Code Comments

```dart
/// Feature description
/// 
/// This function does X and returns Y
/// 
/// Example:
/// ```dart
/// final result = function();
/// ```
```

## ✅ Pre-launch Checklist

- [ ] API endpoints tested
- [ ] Login flow verified
- [ ] Service list displays
- [ ] Booking creation works
- [ ] Logout works
- [ ] No console errors
- [ ] No security warnings
- [ ] App icon configured
- [ ] App name updated
- [ ] Build tested on device

## 📱 Device Testing

### Android Emulator
```bash
flutter emulators --launch Nexus_5X_API_31
flutter run
```

### iOS Simulator
```bash
open -a Simulator
flutter run
```

### Physical Device
```bash
flutter devices
flutter run -d <device-id>
```

## 🤝 Code Quality

- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep methods focused
- Test error scenarios

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Material Design 3](https://m3.material.io/)

## 🔐 Security Best Practices

✅ Store token securely  
✅ Validate user input  
✅ Use HTTPS in production  
✅ Don't hardcode secrets  
✅ Sanitize API responses  
✅ Clear sensitive data on logout  
✅ Validate certificates  

## 📞 Support

For issues:
1. Check network connectivity
2. Verify backend is running
3. Check API URLs
4. Review error messages
5. Check application logs

## 📄 License

MIT License

---

**Version**: 1.0.0  
**Flutter Version**: 3.0+  
**Dart Version**: 3.0+  
**Last Updated**: April 2024
