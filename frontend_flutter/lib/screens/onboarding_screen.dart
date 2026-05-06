import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  late PageController _pageController;

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

  final List<Map<String, String>> _pages = [
    {
      'title': 'Book Cleaning Services',
      'description': 'Find and book trusted cleaners in your area',
      'icon': '🏠',
    },
    {
      'title': 'Trusted Professionals',
      'description': 'All cleaners are verified and rated by customers',
      'icon': '⭐',
    },
    {
      'title': 'Easy Payment',
      'description': 'Secure and flexible payment options available',
      'icon': '💳',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(
                    title: _pages[index]['title']!,
                    description: _pages[index]['description']!,
                    icon: _pages[index]['icon']!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.lightGray,
                          borderRadius:
                              BorderRadius.circular(AppStyles.radiusSmall),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
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
    required String icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: AppStyles.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.paddingLarge),
          child: Text(
            description,
            style: AppStyles.bodyMedium.copyWith(color: AppColors.darkGray),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
