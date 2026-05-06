# ⚡ Naddefli - Quick Start Reference

## 🚀 Start Here

### 1. Database Ready?
- [ ] SQL Server running
- [ ] NaddefliDB exists
- [ ] Test credentials work

### 2. Backend Quick Start
```bash
cd Naddefli/backend_node
npm install
npm run migrate && npm run seed
npm run dev
# ✅ Server at http://localhost:5000
```

### 3. Frontend Quick Start
```bash
cd Naddefli/frontend_flutter
flutter pub get
flutter run
# ✅ App launches on emulator/device
```

## 📱 Test Login Credentials

```
Email:    user@test.com
Password: 123456
```

## 🔧 Essential Commands

### Backend
```bash
npm run dev              # Start server
npm run migrate          # Create tables
npm run seed             # Add sample data
npm run migrate:undo     # Remove tables
```

### Frontend
```bash
flutter run              # Run app
flutter clean            # Clean build
flutter pub get          # Get dependencies
flutter build apk        # Build APK
```

### Database (SQL)
```sql
-- Check data
SELECT COUNT(*) FROM users
SELECT COUNT(*) FROM services
SELECT COUNT(*) FROM bookings

-- Reset database
DROP DATABASE NaddefliDB
CREATE DATABASE NaddefliDB
-- Then run: npm run migrate && npm run seed
```

## 📍 Important URLs & Ports

| Service | URL | Port |
|---------|-----|------|
| Backend API | http://localhost:5000 | 5000 |
| SQL Server | localhost | 1433 |
| API Docs | http://localhost:5000/api/health | - |

## 📁 Project Structure

```
Naddefli/
├── backend_node/        → Node.js API
├── frontend_flutter/    → Flutter App
├── SETUP.md            → Full Setup Guide ⭐
├── README.md           → Project Overview
└── SQL_SERVER_SETUP.md → Database Setup
```

## 🧪 Quick Test

```bash
# Backend test
curl http://localhost:5000/api/health

# Expected:
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-04-29T10:00:00.000Z"
}
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Connection refused" | Check SQL Server is running |
| "Port 5000 in use" | Kill process: `lsof -i :5000` |
| "App won't connect" | Check API URL in constants.dart |
| "Migrations fail" | Ensure database exists |
| "Services not showing" | Run: `npm run seed` |

## 📊 Verify Setup

### Backend ✅
```bash
curl http://localhost:5000/api/services
# Should return array of 8 services
```

### Database ✅
Open SSMS and check tables in NaddefliDB:
- users (3 rows)
- services (8 rows)  
- cleaners (1 row)

### Frontend ✅
- App launches
- Login works
- Services visible
- Can create booking

## 🔐 Test Users

| Email | Pass | Role |
|-------|------|------|
| user@test.com | 123456 | Customer |
| cleaner@test.com | 123456 | Cleaner |
| admin@test.com | 123456 | Admin |

## 📝 Environment File (.env)

```env
PORT=5000
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=NaddefliDB
DB_USER=sa
DB_PASSWORD=YourPassword@123
JWT_SECRET=naddefli_jwt_secret_key_2024_super_secure
```

## 🎯 Next Level

- [ ] Customize colors in `app_styles.dart`
- [ ] Add more services in database
- [ ] Extend API with new endpoints
- [ ] Add cleaner dashboard
- [ ] Implement notifications
- [ ] Add payment gateway
- [ ] Deploy to production

## 📞 Need Help?

1. Check relevant README file
2. Read SETUP.md for detailed steps
3. Check API logs (backend terminal)
4. Check database in SSMS
5. Verify network connectivity

## ⏱️ Typical Timeline

- Setup SQL Server: 10-15 minutes
- Backend setup: 5 minutes
- Frontend setup: 5 minutes
- Testing: 10 minutes
- **Total: ~30-40 minutes**

## 🎉 You're Ready!

Once everything runs:
1. Login with test credentials
2. Browse services
3. Create a booking
4. View bookings
5. Logout and login again
6. Explore codebase

---

## 📚 File Reference

- **SETUP.md** ← Complete setup guide
- **README.md** ← Project overview
- **backend_node/README.md** ← Backend API docs
- **frontend_flutter/README.md** ← Frontend docs
- **SQL_SERVER_SETUP.md** ← Database setup

---

**Quick Ref Ver 1.0** | Last Updated: April 2024
