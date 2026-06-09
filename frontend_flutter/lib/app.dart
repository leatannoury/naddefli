// =============================================================================
// NADDEFLI — app.dart
// Layer: Flutter Mobile App — ROOT WIDGET
// Purpose: Sets up Provider state management and defines all named routes (screens).
// Connects to: All providers and screens via Navigator routes
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/address_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/custom_booking_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/my_addresses_screen.dart';
import 'screens/booking_details_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/service_advisor_screen.dart';
import 'models/booking.dart';
import 'models/service.dart';

/// Main App Widget
class NaddefliApp extends StatelessWidget {
  const NaddefliApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider = app-wide state. Any screen can read/update via context.read/watch.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // login, user, token
        ChangeNotifierProvider(create: (_) => ServiceProvider()), // service catalog
        ChangeNotifierProvider(create: (_) => BookingProvider()), // user's bookings
        ChangeNotifierProvider(create: (_) => AddressProvider()), // saved addresses
      ],
      child: MaterialApp(
        title: 'Naddefli',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // First screen shown — checks if user is already logged in
        home: const SplashScreen(),
        // Named routes: Navigator.pushNamed(context, '/booking', arguments: service)
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) {
            final tabIndex = ModalRoute.of(context)?.settings.arguments;
            return HomeScreen(
              initialTabIndex: tabIndex is int ? tabIndex : 0,
            );
          },
          '/booking': (context) {
            final service = ModalRoute.of(context)?.settings.arguments;
            return BookingScreen(
              service: service as Service,
            );
          },
          '/custom-booking': (context) => const CustomBookingScreen(),
          '/booking-confirmation': (context) {
            final booking = ModalRoute.of(context)?.settings.arguments;
            return BookingConfirmationScreen(booking: booking as Booking);
          },
          '/addresses': (context) => const MyAddressesScreen(),
          '/booking-details': (context) {
            final booking = ModalRoute.of(context)?.settings.arguments;
            return BookingDetailsScreen(booking: booking as Booking);
          },
          '/notifications': (context) => const NotificationsScreen(),
          '/service-advisor': (context) => const ServiceAdvisorScreen(),
        },
      ),
    );
  }
}
