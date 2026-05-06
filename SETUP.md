# 🚀 Naddefli Complete Setup Guide

Complete step-by-step guide to get the entire Naddefli cleaning service application running.

## 📋 Prerequisites

Before starting, ensure you have:

### System Requirements
- Windows 10/11 or macOS or Linux
- 4GB RAM minimum
- 2GB free disk space

### Required Software
- **Node.js 18+** - [Download](https://nodejs.org/)
- **npm** (comes with Node.js)
- **Flutter 3.0+** - [Download](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Microsoft SQL Server** - [Download](https://www.microsoft.com/sql-server/sql-server-downloads)
- **SQL Server Management Studio** - [Download](https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms)
- **Git** (optional) - [Download](https://git-scm.com/)

### Text Editor/IDE
- **Visual Studio Code** - [Download](https://code.visualstudio.com/)
- Extensions: Flutter, Dart, REST Client (optional)

## ✅ Step 1: Verify Installation

### Check Node.js
```bash
node --version    # Should be v18+
npm --version     # Should be 9+
```

### Check Flutter
```bash
flutter --version
dart --version
```

## 🗄️ Step 2: Setup SQL Server Database

### If you don't have SQL Server installed:

**Windows:**
1. Download SQL Server 2022 Express from Microsoft
2. Run installer
3. Choose "Custom" installation
4. Select Database Engine Services
5. In Configuration, choose "Mixed Mode" authentication
6. Set SA password: `YourPassword@123` (remember this)
7. Enable TCP/IP in SQL Server Configuration Manager
8. Install SQL Server Management Studio

**macOS/Linux (Docker Recommended):**
```bash
# Install Docker if not already installed

# Run SQL Server container
docker run -e 'ACCEPT_EULA=Y' \
  -e 'SA_PASSWORD=YourPassword@123' \
  -p 1433:1433 \
  --name naddefli_db \
  mcr.microsoft.com/mssql/server:2022-latest
```

### Create Database in SSMS

1. Open SQL Server Management Studio
2. Connect to your server
3. Right-click "Databases" → "New Database"
4. Name: `NaddefliDB`
5. Click OK

For detailed SQL Server setup, see `SQL_SERVER_SETUP.md`

## 📦 Step 3: Setup Backend (Node.js + Express)

### Navigate to Backend
```bash
cd Naddefli/backend_node
```

### Install Dependencies
```bash
npm install
```

### Configure Environment Variables
Edit `.env` file with your database credentials:
```env
PORT=5000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=NaddefliDB
DB_USER=sa
DB_PASSWORD=YourPassword@123

# JWT Configuration
JWT_SECRET=naddefli_jwt_secret_key_2024_super_secure
JWT_EXPIRY=7d
```

### Run Database Migrations
```bash
# Creates database tables
npm run migrate

# Seeds sample data
npm run seed
```

### Start Backend Server
```bash
npm run dev
```

**Expected Output:**
```
✅ Database connection established successfully
✅ Database models synchronized
✅ Server running on http://localhost:5000
📚 API Documentation:
   - Auth: POST /api/auth/register, POST /api/auth/login
   - Services: GET /api/services
   - Bookings: POST /api/bookings/create, GET /api/bookings/my-bookings
   - Health: GET /api/health
```

**✅ Backend is ready!** Keep server running.

## 📱 Step 4: Setup Frontend (Flutter)

### Open New Terminal

Navigate to Flutter project:
```bash
cd Naddefli/frontend_flutter
```

### Get Dependencies
```bash
flutter pub get
```

### Configure API URL

Check `lib/utils/constants.dart`:
```dart
const String BASE_URL = 'http://localhost:5000/api';
```
(Should be correct for local development)

### Run on Emulator/Device

**Android Emulator:**
```bash
# Start emulator first, or:
flutter emulators --launch Nexus_5X_API_31

# Run app
flutter run
```

**iOS Simulator:**
```bash
open -a Simulator
flutter run
```

**Physical Device:**
```bash
flutter devices
flutter run -d <device-id>
```

**Expected Output:**
```
Launching lib/main.dart on Android Emulator...
...
Waiting for connection from debug service on Android Emulator...
✓ Connected!
✓ App launched!
```

## 🧪 Step 5: Test the Application

### 1. Test Splash Screen
- App should show logo and auto-redirect

### 2. Test Onboarding
- Navigate through 3 pages
- Click "Get Started"

### 3. Test Login
Use test credentials:
```
Email: user@test.com
Password: 123456
```

### 4. Test Home Screen
- Should see "Welcome, Test Customer!"
- Services should display in grid
- Bottom navigation working

### 5. Test Booking
- Tap a service
- Select date and time
- Enter address and city
- Click "Confirm Booking"
- Should see success message

### 6. Test My Bookings
- Switch to "Bookings" tab
- Should see your booking

### 7. Test Logout
- Switch to "Profile" tab
- Click "Logout"
- Should redirect to login

## 📊 Verify Database

### Check Created Tables in SSMS

In SQL Server Management Studio:
1. Connect to NaddefliDB
2. Expand Tables
3. Should see:
   - dbo.users
   - dbo.cleaners
   - dbo.services
   - dbo.bookings
   - dbo.reviews
   - dbo.notifications

### Check Sample Data

```sql
SELECT COUNT(*) FROM users          -- Should see 3
SELECT COUNT(*) FROM services       -- Should see 8
SELECT COUNT(*) FROM cleaners       -- Should see 1
```

## 🔄 API Testing (Optional)

### Using Postman or REST Client

1. **Get Services**
   ```
   GET http://localhost:5000/api/services
   ```

2. **Login**
   ```
   POST http://localhost:5000/api/auth/login
   Content-Type: application/json
   
   {
     "email": "user@test.com",
     "password": "123456"
   }
   ```

3. **Create Booking** (requires token)
   ```
   POST http://localhost:5000/api/bookings/create
   Authorization: Bearer <token_from_login>
   Content-Type: application/json
   
   {
     "service_id": "11111111-1111-1111-1111-111111111111",
     "booking_date": "2024-12-25",
     "booking_time": "10:00",
     "address": "123 Main St",
     "city": "New York",
     "notes": "Please bring supplies"
   }
   ```

## 📱 Test Users

| Email | Password | Role |
|-------|----------|------|
| admin@test.com | 123456 | Admin |
| user@test.com | 123456 | Customer |
| cleaner@test.com | 123456 | Cleaner |

## 🛑 Stopping the Application

### Backend
- Press `Ctrl+C` in backend terminal

### Frontend
- Press `Q` in Flutter terminal (or Ctrl+C)

### SQL Server (Docker)
```bash
docker stop naddefli_db
```

## 🔄 Restarting

### Start Backend
```bash
cd Naddefli/backend_node
npm run dev
```

### Start Frontend
```bash
cd Naddefli/frontend_flutter
flutter run
```

## 📋 Common Issues

### "Connection refused" Error

**Backend:**
```
Error: ECONNREFUSED

Solution:
1. Verify SQL Server is running
2. Check DB credentials in .env
3. Verify database NaddefliDB exists
4. Check port 1433 is accessible
```

**Frontend:**
```
Error: Can't connect to API

Solution:
1. Verify backend is running (should see message on localhost:5000)
2. Check BASE_URL in constants.dart is correct
3. Check network on emulator/device
4. Try: flutter clean && flutter pub get && flutter run
```

### "npm command not found"

```
Solution:
1. Restart terminal/command prompt
2. Verify Node.js installed: node --version
3. Reinstall Node.js if needed
```

### "flutter command not found"

```
Solution:
1. Add Flutter to PATH
2. On Windows: Add C:\src\flutter\bin to PATH
3. On Mac/Linux: Add ~/flutter/bin to PATH
4. Restart terminal and try: flutter --version
```

### Database Doesn't Exist

```bash
# Backend: Automatic creation
npm run migrate    # Creates tables

# SSMS: Create manually
# Right-click Databases → New Database → Name: NaddefliDB
```

### Migration Failed

```bash
# Undo migration
npm run migrate:undo

# Try again
npm run migrate
npm run seed
```

### Services Not Showing in App

```bash
# Verify data was seeded
npm run seed:undo
npm run seed

# Check in database
SELECT * FROM services   # Should see 8 services
```

## 🚀 Next Steps

### 1. Explore the Code
- Review backend structure in `backend_node/src`
- Review frontend structure in `frontend_flutter/lib`
- Understand authentication flow
- Study API endpoints

### 2. Extend Features
- Add more services
- Create new screens
- Add cleaner functionality
- Implement notifications
- Add payment integration

### 3. Customize
- Change app colors in `lib/utils/app_styles.dart`
- Update app name and logo
- Modify service list
- Customize pricing

### 4. Deploy
- Build APK: `flutter build apk --release`
- Build iOS: `flutter build ios --release`
- Deploy backend to cloud (AWS, Azure, etc.)
- Setup production database

## 📚 Documentation

- **Backend Details**: See `backend_node/README.md`
- **Frontend Details**: See `frontend_flutter/README.md`
- **SQL Server Setup**: See `SQL_SERVER_SETUP.md`
- **Main README**: See `README.md`

## 🎯 Quick Command Reference

```bash
# Backend
cd Naddefli/backend_node
npm install              # Install dependencies
npm run dev              # Start server
npm run migrate          # Run migrations
npm run seed             # Seed data
npm run migrate:undo     # Undo migrations

# Frontend
cd Naddefli/frontend_flutter
flutter pub get          # Get dependencies
flutter run              # Run app
flutter build apk        # Build APK
flutter clean            # Clean build

# Database
# In SQL Server Management Studio:
CREATE DATABASE NaddefliDB
SELECT * FROM users
SELECT * FROM services
SELECT * FROM bookings
```

## ✅ Setup Checklist

- [ ] Node.js installed and working
- [ ] Flutter installed and working
- [ ] SQL Server installed and running
- [ ] SQL Server Management Studio installed
- [ ] NaddefliDB database created
- [ ] Backend dependencies installed
- [ ] Backend migrations completed
- [ ] Backend seeders run
- [ ] Backend server started and running
- [ ] Frontend dependencies installed
- [ ] API URL configured correctly
- [ ] Flutter app runs on emulator/device
- [ ] Can login with test credentials
- [ ] Services display in app
- [ ] Can create a booking
- [ ] Can view bookings
- [ ] Can logout

## 🎉 Success!

If you've reached here, congratulations! Your Naddefli application is fully set up and running.

### You can now:
✅ Browse cleaning services  
✅ Book a cleaner  
✅ Track bookings  
✅ Manage profile  
✅ Test API endpoints  
✅ Explore the codebase  

## 📞 Support

If you encounter issues:

1. **Check Logs** - Look at error messages carefully
2. **Verify Credentials** - Double-check database credentials
3. **Restart Services** - Stop and restart backend/database
4. **Clear Cache** - `flutter clean && flutter pub get`
5. **Check Ports** - Verify 5000 and 1433 are available
6. **Review Documentation** - Check relevant README files

## 🔗 Useful Links

- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Guide](https://expressjs.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Sequelize ORM](https://sequelize.org/)
- [SQL Server Documentation](https://learn.microsoft.com/sql/sql-server/)

---

**Version**: 1.0  
**Last Updated**: April 2024  
**Status**: ✅ Ready to Run

Happy coding! 🚀
