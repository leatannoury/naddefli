/**
 * One-time script: prepends educational header comments to all Naddefli source files.
 * Run: node add-code-headers.js
 */
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;

const HEADERS = {
  // Flutter
  'frontend_flutter/lib/main.dart': {
    layer: 'Flutter Mobile App — ENTRY POINT',
    purpose: 'Starts the app: initializes Firebase, local storage, then runs NaddefliApp.',
    talks: 'Firebase SDK, StorageService, app.dart',
  },
  'frontend_flutter/lib/app.dart': {
    layer: 'Flutter Mobile App — ROOT WIDGET',
    purpose: 'Sets up Provider state management and defines all named routes (screens).',
    talks: 'All providers and screens via Navigator routes',
  },
  'frontend_flutter/lib/screens/splash_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Shows splash logo for 2 seconds, checks saved JWT token, routes to Home or Onboarding.',
    talks: 'AuthProvider.initializeAuth()',
  },
  'frontend_flutter/lib/screens/onboarding_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'First-time user intro slides explaining the app before login.',
    talks: 'Navigates to /login',
  },
  'frontend_flutter/lib/screens/login_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Login UI: email/password and Google Sign-In buttons.',
    talks: 'AuthProvider → FirebaseAuthService → POST /api/auth/login or /google',
  },
  'frontend_flutter/lib/screens/register_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Registration form: name, email, phone, password.',
    talks: 'AuthProvider → Firebase + POST /api/auth/register',
  },
  'frontend_flutter/lib/screens/home_screen.dart': {
    layer: 'Flutter — Screen (MAIN HUB)',
    purpose: 'Bottom navigation with 3 tabs: Home (services/offers), Bookings (list/calendar), Profile.',
    talks: 'ServiceProvider, BookingProvider, navigates to all booking flows',
  },
  'frontend_flutter/lib/screens/booking_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Book a catalog service: pick date, time, address, optional promo code.',
    talks: 'POST /api/bookings/create via BookingProvider',
  },
  'frontend_flutter/lib/screens/custom_booking_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Custom cleaning builder: property type, room counts, deep/normal, add-ons, loyalty redeem.',
    talks: 'POST /api/bookings/create with is_custom=true; can be pre-filled from BookingDraft (AI)',
  },
  'frontend_flutter/lib/screens/booking_confirmation_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Success page shown after a booking is created.',
    talks: 'Receives Booking object via route arguments',
  },
  'frontend_flutter/lib/screens/booking_details_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'View full booking details; customer can cancel if status is pending.',
    talks: 'PUT /api/bookings/cancel/:id',
  },
  'frontend_flutter/lib/screens/my_addresses_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'List, add, edit, delete saved addresses.',
    talks: '/api/addresses via AddressProvider',
  },
  'frontend_flutter/lib/screens/notifications_screen.dart': {
    layer: 'Flutter — Screen',
    purpose: 'Shows in-app notifications (booking updates, etc.).',
    talks: '/api/notifications',
  },
  'frontend_flutter/lib/screens/service_advisor_screen.dart': {
    layer: 'Flutter — Screen (AI FEATURE)',
    purpose: 'Quiz UI for AI Cleaning Planner; shows recommendation; "Use This Plan" opens custom booking.',
    talks: 'POST /api/ai/service-recommendation → BookingDraft → CustomBookingScreen',
  },
  'frontend_flutter/lib/providers/auth_provider.dart': {
    layer: 'Flutter — State (Provider)',
    purpose: 'Manages login state: user object, JWT token, loading/error. Calls auth services.',
    talks: 'FirebaseAuthService, StorageService, GET /api/auth/profile',
  },
  'frontend_flutter/lib/providers/booking_provider.dart': {
    layer: 'Flutter — State (Provider)',
    purpose: 'Holds user bookings list; create and cancel booking operations.',
    talks: 'BookingService → /api/bookings/*',
  },
  'frontend_flutter/lib/providers/service_provider.dart': {
    layer: 'Flutter — State (Provider)',
    purpose: 'Loads and caches the service catalog from the API.',
    talks: 'ServiceApiService → GET /api/services',
  },
  'frontend_flutter/lib/providers/address_provider.dart': {
    layer: 'Flutter — State (Provider)',
    purpose: 'Manages saved addresses state for the current user.',
    talks: 'AddressService → /api/addresses',
  },
  'frontend_flutter/lib/services/http_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'Dio HTTP client wrapper. AuthInterceptor auto-adds Bearer JWT to every request.',
    talks: 'All API calls go through this; reads token from StorageService',
  },
  'frontend_flutter/lib/services/auth_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'Low-level API calls for register, login, get/update profile.',
    talks: 'HttpService → /api/auth/*',
  },
  'frontend_flutter/lib/services/firebase_auth_service.dart': {
    layer: 'Flutter — Service (Firebase)',
    purpose: 'Firebase email/password and Google Sign-In, then syncs user with backend API.',
    talks: 'firebase_auth, google_sign_in → backend /api/auth/register|login|google',
  },
  'frontend_flutter/lib/services/booking_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'API calls: create booking, fetch my-bookings, cancel booking.',
    talks: 'HttpService → /api/bookings/*',
  },
  'frontend_flutter/lib/services/service_api_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'Fetches service catalog from backend.',
    talks: 'GET /api/services',
  },
  'frontend_flutter/lib/services/address_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'CRUD API calls for saved addresses.',
    talks: '/api/addresses',
  },
  'frontend_flutter/lib/services/notification_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'Fetch notifications and mark as read.',
    talks: '/api/notifications',
  },
  'frontend_flutter/lib/services/cleaning_tip_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'Fetches tip-of-the-day for home screen.',
    talks: 'GET /api/cleaning-tips/tip-of-the-day',
  },
  'frontend_flutter/lib/services/ai_advisor_service.dart': {
    layer: 'Flutter — Service (AI)',
    purpose: 'Sends quiz answers to backend AI recommendation endpoint.',
    talks: 'POST /api/ai/service-recommendation',
  },
  'frontend_flutter/lib/services/app_settings_service.dart': {
    layer: 'Flutter — Service',
    purpose: 'Fetches public business settings (hourly rates, support contact).',
    talks: 'GET /api/settings/public',
  },
  'frontend_flutter/lib/models/user.dart': {
    layer: 'Flutter — Model',
    purpose: 'Data class representing a user (id, name, email, loyalty fields). fromJson/toJson.',
    talks: 'Parsed from /api/auth responses',
  },
  'frontend_flutter/lib/models/booking.dart': {
    layer: 'Flutter — Model',
    purpose: 'Data class for a booking. displayTitle shows custom vs service name correctly.',
    talks: 'Parsed from /api/bookings responses',
  },
  'frontend_flutter/lib/models/service.dart': {
    layer: 'Flutter — Model',
    purpose: 'Data class for a catalog cleaning service.',
    talks: 'Parsed from GET /api/services',
  },
  'frontend_flutter/lib/models/address.dart': {
    layer: 'Flutter — Model',
    purpose: 'Data class for a saved customer address.',
    talks: 'Parsed from /api/addresses',
  },
  'frontend_flutter/lib/models/booking_draft.dart': {
    layer: 'Flutter — Model',
    purpose: 'Temporary cleaning plan from AI advisor, passed to CustomBookingScreen to pre-fill form.',
    talks: 'ServiceAdvisorScreen → CustomBookingScreen',
  },
  'frontend_flutter/lib/models/response_model.dart': {
    layer: 'Flutter — Model',
    purpose: 'Generic wrapper for API responses { success, data, message }.',
    talks: 'Used by services parsing JSON',
  },
  'frontend_flutter/lib/widgets/booking_calendar_section.dart': {
    layer: 'Flutter — Widget',
    purpose: 'Calendar view in Bookings tab; purple highlight on days with bookings; tap to see list.',
    talks: 'table_calendar package; receives bookings list from parent',
  },
  'frontend_flutter/lib/widgets/booking_form_ui.dart': {
    layer: 'Flutter — Widget',
    purpose: 'Shared UI components for booking forms (gradient headers, date/time pickers, cards).',
    talks: 'Used by booking_screen and custom_booking_screen',
  },
  'frontend_flutter/lib/widgets/cleaning_tip_card.dart': {
    layer: 'Flutter — Widget',
    purpose: 'Card on home screen showing daily cleaning tip with gradient background.',
    talks: 'CleaningTipService data',
  },
  'frontend_flutter/lib/utils/constants.dart': {
    layer: 'Flutter — Config',
    purpose: 'BASE_URL (API address) and ApiEndpoints class with all REST paths. CHANGE IP HERE for phone testing.',
    talks: 'Used by every service file',
  },
  'frontend_flutter/lib/utils/storage_service.dart': {
    layer: 'Flutter — Utility',
    purpose: 'Saves/loads JWT token and user data on phone using SharedPreferences.',
    talks: 'AuthProvider, HttpService AuthInterceptor',
  },
  'frontend_flutter/lib/utils/app_styles.dart': {
    layer: 'Flutter — Utility',
    purpose: 'AppColors, typography, card decorations — consistent visual design.',
    talks: 'Used by all screens and widgets',
  },
  'frontend_flutter/lib/utils/pricing.dart': {
    layer: 'Flutter — Utility',
    purpose: 'Client-side price calculation for custom bookings (hours × rate + add-ons).',
    talks: 'Mirrors backend pricing logic for live UI updates',
  },
  'frontend_flutter/lib/utils/image_utils.dart': {
    layer: 'Flutter — Utility',
    purpose: 'Builds full image URLs from API_ORIGIN + relative upload path.',
    talks: 'Service images from /uploads',
  },

  // Backend
  'backend_node/src/index.js': {
    layer: 'Backend API — ENTRY POINT',
    purpose: 'Express server: mounts all routes, CORS, static uploads, DB migration on startup, listens on PORT.',
    talks: 'All route files, Sequelize, database.sqlite',
  },
  'backend_node/src/config/db.js': {
    layer: 'Backend — Config',
    purpose: 'Creates Sequelize instance connected to SQLite database file.',
    talks: 'database.sqlite',
  },
  'backend_node/src/config/database.js': {
    layer: 'Backend — Config',
    purpose: 'Alternate database configuration (documented for MSSQL; SQLite used in practice).',
    talks: 'Sequelize CLI migrations',
  },
  'backend_node/src/middleware/auth.js': {
    layer: 'Backend — Middleware',
    purpose: 'authMiddleware: verifies JWT from Authorization header. authorizationMiddleware: checks user role.',
    talks: 'Every protected route uses these',
  },
  'backend_node/src/middleware/errorHandler.js': {
    layer: 'Backend — Middleware',
    purpose: 'Global Express error handler; returns consistent JSON error responses.',
    talks: 'Last middleware in index.js',
  },
  'backend_node/src/middleware/upload.js': {
    layer: 'Backend — Middleware',
    purpose: 'Multer file upload config for service images → public/uploads/',
    talks: 'Admin service image upload',
  },
  'backend_node/src/routes/authRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'Maps /api/auth URLs to authController (register, login, google, profile).',
    talks: 'authController.js',
  },
  'backend_node/src/routes/serviceRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'GET /api/services — public service catalog.',
    talks: 'serviceController.js',
  },
  'backend_node/src/routes/bookingRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'POST create, GET my-bookings, PUT cancel — customer booking endpoints.',
    talks: 'bookingController.js + authMiddleware',
  },
  'backend_node/src/routes/addressRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'CRUD routes for /api/addresses.',
    talks: 'addressController.js',
  },
  'backend_node/src/routes/promoRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'Hot offers (public) and promo validation.',
    talks: 'promoController.js',
  },
  'backend_node/src/routes/addonRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'Add-ons list (public) and admin CRUD.',
    talks: 'addonController.js',
  },
  'backend_node/src/routes/cleaningTipRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'Cleaning tips public + admin CRUD.',
    talks: 'cleaningTipController.js',
  },
  'backend_node/src/routes/notificationRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'User notification list and mark-read.',
    talks: 'notificationController.js',
  },
  'backend_node/src/routes/adminRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'All /api/admin/* routes: dashboard, bookings, customers, services, promos, settings.',
    talks: 'adminController.js + admin role check',
  },
  'backend_node/src/routes/cleanerRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'Cleaner job accept, status updates, earnings.',
    talks: 'cleanerController.js',
  },
  'backend_node/src/routes/reviewRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'Create and list cleaner reviews.',
    talks: 'reviewController.js',
  },
  'backend_node/src/routes/aiRoutes.js': {
    layer: 'Backend — Routes',
    purpose: 'POST /api/ai/service-recommendation — AI cleaning planner.',
    talks: 'aiController.js',
  },
  'backend_node/src/controllers/authController.js': {
    layer: 'Backend — Controller',
    purpose: 'Register (bcrypt hash), login, Google OAuth verify, get/update profile.',
    talks: 'User model, JWT via helpers.js',
  },
  'backend_node/src/controllers/bookingController.js': {
    layer: 'Backend — Controller (CORE BUSINESS)',
    purpose: 'Create booking with price calc, promo, loyalty; list bookings; cancel; auto-complete past jobs.',
    talks: 'Booking, User, Service, Notification models; loyalty.js',
  },
  'backend_node/src/controllers/serviceController.js': {
    layer: 'Backend — Controller',
    purpose: 'List and get single service from catalog.',
    talks: 'Service model',
  },
  'backend_node/src/controllers/addressController.js': {
    layer: 'Backend — Controller',
    purpose: 'Address CRUD for logged-in customer.',
    talks: 'Address model',
  },
  'backend_node/src/controllers/promoController.js': {
    layer: 'Backend — Controller',
    purpose: 'Validate promo codes, apply discounts, list hot offers.',
    talks: 'PromoCode model',
  },
  'backend_node/src/controllers/addonController.js': {
    layer: 'Backend — Controller',
    purpose: 'List active add-ons; admin CRUD.',
    talks: 'AddOn model',
  },
  'backend_node/src/controllers/cleaningTipController.js': {
    layer: 'Backend — Controller',
    purpose: 'Tip of the day rotation; admin tips CRUD.',
    talks: 'CleaningTip model',
  },
  'backend_node/src/controllers/notificationController.js': {
    layer: 'Backend — Controller',
    purpose: 'List notifications, unread count, mark read.',
    talks: 'Notification model',
  },
  'backend_node/src/controllers/adminController.js': {
    layer: 'Backend — Controller (ADMIN)',
    purpose: 'Dashboard stats, booking accept/cancel/complete, customer CRUD, services, promos, settings.',
    talks: 'Most models; settings.json',
  },
  'backend_node/src/controllers/cleanerController.js': {
    layer: 'Backend — Controller',
    purpose: 'Cleaner accepts jobs, updates status, views earnings.',
    talks: 'Booking, Cleaner models',
  },
  'backend_node/src/controllers/reviewController.js': {
    layer: 'Backend — Controller',
    purpose: 'Create review after completed booking; list cleaner reviews.',
    talks: 'Review model',
  },
  'backend_node/src/controllers/aiController.js': {
    layer: 'Backend — Controller (AI)',
    purpose: 'Receives quiz answers, runs rule engine, optionally calls Gemini for summary text.',
    talks: 'serviceRecommendationEngine.js, geminiService.js',
  },
  'backend_node/src/models/index.js': {
    layer: 'Backend — Models',
    purpose: 'Exports all Sequelize models and defines table relationships (User has many Bookings, etc.).',
    talks: 'All model files',
  },
  'backend_node/src/models/User.js': {
    layer: 'Backend — Model (DB Table: users)',
    purpose: 'User schema: name, email, bcrypt password, role, loyalty fields, is_blocked.',
    talks: 'Central to auth and bookings',
  },
  'backend_node/src/models/Booking.js': {
    layer: 'Backend — Model (DB Table: bookings)',
    purpose: 'Booking schema: dates, address, price, status, custom fields, promo, loyalty flags.',
    talks: 'Core business entity',
  },
  'backend_node/src/models/Service.js': {
    layer: 'Backend — Model (DB Table: services)',
    purpose: 'Service catalog: name, price, duration, image, add_ons JSON, is_active.',
    talks: 'Referenced by bookings',
  },
  'backend_node/src/models/Address.js': {
    layer: 'Backend — Model (DB Table: addresses)',
    purpose: 'Saved customer addresses.',
    talks: 'Belongs to User',
  },
  'backend_node/src/models/PromoCode.js': {
    layer: 'Backend — Model (DB Table: promo_codes)',
    purpose: 'Promo codes with type, value, JSON conditions, expiry.',
    talks: 'Used in booking price calculation',
  },
  'backend_node/src/models/AddOn.js': {
    layer: 'Backend — Model (DB Table: add_ons)',
    purpose: 'Extra cleaning services with price.',
    talks: 'Custom bookings extras field',
  },
  'backend_node/src/models/CleaningTip.js': {
    layer: 'Backend — Model (DB Table: cleaning_tips)',
    purpose: 'Daily tips shown on app home screen.',
    talks: 'Public API + admin CRUD',
  },
  'backend_node/src/models/Notification.js': {
    layer: 'Backend — Model (DB Table: notifications)',
    purpose: 'In-app notifications per user.',
    talks: 'Created on booking events',
  },
  'backend_node/src/models/Cleaner.js': {
    layer: 'Backend — Model (DB Table: cleaners)',
    purpose: 'Cleaner profile linked to User (experience, rating, availability).',
    talks: 'Assigned to bookings',
  },
  'backend_node/src/models/Review.js': {
    layer: 'Backend — Model (DB Table: reviews)',
    purpose: 'Customer ratings for cleaners after completed jobs.',
    talks: 'Booking, User, Cleaner',
  },
  'backend_node/src/services/geminiService.js': {
    layer: 'Backend — External Service',
    purpose: 'Calls Google Gemini API to generate friendly AI advisor summary text.',
    talks: 'GEMINI_API_KEY env var; used by aiController',
  },
  'backend_node/src/utils/helpers.js': {
    layer: 'Backend — Utility',
    purpose: 'bcrypt password hash, JWT generate/verify, booking display name formatting.',
    talks: 'Used across controllers',
  },
  'backend_node/src/utils/loyalty.js': {
    layer: 'Backend — Utility',
    purpose: 'Awards loyalty milestones: every 4 completed bookings → 1 free reward.',
    talks: 'Called when booking marked completed',
  },
  'backend_node/src/utils/response.js': {
    layer: 'Backend — Utility',
    purpose: 'Standardized success/error JSON response helpers.',
    talks: 'Controllers',
  },
  'backend_node/src/utils/serviceRecommendationEngine.js': {
    layer: 'Backend — Utility (AI Rules)',
    purpose: 'Deterministic rule engine: quiz answers → cleaning type, hours, price estimate.',
    talks: 'aiController before Gemini call',
  },

  // Admin
  'admin_dashboard/src/main.jsx': {
    layer: 'Admin Dashboard — ENTRY POINT',
    purpose: 'Renders React app into DOM.',
    talks: 'App.jsx',
  },
  'admin_dashboard/src/App.jsx': {
    layer: 'Admin Dashboard — ROOT',
    purpose: 'React Router: defines all admin page routes, wraps with AuthProvider.',
    talks: 'All pages in src/pages/',
  },
  'admin_dashboard/src/services/api.js': {
    layer: 'Admin — API Client',
    purpose: 'Axios instance with JWT from localStorage; all admin API functions.',
    talks: 'All /api/admin/* endpoints',
  },
  'admin_dashboard/src/contexts/AuthContext.jsx': {
    layer: 'Admin — State',
    purpose: 'Admin login state, token storage in localStorage, logout.',
    talks: 'POST /api/admin/login',
  },
  'admin_dashboard/src/routes/ProtectedRoute.jsx': {
    layer: 'Admin — Route Guard',
    purpose: 'Redirects to /login if admin is not authenticated.',
    talks: 'AuthContext',
  },
  'admin_dashboard/src/layouts/MainLayout.jsx': {
    layer: 'Admin — Layout',
    purpose: 'Sidebar + Navbar wrapper around page content.',
    talks: 'Sidebar, Navbar components',
  },
  'admin_dashboard/src/pages/Login.jsx': {
    layer: 'Admin — Page',
    purpose: 'Admin login form.',
    talks: 'AuthContext → POST /api/admin/login',
  },
  'admin_dashboard/src/pages/Dashboard.jsx': {
    layer: 'Admin — Page',
    purpose: 'Overview: stats cards, charts, recent bookings.',
    talks: 'GET /api/admin/dashboard',
  },
  'admin_dashboard/src/pages/Bookings.jsx': {
    layer: 'Admin — Page',
    purpose: 'All bookings list with date/status filters; accept, cancel, complete actions.',
    talks: '/api/admin/bookings',
  },
  'admin_dashboard/src/pages/Customers.jsx': {
    layer: 'Admin — Page',
    purpose: 'Customer list, detail, create, edit, block, delete.',
    talks: '/api/admin/customers',
  },
  'admin_dashboard/src/pages/Services.jsx': {
    layer: 'Admin — Page',
    purpose: 'Service catalog CRUD and image upload.',
    talks: '/api/admin/services',
  },
  'admin_dashboard/src/pages/Promos.jsx': {
    layer: 'Admin — Page',
    purpose: 'Promo code management.',
    talks: '/api/admin/promos',
  },
  'admin_dashboard/src/pages/Addons.jsx': {
    layer: 'Admin — Page',
    purpose: 'Add-on services management.',
    talks: '/api/addons/admin',
  },
  'admin_dashboard/src/pages/CleaningTips.jsx': {
    layer: 'Admin — Page',
    purpose: 'Manage cleaning tips shown in mobile app.',
    talks: '/api/cleaning-tips/admin',
  },
  'admin_dashboard/src/pages/Notifications.jsx': {
    layer: 'Admin — Page',
    purpose: 'Admin notification inbox (pending bookings alert).',
    talks: '/api/admin/notifications',
  },
  'admin_dashboard/src/pages/Settings.jsx': {
    layer: 'Admin — Page',
    purpose: 'Edit business settings: hourly rates, support contact.',
    talks: 'GET/PUT /api/admin/settings',
  },
  'admin_dashboard/src/pages/Analytics.jsx': {
    layer: 'Admin — Page',
    purpose: 'Analytics charts and reports.',
    talks: 'Dashboard/analytics API data',
  },
  'admin_dashboard/src/components/Sidebar.jsx': {
    layer: 'Admin — Component',
    purpose: 'Left navigation menu linking to all admin pages.',
    talks: 'React Router NavLink',
  },
  'admin_dashboard/src/components/Navbar.jsx': {
    layer: 'Admin — Component',
    purpose: 'Top bar with admin name and logout.',
    talks: 'AuthContext',
  },
  'admin_dashboard/src/components/BookingDetails.jsx': {
    layer: 'Admin — Component',
    purpose: 'Modal showing full booking details for admin review.',
    talks: 'Bookings page',
  },
  'admin_dashboard/src/components/StatCard.jsx': {
    layer: 'Admin — Component',
    purpose: 'Reusable metric card for dashboard stats.',
    talks: 'Dashboard page',
  },
  'admin_dashboard/src/components/DateFilterBar.jsx': {
    layer: 'Admin — Component',
    purpose: 'Date range picker for filtering booking/customer lists.',
    talks: 'Bookings, Dashboard pages',
  },
  'admin_dashboard/src/components/LoadingScreen.jsx': {
    layer: 'Admin — Component',
    purpose: 'Full-page loading spinner while data fetches.',
    talks: 'Used across pages',
  },
  'admin_dashboard/src/utils/bookingDisplay.js': {
    layer: 'Admin — Utility',
    purpose: 'Formats booking title: shows "Custom Cleaning (Deep)" vs service name correctly.',
    talks: 'Bookings page, BookingDetails',
  },
  'admin_dashboard/src/utils/serviceImage.js': {
    layer: 'Admin — Utility',
    purpose: 'Builds full image URL from API base + upload path.',
    talks: 'Services page',
  },
};

const MARKER = 'NADDEFLI —';

function buildHeader(relPath, info, ext) {
  const name = path.basename(relPath);
  if (ext === '.dart') {
    return `// =============================================================================
// ${MARKER} ${name}
// Layer: ${info.layer}
// Purpose: ${info.purpose}
// Connects to: ${info.talks}
// =============================================================================

`;
  }
  return `/**
 * ${MARKER} ${name}
 * Layer: ${info.layer}
 * Purpose: ${info.purpose}
 * Connects to: ${info.talks}
 */

`;
}

let updated = 0;
let skipped = 0;

for (const [relPath, info] of Object.entries(HEADERS)) {
  const fullPath = path.join(ROOT, relPath);
  if (!fs.existsSync(fullPath)) {
    console.warn('Missing:', relPath);
    skipped++;
    continue;
  }
  const content = fs.readFileSync(fullPath, 'utf8');
  if (content.includes(MARKER)) {
    skipped++;
    continue;
  }
  const ext = path.extname(relPath);
  const header = buildHeader(relPath, info, ext);
  fs.writeFileSync(fullPath, header + content, 'utf8');
  updated++;
  console.log('✓', relPath);
}

console.log(`\nDone: ${updated} updated, ${skipped} skipped (already had header or missing)`);
