# Naddefli - Cleaning Service Mobile Application

A complete full-stack mobile application connecting customers with professional cleaners for homes, apartments, offices, and special cleaning services.

## 📱 Project Structure

```
Naddefli/
├── backend_node/          # Node.js + Express REST API
│   ├── src/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── models/
│   │   ├── middleware/
│   │   ├── config/
│   │   ├── utils/
│   │   └── index.js
│   ├── migrations/
│   ├── seeders/
│   ├── package.json
│   ├── .env
│   └── README.md
│
└── frontend_flutter/      # Flutter Mobile App
    ├── lib/
    │   ├── screens/
    │   ├── widgets/
    │   ├── models/
    │   ├── providers/
    │   ├── services/
    │   ├── utils/
    │   ├── main.dart
    │   └── app.dart
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── assets/
    └── README.md
```

## 🎯 Features

### Customer Features
✅ User registration and authentication  
✅ Browse available cleaning services  
✅ Book cleaning services with date/time selection  
✅ View booking history  
✅ Track booking status in real-time  
✅ Rate and review completed services  
✅ Manage profile information  
✅ Receive notifications  

### Cleaner Features
✅ Accept/reject job bookings  
✅ View assigned jobs  
✅ Update booking status (on the way, started, completed)  
✅ Manage availability  
✅ Track earnings  
✅ View ratings and reviews  

### Admin Features
✅ Dashboard with statistics  
✅ Manage users and cleaners  
✅ View all bookings and reviews  
✅ System analytics  

## 🛠️ Tech Stack

### Backend
- **Server**: Node.js 18+ with Express.js 4.18
- **Database**: Microsoft SQL Server
- **ORM**: Sequelize 6
- **Authentication**: JWT + bcryptjs
- **Validation**: express-validator
- **API**: RESTful with CORS

### Frontend
- **Framework**: Flutter (latest stable)
- **State Management**: Provider
- **HTTP Client**: Dio
- **Storage**: SharedPreferences
- **UI**: Material Design 3

### Database
- **Primary**: Microsoft SQL Server
- **Tables**: Users, Cleaners, Services, Bookings, Reviews, Notifications
- **Migrations**: Sequelize migrations
- **Seeders**: Sample data included

## ⚡ Quick Start

### Prerequisites
- Node.js 18+ and npm
- Flutter SDK
- Microsoft SQL Server (SSMS)
- Android Studio or Xcode (for Flutter)

### Backend Setup

```bash
# Navigate to backend
cd Naddefli/backend_node

# Install dependencies
npm install

# Configure database in .env file
# Update DB_HOST, DB_USER, DB_PASSWORD

# Run migrations
npm run migrate

# Seed sample data
npm run seed

# Start server
npm run dev
```

**Server runs on**: `http://localhost:5000`

### Frontend Setup

```bash
# Navigate to frontend
cd Naddefli/frontend_flutter

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run
```

## 📊 Database Structure

### Users Table
- id (UUID, PK)
- full_name
- email (unique)
- phone
- password (hashed)
- role (customer/cleaner/admin)
- created_at

### Cleaners Table
- id (UUID, PK)
- user_id (FK)
- experience_years
- rating (1-5)
- is_available
- national_id
- created_at

### Services Table
- id (UUID, PK)
- name
- description
- base_price
- duration_hours
- image
- created_at

### Bookings Table
- id (UUID, PK)
- user_id (FK)
- cleaner_id (FK, nullable)
- service_id (FK)
- booking_date
- booking_time
- address
- city
- notes
- total_price
- status (pending/accepted/on_the_way/started/completed/cancelled)
- created_at

### Reviews Table
- id (UUID, PK)
- booking_id (FK)
- user_id (FK)
- cleaner_id (FK)
- rating (1-5)
- comment
- created_at

### Notifications Table
- id (UUID, PK)
- user_id (FK)
- title
- body
- is_read
- created_at

## 🔐 Authentication

JWT-based token authentication:

```
Register → Login → Get Token → Store Token → Use in API Requests
```

**Test Credentials**:
- Admin: `admin@test.com` / `123456`
- Customer: `user@test.com` / `123456`
- Cleaner: `cleaner@test.com` / `123456`

## 💰 Service Pricing

| Service | Price | Duration |
|---------|-------|----------|
| Kitchen Cleaning | $15 | 2h |
| Bathroom Cleaning | $10 | 1h |
| Bedroom Cleaning | $12 | 1.5h |
| Full House Cleaning | $40 | 4h |
| Window Cleaning | $20 | 1.5h |
| Sofa Cleaning | $25 | 2h |
| Pest Control | $50 | 2h |
| Office Cleaning | $35 | 3h |

**Dynamic Pricing**: Same-day urgent bookings get +20% surcharge

## 🚀 API Endpoints

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/profile`
- `PUT /api/auth/profile`

### Services
- `GET /api/services`
- `GET /api/services/:id`

### Bookings
- `POST /api/bookings/create`
- `GET /api/bookings/my-bookings`
- `GET /api/bookings/:id`
- `PUT /api/bookings/cancel/:id`

### Cleaner
- `GET /api/cleaner/jobs`
- `PUT /api/cleaner/accept/:id`
- `PUT /api/cleaner/status/:id`
- `GET /api/cleaner/earnings`

### Notifications
- `GET /api/notifications`
- `PUT /api/notifications/:id/read`

### Admin
- `GET /api/admin/dashboard`
- `GET /api/admin/users`
- `GET /api/admin/cleaners`
- `GET /api/admin/bookings`

## 📱 Flutter Screens

1. **Splash Screen** - App loading
2. **Onboarding** - App introduction
3. **Login** - User authentication
4. **Register** - New user signup
5. **Home** - Dashboard with services
6. **Booking** - Service booking form
7. **My Bookings** - View bookings
8. **Profile** - User profile management

## 🏗️ Architecture

### Backend Architecture
- **MVC Pattern**: Controllers, Models, Routes
- **Middleware**: Auth, Error Handling
- **Services**: Business logic separation
- **Utilities**: Helpers and formatters

### Frontend Architecture
- **Clean Architecture**: Separation of concerns
- **Provider State Management**: Reactive programming
- **Repository Pattern**: Data layer abstraction
- **Service Layer**: API communication

## 📚 Documentation

For detailed information:
- **Backend**: See `backend_node/README.md`
- **Frontend**: See `frontend_flutter/README.md`

## 🧪 Testing

### Backend Testing
```bash
# Start server
npm run dev

# Test with Postman or curl
curl -X GET http://localhost:5000/api/services
```

### Frontend Testing
```bash
# Run on emulator
flutter run

# Run on device
flutter run -d <device-id>
```

## 🔒 Security Features

✅ JWT token-based authentication  
✅ Bcrypt password hashing  
✅ CORS enabled  
✅ Input validation  
✅ Role-based access control  
✅ Secure token storage (SharedPreferences)  
✅ Error message sanitization  

## 📈 Performance Optimizations

- Token caching in local storage
- Service list caching
- Lazy loading for bookings
- Optimized database queries
- Proper indexing on foreign keys

## 🚢 Deployment

### Backend Deployment
1. Set environment variables
2. Configure production database
3. Run migrations on production
4. Use PM2 for process management
5. Setup reverse proxy (Nginx)
6. Enable HTTPS

### Frontend Deployment
1. Build APK: `flutter build apk`
2. Build iOS: `flutter build ios`
3. Upload to Google Play Store / App Store

## 🐛 Troubleshooting

### Backend Issues
- Check SQL Server connection
- Verify .env configuration
- Review API logs
- Check token validity

### Frontend Issues
- Clear cache: `flutter clean`
- Rebuild: `flutter pub get && flutter run`
- Check API URL configuration
- Verify network connectivity

## 📞 Support

### Common Issues

**Q: Database connection fails**  
A: Verify SQL Server is running, check credentials in .env

**Q: API returns 401 Unauthorized**  
A: Ensure token is included in Authorization header

**Q: Flutter app won't connect to backend**  
A: Check API_URL in constants, ensure backend is running

**Q: Services not showing in app**  
A: Run migrations and seeders: `npm run migrate && npm run seed`

## 📋 Checklist

### Before Going Live
- [ ] Backend API tested
- [ ] Database migrations verified
- [ ] Sample data seeded
- [ ] Flutter app builds successfully
- [ ] Login/registration flows tested
- [ ] Booking creation tested
- [ ] All API endpoints working
- [ ] Error handling verified
- [ ] Security measures implemented
- [ ] Documentation updated

## 📦 Dependencies

### Backend
- express
- sequelize
- tedious (SQL Server driver)
- jsonwebtoken
- bcryptjs
- cors
- dotenv

### Frontend
- provider
- dio
- shared_preferences
- google_fonts
- shimmer
- intl

## 🎉 Getting Started

1. Clone/download the Naddefli folder
2. Setup backend (see Backend Setup above)
3. Setup frontend (see Frontend Setup above)
4. Start backend server
5. Run Flutter app
6. Login with test credentials
7. Book a cleaning service
8. Enjoy!

## 📄 License

MIT License - Feel free to use this project

## 🙌 Credits

Built as a complete full-stack example for a cleaning service platform.

---

**Version**: 1.0.0  
**Last Updated**: April 2024  
**Status**: ✅ Ready for Development/Testing

For specific documentation, refer to:
- **Backend Docs**: `backend_node/README.md`
- **Frontend Docs**: `frontend_flutter/README.md` (create next if needed)
