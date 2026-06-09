# Naddefli — Complete Presentation Study Guide

**Read this top to bottom once, then skim the cheat sheet before you present.**

You built a **3-tier cleaning-service platform**:

| Layer | Technology | Who uses it |
|-------|-----------|-------------|
| **Mobile app** | Flutter (Dart) | Customers on phone |
| **Backend API** | Node.js + Express | Connects app + admin to database |
| **Admin dashboard** | React + Vite | Business owner / staff |
| **Database** | SQLite file (`database.sqlite`) | Stores all data |
| **Firebase** | Google Firebase Auth | Login on the phone (email + Google) |
| **Gemini AI** | Google Gemini API | Polishes AI advisor text on backend |

---

## 1. The Big Picture (say this in 30 seconds)

> "Naddefli is a home-cleaning booking platform. Customers use a **Flutter mobile app** to browse services, book cleanings, manage addresses, and get AI recommendations. An **Express REST API** handles business logic, pricing, loyalty, and notifications. Data lives in **SQLite** via **Sequelize ORM**. Staff use a **React admin dashboard** to accept bookings, manage customers, services, promos, and settings. **Firebase** handles client-side authentication; the backend issues **JWT tokens** for every API call."

```
┌──────────────────┐   HTTP + JWT    ┌──────────────────┐
│  Flutter App     │ ◄──────────────►│  Node.js API     │
│  (Customer UI)   │  :5000/api      │  (Business logic)│
└────────┬─────────┘                 └────────┬─────────┘
         │ Firebase Auth                      │ Sequelize
         ▼                                    ▼
┌──────────────────┐                 ┌──────────────────┐
│  Google/Firebase │                 │  database.sqlite │
└──────────────────┘                 └──────────────────┘

┌──────────────────┐   HTTP + JWT    ┌──────────────────┐
│  React Admin     │ ◄──────────────►│  /api/admin/*    │
└──────────────────┘                 └──────────────────┘
```

---

## 2. Folder Structure — What Lives Where

```
Naddefli/
├── frontend_flutter/     ← Mobile app (Dart/Flutter)
│   └── lib/
│       ├── main.dart           ← App entry: Firebase + storage init
│       ├── app.dart            ← Routes + Provider setup
│       ├── screens/            ← Full pages (login, home, booking…)
│       ├── widgets/            ← Reusable UI pieces (calendar, forms)
│       ├── providers/          ← App state (auth, bookings, services)
│       ├── services/           ← API calls to backend
│       ├── models/             ← Data classes (Booking, User, Service)
│       └── utils/              ← Constants, styles, pricing helpers
│
├── backend_node/           ← REST API (JavaScript/Node)
│   └── src/
│       ├── index.js            ← Server start, route mounting
│       ├── routes/             ← URL → controller mapping
│       ├── controllers/        ← Business logic per feature
│       ├── models/             ← Database table definitions
│       ├── middleware/         ← Auth JWT check, file upload, errors
│       ├── services/           ← Gemini AI integration
│       └── utils/              ← Helpers, loyalty, pricing engine
│
└── admin_dashboard/        ← Staff web app (React)
    └── src/
        ├── main.jsx            ← React entry
        ├── App.jsx             ← Page routing
        ├── pages/              ← Dashboard, Bookings, Customers…
        ├── components/         ← Sidebar, booking detail modal
        ├── contexts/           ← Admin login state
        └── services/api.js     ← Axios calls to backend
```

---

## 3. How the Three Apps Talk to Each Other

### Step-by-step: any API call from the phone

1. **User opens app** → `main.dart` initializes Firebase + local storage
2. **Splash screen** → checks if JWT token is saved on phone
3. **If logged in** → `AuthProvider` calls `GET /api/auth/profile` with token
4. **HttpService** (Dio) automatically adds header: `Authorization: Bearer <token>`
5. **Backend** `authMiddleware` verifies JWT with `JWT_SECRET`
6. **Controller** reads/writes database via Sequelize models
7. **JSON response** comes back → Provider updates state → UI rebuilds

### URLs you must know

| Client | Base URL | Why |
|--------|----------|-----|
| Flutter on **physical phone** | `http://192.168.1.107:5000/api` | Phone can't reach `localhost` — needs your PC's LAN IP |
| Admin on **same PC** | `http://localhost:5000/api` | Browser and server on same machine |
| Backend bind address | `0.0.0.0:5000` | Listens on all network interfaces |

File: `frontend_flutter/lib/utils/constants.dart` → `BASE_URL`

---

## 4. Authentication — Full Flow (common exam question)

### Why two systems? (Firebase + JWT)

- **Firebase** = proves identity on the phone (email/password, Google sign-in)
- **JWT (backend)** = proves identity to YOUR API (your database owns users, roles, loyalty)

### Register flow

```
User fills form (RegisterScreen)
    → FirebaseAuthService.signUpWithEmail()
        → Firebase creates account on Google servers
        → POST /api/auth/register { full_name, email, password, phone }
            → Backend hashes password (bcrypt)
            → Saves User row in SQLite (role = customer)
            → Returns JWT token + user JSON
    → StorageService saves token on phone
    → Navigate to HomeScreen
```

### Login flow

```
User enters email/password (LoginScreen)
    → Firebase signInWithEmailAndPassword()
    → POST /api/auth/login
        → Backend finds user, compares bcrypt password
        → Rejects if is_blocked = true
        → Returns JWT
    → Token saved → Home
```

### Google Sign-In

```
GoogleSignIn → Firebase credential → POST /api/auth/google { id_token, email, full_name }
    → Backend verifies token with Google tokeninfo API
    → Creates user if new, else finds existing
    → Returns JWT
```

### Admin login (separate)

```
Admin Login page → POST /api/admin/login
    → Same JWT format but role must be admin
    → Token stored in localStorage (naddefli_admin_token)
```

**Key files:** `auth_provider.dart`, `firebase_auth_service.dart`, `authController.js`, `middleware/auth.js`

---

## 5. Booking Flow — Full Journey (demo this)

### A) Book a catalog service (e.g. "Kitchen Cleaning")

```
HomeScreen → tap service card
    → BookingScreen (pre-filled service info)
    → User picks date, time, address, optional promo
    → BookingProvider.createBooking()
        → POST /api/bookings/create
            → Validates future date
            → Calculates price (hours × rate)
            → Applies promo discount if valid
            → Creates Booking (status = pending)
            → Creates Notification ("Booking Pending")
    → BookingConfirmationScreen
```

### B) Custom booking (user configures rooms, deep/normal, add-ons)

```
Home → FAB or "Custom Booking"
    → CustomBookingScreen
    → User sets property type, room counts, cleaning type, add-ons
    → Price calculated client-side (pricing.dart) + confirmed server-side
    → Same POST /api/bookings/create with is_custom = true
```

### C) AI Cleaning Planner

```
Home → "AI Cleaning Planner"
    → ServiceAdvisorScreen (quiz: property, mess level, etc.)
    → POST /api/ai/service-recommendation (no auth required)
        → serviceRecommendationEngine.js picks hours, type, price (rules)
        → geminiService.js writes friendly summary text
    → User taps "Use This Plan"
    → CustomBookingScreen opens pre-filled via BookingDraft model
```

### D) Admin accepts booking

```
Admin Bookings page → filter Pending
    → Accept button → PUT /api/admin/bookings/:id/accept
        → status = accepted
        → Customer gets in-app notification
```

### E) Customer sees update

```
Bookings tab → list or calendar view
    → Purple-highlighted days = days with bookings
    → Tap day → booking cards below
    → Tap booking → BookingDetailsScreen (cancel if still pending)
```

### Booking status lifecycle

```
pending → accepted → on_the_way → started → completed
              ↘ cancelled (customer or admin)
```

---

## 6. Database — Tables You Should Name

| Table | What it stores |
|-------|----------------|
| `users` | All accounts (customer, admin, cleaner) + loyalty fields |
| `bookings` | Every booking (service or custom) |
| `services` | Catalog services (name, price, image, duration) |
| `addresses` | Saved customer addresses |
| `promo_codes` | Discount codes (DEEP20, FIRST10…) |
| `add_ons` | Extra services (windows, oven…) |
| `notifications` | In-app messages per user |
| `cleaning_tips` | Daily tips shown on home screen |
| `cleaners` | Cleaner profiles (linked to users) |
| `reviews` | Ratings after completed jobs |

**ORM:** Sequelize models in `backend_node/src/models/`
**File on disk:** `backend_node/database.sqlite`

---

## 7. Loyalty Program (if asked)

- Every **completed** booking increments `loyalty_progress`
- After **4 completions** → user gets `loyalty_rewards_available += 1`, progress resets
- Reward can be redeemed on next **custom normal** cleaning (covers base price)
- Logic: `backend_node/src/utils/loyalty.js`

---

## 8. Pricing (if asked)

- **Normal cleaning:** $4/hour (from `settings.json`)
- **Deep cleaning:** $6/hour
- Hours estimated from room/bathroom/kitchen counts (custom) or service duration
- Add-ons add fixed prices from `add_ons` table
- Promos reduce total via `promoController.validate`
- Flutter mirrors logic in `utils/pricing.dart` for live UI updates

---

## 9. Flutter App Architecture

### Pattern: **Provider** (state management)

| Provider | Responsibility |
|----------|----------------|
| `AuthProvider` | Login state, user profile, token |
| `ServiceProvider` | List of cleaning services from API |
| `BookingProvider` | User's bookings, create/cancel |
| `AddressProvider` | Saved addresses CRUD |

### Screens map

| Screen | Route | Purpose |
|--------|-------|---------|
| SplashScreen | `/` (home) | 2s logo, check auth |
| OnboardingScreen | `/onboarding` | First-time intro slides |
| LoginScreen | `/login` | Email + Google login |
| RegisterScreen | `/register` | Sign up |
| HomeScreen | `/home` | 3 tabs: Home, Bookings, Profile |
| BookingScreen | `/booking` | Book one catalog service |
| CustomBookingScreen | `/custom-booking` | Build-your-own cleaning |
| ServiceAdvisorScreen | `/service-advisor` | AI quiz → recommendation |
| BookingConfirmationScreen | `/booking-confirmation` | Success after booking |
| BookingDetailsScreen | `/booking-details` | View/cancel one booking |
| MyAddressesScreen | `/addresses` | Manage saved addresses |
| NotificationsScreen | `/notifications` | In-app notification list |

### HomeScreen tabs

- **Tab 0 — Home:** carousel, hot offers, service grid, cleaning tip, AI planner CTA
- **Tab 1 — Bookings:** toggle List / Calendar
- **Tab 2 — Profile:** name, loyalty, addresses link, logout

---

## 10. Backend Architecture (MVC-style)

```
Request → Route → Middleware (auth?) → Controller → Model (DB) → JSON Response
```

| Folder | Role |
|--------|------|
| `routes/` | Defines URLs, attaches middleware |
| `controllers/` | Business logic (validate, calculate, save) |
| `models/` | Sequelize table schemas |
| `middleware/auth.js` | JWT verify + role check |
| `middleware/upload.js` | Multer for service images |
| `services/geminiService.js` | Calls Google Gemini API |

### Main route prefixes

| Prefix | Feature |
|--------|---------|
| `/api/auth` | Register, login, profile |
| `/api/services` | Public service catalog |
| `/api/bookings` | Create, list, cancel bookings |
| `/api/addresses` | Saved addresses |
| `/api/promo` | Hot offers, validate codes |
| `/api/addons` | Add-on list |
| `/api/cleaning-tips` | Tip of the day |
| `/api/ai` | Service recommendation |
| `/api/notifications` | User notifications |
| `/api/admin` | Everything for admin dashboard |

---

## 11. Admin Dashboard Architecture

| Page | What it does |
|------|--------------|
| Dashboard | Stats, charts, recent bookings |
| Bookings | List/filter/accept/cancel/complete |
| Customers | CRUD, block users |
| Services | CRUD + image upload |
| Promos | Promo code management |
| Add-ons | Extra services management |
| Cleaning Tips | Manage home-screen tips |
| Notifications | Admin notification inbox |
| Settings | Business rates, support info |
| Analytics | Charts (if enabled) |

**Auth:** `AuthContext.jsx` wraps app; `ProtectedRoute.jsx` redirects if no token
**API:** `services/api.js` — Axios with `Authorization: Bearer` from localStorage

---

## 12. External Services

| Service | Where | Purpose |
|---------|-------|---------|
| Firebase Auth | Flutter | Email/password + Google on device |
| Google Sign-In | Flutter | OAuth flow |
| Google tokeninfo | Backend | Verify Google id_token |
| Google Gemini | Backend | AI advisor summary text |
| (No payment gateway) | — | Bookings don't charge cards |
| (No push notifications) | — | Notifications are in-app DB only |

---

## 13. Key Dependencies (name-drop if asked)

**Flutter:** `provider`, `dio`, `firebase_core`, `firebase_auth`, `google_sign_in`, `table_calendar`, `shared_preferences`

**Backend:** `express`, `sequelize`, `sqlite3`, `jsonwebtoken`, `bcryptjs`, `multer`, `cors`, `dotenv`

**Admin:** `react`, `react-router-dom`, `axios`, `@mui/material`, `chart.js`, `vite`

---

## 14. Demo Script (recommended order)

1. **Start backend:** `cd backend_node && npm start` — show console "Server running"
2. **Start admin:** `cd admin_dashboard && npm run dev` — login as admin
3. **Run Flutter** on physical phone (same WiFi as PC)
4. **Show login/register** — mention Firebase + JWT
5. **Home tab** — services, cleaning tip, hot offers, AI planner
6. **AI planner** — answer quiz → recommendation → "Use This Plan" → custom booking
7. **Book a service** — pick date/time → confirmation
8. **Admin** — show pending booking → Accept
9. **App Bookings tab** — calendar with highlighted days → tap → see status accepted
10. **Profile** — loyalty progress, addresses

---

## 15. Likely Q&A — Memorize These

**Q: Why Flutter?**
A: Cross-platform (Android/iOS from one codebase), fast UI, good for mobile-first booking apps.

**Q: Why Node.js backend?**
A: JavaScript full-stack consistency, Express is lightweight REST, huge npm ecosystem.

**Q: Why SQLite?**
A: Simple file-based DB, no separate server needed, perfect for prototype/demo. Sequelize makes migration to PostgreSQL/MySQL easy.

**Q: How is security handled?**
A: Passwords bcrypt-hashed, JWT with secret expiry, role-based middleware, blocked users rejected at login.

**Q: How does the AI work?**
A: Rule engine picks cleaning type/hours/price deterministically; Gemini only writes the human-friendly explanation (optional if API key missing).

**Q: Difference between service booking and custom booking?**
A: Service booking uses a fixed catalog item. Custom lets user configure property size, deep vs normal, and add-ons. Custom bookings store `is_custom = true`.

**Q: How do promos work?**
A: Codes in `promo_codes` table with JSON conditions (e.g. first booking, deep cleaning only). Validated server-side before price finalization.

**Q: What happens when booking completes?**
A: Status → completed, loyalty milestone checked, customer notified.

---

## 16. Environment Variables (backend `.env`)

| Variable | Purpose |
|----------|---------|
| `JWT_SECRET` | Signs/verifies tokens |
| `JWT_EXPIRY` | Token lifetime (e.g. 7d) |
| `PORT` | Server port (5000) |
| `HOST` | 0.0.0.0 for phone access |
| `PUBLIC_BASE_URL` | Base URL for uploaded images |
| `GEMINI_API_KEY` | Google AI key |
| `GEMINI_MODEL` | e.g. gemini-2.5-flash |
| `NODE_ENV` | development enables debug routes |

---

## 17. File-by-File Quick Reference

See `CODE_MAP.md` in the same folder — every source file listed with a one-line explanation.

Every source file also has a **header comment block** at the top explaining its role in the system.

---

## 18. Presentation Cheat Sheet (print this)

```
STACK:     Flutter + Node/Express + React + SQLite + Firebase + Gemini
ARCH:      3-tier REST API, JWT auth, Provider state, Sequelize ORM
USERS:     customer (app), admin (dashboard), cleaner (API ready)
BOOKING:   pending → accepted → completed (+ loyalty)
PRICING:   $4/hr normal, $6/hr deep + add-ons - promos
AI:        Rules engine + Gemini summary → pre-fills custom booking
MOBILE IP: 192.168.1.107:5000 (NOT localhost on phone)
DB FILE:   backend_node/database.sqlite
```

**Opening line:**
"I developed Naddefli, a full-stack home cleaning platform with a Flutter customer app, Node.js REST API, SQLite database, React admin panel, Firebase authentication, and an AI-powered service advisor using Google Gemini."

Good luck — you know this system. The code is organized logically; this guide maps to it.
