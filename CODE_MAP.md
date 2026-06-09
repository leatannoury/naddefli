# Naddefli — File-by-File Code Map

Every source file with a one-line purpose. Header comments were added to each file in the codebase.

---

## Flutter — `frontend_flutter/lib/`

| File | Purpose |
|------|---------|
| `main.dart` | App entry: initializes Firebase, local storage, launches `NaddefliApp` |
| `app.dart` | Root widget: Provider setup + named route table for all screens |
| **screens/** | |
| `splash_screen.dart` | Splash logo; calls `AuthProvider.initializeAuth()` then routes to home or onboarding |
| `onboarding_screen.dart` | First-launch intro slides before login |
| `login_screen.dart` | Email/password + Google sign-in UI |
| `register_screen.dart` | New account registration form |
| `home_screen.dart` | Main hub with bottom nav: Home, Bookings, Profile tabs |
| `booking_screen.dart` | Book a single catalog service (date, time, address, promo) |
| `custom_booking_screen.dart` | Custom cleaning builder (rooms, type, add-ons, loyalty redeem) |
| `booking_confirmation_screen.dart` | Success screen after booking is created |
| `booking_details_screen.dart` | View one booking; cancel if pending |
| `my_addresses_screen.dart` | CRUD for saved delivery addresses |
| `notifications_screen.dart` | Lists in-app notifications from API |
| `service_advisor_screen.dart` | AI quiz UI → recommendation → pre-fill custom booking |
| **providers/** | |
| `auth_provider.dart` | Holds login state, token, user; calls auth services |
| `booking_provider.dart` | Holds user's bookings; create/cancel/fetch |
| `service_provider.dart` | Holds service catalog from API |
| `address_provider.dart` | Holds saved addresses |
| **services/** | |
| `http_service.dart` | Dio HTTP client; auto-attaches JWT Bearer token |
| `auth_service.dart` | Raw API calls: register, login, profile |
| `firebase_auth_service.dart` | Firebase email/Google auth then syncs with backend |
| `booking_service.dart` | API: create booking, my-bookings, cancel |
| `service_api_service.dart` | API: fetch services list |
| `address_service.dart` | API: address CRUD |
| `notification_service.dart` | API: fetch/mark notifications |
| `cleaning_tip_service.dart` | API: tip of the day |
| `ai_advisor_service.dart` | API: POST service-recommendation |
| `app_settings_service.dart` | API: public settings (rates, support phone) |
| **models/** | |
| `user.dart` | User data class (fromJson/toJson) |
| `booking.dart` | Booking data class + `displayTitle` for custom vs service |
| `service.dart` | Service catalog item |
| `address.dart` | Saved address |
| `booking_draft.dart` | Temporary plan from AI advisor → custom booking |
| `response_model.dart` | Generic API response wrapper |
| **widgets/** | |
| `booking_calendar_section.dart` | Calendar view with highlighted booking days |
| `booking_form_ui.dart` | Shared form components (headers, date/time pickers) |
| `cleaning_tip_card.dart` | Home screen daily tip card |
| **utils/** | |
| `constants.dart` | `BASE_URL`, all API endpoint paths |
| `storage_service.dart` | SharedPreferences: save/load JWT token and user |
| `app_styles.dart` | Colors, typography, card decorations |
| `pricing.dart` | Client-side price calculation for custom bookings |
| `image_utils.dart` | Builds full image URLs from API origin |

---

## Backend — `backend_node/src/`

| File | Purpose |
|------|---------|
| `index.js` | Express server setup, route mounting, DB migrations on startup |
| **config/** | |
| `db.js` | Sequelize connection to SQLite |
| `database.js` | Alternate DB config (documented for MSSQL) |
| `settings.json` | Business settings: hourly rates, support contact |
| **middleware/** | |
| `auth.js` | JWT verification + role-based authorization |
| `errorHandler.js` | Global Express error handler |
| `upload.js` | Multer config for service image uploads |
| **routes/** | |
| `authRoutes.js` | /register, /login, /google, /profile |
| `serviceRoutes.js` | GET services catalog |
| `bookingRoutes.js` | Create, list, cancel bookings |
| `addressRoutes.js` | Address CRUD |
| `promoRoutes.js` | Hot offers + validate promo |
| `addonRoutes.js` | Add-ons list + admin CRUD |
| `cleaningTipRoutes.js` | Tips public + admin CRUD |
| `notificationRoutes.js` | User notifications |
| `adminRoutes.js` | All admin dashboard endpoints |
| `cleanerRoutes.js` | Cleaner job management |
| `reviewRoutes.js` | Post-booking reviews |
| `aiRoutes.js` | AI service recommendation |
| **controllers/** | |
| `authController.js` | Register, login, Google OAuth, profile |
| `bookingController.js` | Create booking, pricing, loyalty, auto-complete |
| `serviceController.js` | List/get services |
| `addressController.js` | Address CRUD logic |
| `promoController.js` | Promo validation + hot offers |
| `addonController.js` | Add-on management |
| `cleaningTipController.js` | Cleaning tips CRUD + tip of day |
| `notificationController.js` | Notification list/mark read |
| `adminController.js` | Dashboard stats, booking management, customers, settings |
| `cleanerController.js` | Cleaner accept/status/earnings |
| `reviewController.js` | Create/list reviews |
| `aiController.js` | Orchestrates recommendation engine + Gemini |
| **models/** | |
| `index.js` | Exports all models + defines table associations |
| `User.js` | users table |
| `Booking.js` | bookings table |
| `Service.js` | services table |
| `Address.js` | addresses table |
| `PromoCode.js` | promo_codes table |
| `AddOn.js` | add_ons table |
| `CleaningTip.js` | cleaning_tips table |
| `Notification.js` | notifications table |
| `Cleaner.js` | cleaners table |
| `Review.js` | reviews table |
| **services/** | |
| `geminiService.js` | Calls Google Gemini API for AI text |
| **utils/** | |
| `helpers.js` | bcrypt, JWT, booking display names, formatters |
| `loyalty.js` | Loyalty milestone awards on completion |
| `response.js` | Standard success/error JSON helpers |
| `serviceRecommendationEngine.js` | Rule-based AI advisor logic |

---

## Admin — `admin_dashboard/src/`

| File | Purpose |
|------|---------|
| `main.jsx` | React DOM render entry |
| `App.jsx` | React Router routes for all admin pages |
| `services/api.js` | Axios client + all admin API functions |
| `contexts/AuthContext.jsx` | Admin login state + token in localStorage |
| `routes/ProtectedRoute.jsx` | Redirect to login if not authenticated |
| `layouts/MainLayout.jsx` | Sidebar + navbar wrapper for pages |
| **pages/** | |
| `Login.jsx` | Admin login form |
| `Dashboard.jsx` | Stats, charts, recent bookings |
| `Bookings.jsx` | Booking list with filters, accept/cancel/complete |
| `Customers.jsx` | Customer management |
| `Services.jsx` | Service CRUD + image upload |
| `Promos.jsx` | Promo code management |
| `Addons.jsx` | Add-on management |
| `CleaningTips.jsx` | Cleaning tips CRUD |
| `Notifications.jsx` | Admin notification inbox |
| `Settings.jsx` | Business settings editor |
| `Analytics.jsx` | Analytics charts |
| **components/** | |
| `Sidebar.jsx` | Left navigation menu |
| `Navbar.jsx` | Top bar with user info |
| `BookingDetails.jsx` | Modal with full booking info |
| `StatCard.jsx` | Dashboard metric card |
| `DateFilterBar.jsx` | Date range filter for lists |
| `LoadingScreen.jsx` | Full-page loading spinner |
| **utils/** | |
| `bookingDisplay.js` | Format booking title (custom vs service name) |
| `serviceImage.js` | Build image URL from API origin |
