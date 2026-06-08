import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/booking_form_ui.dart';

/// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  late PageController _pageController;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'A Cleaner Home,\nA Better Life',
      'description':
          'Book trusted home cleaning in Zahle with flexible scheduling and transparent pricing.',
      'icon': Icons.home_rounded,
      'colors': const [Color(0xFF0F766E), Color(0xFF14B8A6)],
    },
    {
      'title': 'Smart Booking,\nLess Stress',
      'description':
          'Choose a service or customize your clean with add-ons, duration, and instant estimates.',
      'icon': Icons.auto_awesome_rounded,
      'colors': const [Color(0xFF312E81), Color(0xFF6366F1)],
    },
    {
      'title': 'Trusted Cleaners,\nReal Rewards',
      'description':
          'Track bookings, earn loyalty rewards, and enjoy a spotless home on your schedule.',
      'icon': Icons.stars_rounded,
      'colors': const [Color(0xFF9A3412), Color(0xFFF97316)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppStyles.marginMobile),
                    child: _buildPage(
                      title: page['title'] as String,
                      description: page['description'] as String,
                      icon: page['icon'] as IconData,
                      colors: page['colors'] as List<Color>,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: _currentPage == index ? 22 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppStyles.radiusMedium),
                              ),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: BookingFormUi.primaryButtonStyle(),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 360,
          decoration: AppDecorations.gradientCard(colors: colors),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -36,
                top: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: Icon(
                  icon,
                  size: 88,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppStyles.paddingXLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Naddefli',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
