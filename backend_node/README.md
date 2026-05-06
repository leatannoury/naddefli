# Naddefli Backend - Node.js + Express REST API

Professional backend API for the Naddefli Cleaning Service Mobile Application built with Node.js, Express, and Microsoft SQL Server.

## 📋 Project Overview

Naddefli is an on-demand cleaning service platform that connects customers with verified cleaners. This backend provides all necessary REST APIs for authentication, service management, bookings, reviews, and admin features.

## 🏗️ Architecture

```
backend_node/
├── src/
│   ├── controllers/        # Business logic
│   ├── routes/             # API endpoints
│   ├── models/             # Sequelize ORM models
│   ├── middleware/         # Auth, error handling
│   ├── config/             # Database config
│   ├── utils/              # Helpers and utilities
│   └── index.js            # Server entry point
├── migrations/             # Database migrations
├── seeders/                # Sample data
├── package.json
├── .env
└── .sequelizerc
```

## 🛠️ Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.18
- **Database**: Microsoft SQL Server (SSMS)
- **ORM**: Sequelize 6
- **Authentication**: JWT (JSON Web Tokens)
- **Password**: bcryptjs
- **Validation**: express-validator
- **CORS**: Enabled for mobile app

## 📦 Installation

### Prerequisites
- Node.js 18+ and npm
- Microsoft SQL Server (local or remote)
- SQL Server Management Studio (SSMS)

### Setup Steps

1. **Navigate to backend folder**
   ```bash
   cd Naddefli/backend_node
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   Edit `.env` file with your SQL Server credentials:
   ```
   PORT=5000
   NODE_ENV=development
   
   DB_HOST=localhost
   DB_PORT=1433
   DB_DATABASE=NaddefliDB
   DB_USER=sa
   DB_PASSWORD=YourPassword@123
   
   JWT_SECRET=naddefli_jwt_secret_key_2024_super_secure
   JWT_EXPIRY=7d
   ```

4. **Run migrations (creates database schema)**
   ```bash
   npm run migrate
   ```

5. **Seed sample data**
   ```bash
   npm run seed
   ```

6. **Start development server**
   ```bash
   npm run dev
   ```

Server will run on `http://localhost:5000`

## 🚀 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get current user profile (Protected)
- `PUT /api/auth/profile` - Update profile (Protected)

### Services
- `GET /api/services` - Get all services
- `GET /api/services/:id` - Get service by ID

### Bookings (Customer)
- `POST /api/bookings/create` - Create new booking (Protected)
- `GET /api/bookings/my-bookings` - Get user's bookings (Protected)
- `GET /api/bookings/:id` - Get booking details (Protected)
- `PUT /api/bookings/cancel/:id` - Cancel booking (Protected)

### Cleaner Operations
- `GET /api/cleaner/jobs` - Get assigned jobs (Protected, Cleaner only)
- `PUT /api/cleaner/accept/:id` - Accept booking (Protected, Cleaner only)
- `PUT /api/cleaner/status/:id` - Update booking status (Protected, Cleaner only)
- `GET /api/cleaner/earnings` - Get earnings (Protected, Cleaner only)
- `PUT /api/cleaner/availability` - Update availability (Protected, Cleaner only)

### Reviews
- `POST /api/reviews/create` - Create review (Protected, Customer only)
- `GET /api/reviews/cleaner/:cleanerId` - Get cleaner reviews

### Notifications
- `GET /api/notifications` - Get user notifications (Protected)
- `PUT /api/notifications/:id/read` - Mark as read (Protected)
- `PUT /api/notifications/read-all` - Mark all as read (Protected)

### Admin
- `GET /api/admin/dashboard` - Dashboard stats (Protected, Admin only)
- `GET /api/admin/users` - Get all users (Protected, Admin only)
- `GET /api/admin/cleaners` - Get all cleaners (Protected, Admin only)
- `GET /api/admin/bookings` - Get all bookings (Protected, Admin only)

## 📊 Database Schema

### Tables
1. **users** - All users (customers, cleaners, admins)
2. **cleaners** - Cleaner profiles with ratings
3. **services** - Available cleaning services
4. **bookings** - Customer bookings
5. **reviews** - Service reviews
6. **notifications** - User notifications

## 🔐 Authentication

Uses JWT token-based authentication:

**Login Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user-uuid",
      "full_name": "John Doe",
      "email": "john@example.com",
      "role": "customer"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Using Token:**
Add to request header:
```
Authorization: Bearer <token>
```

## 👥 Sample Test Users

| Email | Password | Role |
|-------|----------|------|
| admin@test.com | 123456 | admin |
| user@test.com | 123456 | customer |
| cleaner@test.com | 123456 | cleaner |

## 💰 Pricing Logic

- Base prices set per service
- Urgent bookings (same day): +20% surcharge
- Dynamic pricing based on service type

**Sample Service Prices:**
- Kitchen Cleaning: $15
- Bathroom Cleaning: $10
- Bedroom Cleaning: $12
- Full House Cleaning: $40
- Window Cleaning: $20
- Sofa Cleaning: $25
- Pest Control: $50
- Office Cleaning: $35

## 📝 Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "error": { /* error details */ }
}
```

## 🔄 Booking Status Flow

1. **pending** - Awaiting cleaner acceptance
2. **accepted** - Cleaner accepted the booking
3. **on_the_way** - Cleaner is traveling to location
4. **started** - Service started
5. **completed** - Service finished
6. **cancelled** - Booking cancelled

## 🧪 Testing Endpoints

Use Postman or any REST client:

1. **Register**
   ```
   POST http://localhost:5000/api/auth/register
   Content-Type: application/json
   
   {
     "full_name": "Test User",
     "email": "test@example.com",
     "password": "123456",
     "phone": "+1234567890",
     "role": "customer"
   }
   ```

2. **Login**
   ```
   POST http://localhost:5000/api/auth/login
   Content-Type: application/json
   
   {
     "email": "test@example.com",
     "password": "123456"
   }
   ```

3. **Get Services**
   ```
   GET http://localhost:5000/api/services
   ```

4. **Create Booking** (requires token)
   ```
   POST http://localhost:5000/api/bookings/create
   Authorization: Bearer <token>
   Content-Type: application/json
   
   {
     "service_id": "service-uuid",
     "booking_date": "2024-12-25",
     "booking_time": "10:00",
     "address": "123 Main St",
     "city": "New York",
     "notes": "Please bring supplies"
   }
   ```

## 🐛 Troubleshooting

### Database Connection Error
- Verify SQL Server is running
- Check credentials in `.env`
- Ensure database port is accessible

### Migration Failed
```bash
npm run migrate:undo
npm run migrate
```

### Clear and Reseed Database
```bash
npm run seed:undo
npm run seed
```

## 📚 Project Structure Details

### Controllers
Each controller handles business logic for specific features:
- `authController.js` - User registration, login, profile
- `serviceController.js` - Service retrieval
- `bookingController.js` - Booking management
- `cleanerController.js` - Cleaner operations
- `reviewController.js` - Reviews management
- `notificationController.js` - Notifications
- `adminController.js` - Admin dashboard

### Routes
RESTful route definitions with middleware:
- Protection: `authMiddleware` ensures authenticated access
- Authorization: `authorizationMiddleware` checks user role

### Middleware
- `auth.js` - JWT verification and role checking
- `errorHandler.js` - Global error handling

### Utils
- `helpers.js` - Password hashing, token generation, price calculation
- `response.js` - Standard response formatting

## 🚀 Production Deployment

1. Set `NODE_ENV=production` in `.env`
2. Use environment variables for sensitive data
3. Enable HTTPS
4. Configure CORS for specific domains
5. Use process manager (PM2)
6. Setup database backups
7. Monitor logs and errors

## 📄 Environment Variables

```
PORT - Server port (default: 5000)
NODE_ENV - Environment (development/production)
DB_HOST - SQL Server host
DB_PORT - SQL Server port (default: 1433)
DB_DATABASE - Database name
DB_USER - Database user
DB_PASSWORD - Database password
JWT_SECRET - Secret key for JWT signing
JWT_EXPIRY - Token expiration time (default: 7d)
```

## 🤝 Contributing

1. Follow clean code principles
2. Add comments for complex logic
3. Test APIs before committing
4. Keep migrations organized
5. Update documentation

## 📞 Support

For issues or questions, check:
1. Database connection settings
2. API logs in terminal
3. Request/response format
4. Authentication tokens
5. User permissions/roles

## ✅ Checklist Before Going Live

- [ ] Update JWT_SECRET to strong key
- [ ] Configure production database
- [ ] Setup CORS for web/mobile domains
- [ ] Enable HTTPS
- [ ] Setup monitoring and logging
- [ ] Create database backups
- [ ] Test all API endpoints
- [ ] Verify authentication flows
- [ ] Check error handling
- [ ] Update documentation

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**License**: MIT
