import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'utils/storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'models/service.dart';

/// Main App Widget
class NaddefliApp extends StatelessWidget {
  const NaddefliApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Naddefli',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) =>
              const SplashScreen(),
          '/onboarding': (context) =>
              const OnboardingScreen(),
          '/login': (context) =>
              const LoginScreen(),
          '/register': (context) =>
              const RegisterScreen(),
          '/home': (context) =>
              const HomeScreen(),
          '/booking': (context) {
            final service =
                ModalRoute.of(context)
                    ?.settings
                    .arguments;
            return BookingScreen(
              service: service as Service,
            );
          },
        },
      ),
    );
  }
}
