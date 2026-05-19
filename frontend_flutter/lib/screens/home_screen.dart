import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/booking_provider.dart';
import '../utils/app_styles.dart';

/// Home Screen
class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  int _bookingTabIndex = 0;
  int _heroPageIndex = 0;
  final PageController _heroPageController = PageController(viewportFraction: 0.92);
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _heroCards = [
    {
      'title': 'A Cleaner Home, A Better Life',
      'subtitle': 'Professional cleaning services at your fingertips',
      'button': 'Book Now',
    },
    {
      'title': 'Book Your Cleaning Now',
      'subtitle': 'Customize your cleaning and get an instant price estimate',
      'button': 'Get Started',
    },
    {
      'title': 'Professional Cleaners You Can Trust',
      'subtitle': 'Background-checked experts with 5-star ratings',
      'button': 'Explore Services',
    },
  ];

  final List<Map<String, String>> _offerCards = [
    {
      'title': '20% OFF Deep Cleaning',
      'subtitle': 'Save on premium deep cleaning plans.',
      'tag': 'Hot',
      'code': 'DEEP20',
    },
    {
      'title': 'First Booking Discount',
      'subtitle': 'Enjoy a welcome promo on your first order.',
      'tag': 'New',
      'code': 'FIRST10',
    },
    {
      'title': 'Free Window Add-on',
      'subtitle': 'Add windows cleaning to any service.',
      'tag': 'Free',
      'code': 'WINDOWFREE',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadServices();
      _loadBookings();
    });
  }

  void _loadServices() {
    context.read<ServiceProvider>().fetchServices();
  }

  void _loadBookings() {
    context.read<BookingProvider>().fetchMyBookings();
  }

  bool _isUpcomingBooking(dynamic booking, DateTime now) {
    try {
      final bookingStatus = booking.status ?? '';
      if (bookingStatus == 'cancelled' || bookingStatus == 'completed') {
        return false;
      }
      if (bookingStatus == 'pending' ||
          bookingStatus == 'accepted' ||
          bookingStatus == 'on_the_way' ||
          bookingStatus == 'started') {
        return true;
      }
      final dateStr =
          '${booking.bookingDate.toIso8601String().split('T').first}T${booking.bookingTime}';
      final dateTime = DateTime.tryParse(dateStr);
      return dateTime != null && dateTime.isAfter(now);
    } catch (e) {
      return false;
    }
  }


  @override
  void dispose() {
    _heroPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Naddefli',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              onPressed: () =>
                  Navigator.of(context).pushNamed('/custom-booking'),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildBookingsTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppStyles.paddingLarge),
          _buildHeroSection(),
          const SizedBox(height: AppStyles.paddingLarge),
          _buildQuickBookingCard(),
          const SizedBox(height: AppStyles.paddingLarge),
          _buildLoyaltyStreakCard(),
          const SizedBox(height: AppStyles.paddingLarge),
          _buildOffersSection(),
          const SizedBox(height: AppStyles.paddingXLarge),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppStyles.marginMobile,
              0,
              AppStyles.marginMobile,
              AppStyles.paddingSmall,
            ),
             child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Services Grid
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.marginMobile,
            ),
            child: Consumer<ServiceProvider>(
              builder: (context, serviceProvider, _) {
                if (serviceProvider.isLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (serviceProvider.services.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppStyles.paddingLarge),
                    child: Text(
                      'No services available',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: serviceProvider.services.length,
                  itemBuilder: (context, index) {
                    final service = serviceProvider.services[index];
                    return _buildServiceCard(context, service);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppStyles.paddingXLarge),

          // Social Proof Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.marginMobile,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
              ),
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: AppStyles.paddingSmall + 8,
                        height: AppStyles.paddingSmall + 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: AppStyles.paddingSmall + 8,
                        height: AppStyles.paddingSmall + 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: AppStyles.paddingSmall + 8,
                        height: AppStyles.paddingSmall + 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.paddingBase),
                  const Text(
                    'Trusted by 2,000+ local homes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),
                  Text(
                    'Our cleaning experts are background checked and highly rated.',
                    textAlign: TextAlign.center,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppStyles.paddingXLarge),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _heroPageController,
            itemCount: _heroCards.length,
            onPageChanged: (index) => setState(() => _heroPageIndex = index),
            itemBuilder: (context, index) {
              final card = _heroCards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary.withValues(alpha: 0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppStyles.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          card['title']!,
                          style: const TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          card['subtitle']!,
                          style: TextStyle(
                            color: AppColors.onPrimary.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            if (card['button'] == 'Book Now') {
                              Navigator.of(context)
                                  .pushNamed('/custom-booking');
                            } else {
                              Navigator.of(context)
                                  .pushReplacementNamed('/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            card['button']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppStyles.paddingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _heroCards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _heroPageIndex == index ? 20 : 10,
              height: 6,
              decoration: BoxDecoration(
                color: _heroPageIndex == index
                    ? AppColors.primary
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickBookingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.marginMobile),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book Your Cleaning Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize and get instant pricing',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/custom-booking'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.marginMobile,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hot Offers',
            style: AppStyles.headlineSmall,
          ),
          const SizedBox(height: AppStyles.paddingSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _offerCards.length,
                (index) {
                  final offer = _offerCards[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildOfferCard(offer),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyStreakCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final points = auth.user?.loyaltyPoints ?? 0;
        final streakProgress = points % 5;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.marginMobile),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x240D9488), blurRadius: 12, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Loyalty Milestones',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Total: $points pts',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final isCompleted = index < streakProgress;
                    final isGift = index == 4;

                    return Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isCompleted 
                                ? Colors.amber 
                                : Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? Colors.amber : Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isGift
                                ? Icon(
                                    Icons.card_giftcard,
                                    color: isCompleted ? Colors.white : Colors.white70,
                                    size: 20,
                                  )
                                : (isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isGift ? 'Reward' : 'Clean ${index + 1}',
                          style: TextStyle(
                            color: isCompleted ? Colors.amber : Colors.white70,
                            fontSize: 10,
                            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Text(
                  points >= 5 
                      ? '🎉 You unlocked a FREE standard hourly base clean!' 
                      : 'Complete ${5 - streakProgress} more standard booking(s) to unlock milestone 5!',
                  style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfferCard(Map<String, String> offer) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              offer['tag']!,
              style: AppStyles.labelBold.copyWith(
                color: AppColors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppStyles.paddingBase),
          Flexible(
            child: Text(
              offer['title']!,
              style: AppStyles.headlineSmall.copyWith(
                fontSize: 16,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppStyles.paddingSmall),
          Flexible(
            child: Text(
              offer['subtitle']!,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        const Icon(Icons.local_offer, color: Color(0xFF0D9488)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(offer['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer['subtitle']!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 16),
                        const Text('Use Coupon Code:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                offer['code']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5, color: Color(0xFF0D9488)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Color(0xFF64748B)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Coupon code ${offer['code']} copied to clipboard!')),
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Get Offer',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildServiceCard(BuildContext context, dynamic service) {
    return GestureDetector(
      onTap: () {
        context.read<ServiceProvider>().selectService(service);
        Navigator.of(context).pushNamed('/booking', arguments: service);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon Section
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.radiusLarge),
                  topRight: Radius.circular(AppStyles.radiusLarge),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.cleaning_services,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${service.basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        service.name ?? 'Service',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        service.description ?? 'Professional cleaning service',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.durationHours.toStringAsFixed(1)}h',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBookingsTab() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        if (bookingProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (bookingProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    bookingProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: bookingProvider.fetchMyBookings,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (bookingProvider.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: AppColors.gray.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text('No bookings yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                  child: const Text('Browse Services'),
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final List<dynamic> upcoming = bookingProvider.bookings
            .where((dynamic booking) => _isUpcomingBooking(booking, now))
            .toList();
        final List<dynamic> completed = bookingProvider.bookings
            .where((dynamic booking) => booking.status == 'completed')
            .toList();
        final List<dynamic> cancelled = bookingProvider.bookings
            .where((dynamic booking) => booking.status == 'cancelled')
            .toList();
        final visibleBookings = _bookingTabIndex == 0
            ? upcoming
            : _bookingTabIndex == 1
                ? completed
                : cancelled;

        return RefreshIndicator(
          onRefresh: bookingProvider.fetchMyBookings,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppStyles.paddingLarge),
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                ),
                child: Row(
                  children: [
                    _buildBookingTab('Upcoming', 0, upcoming.length),
                    _buildBookingTab('Completed', 1, completed.length),
                    _buildBookingTab('Cancelled', 2, cancelled.length),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (visibleBookings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppStyles.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  ),
                  child: Text(
                    _bookingTabIndex == 0
                        ? 'No upcoming bookings.'
                        : _bookingTabIndex == 1
                            ? 'No completed bookings yet.'
                            : 'No cancelled bookings.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...visibleBookings.map(_buildBookingCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingTab(String label, int index, int count) {
    final selected = _bookingTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _bookingTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final extrasString = booking.extras?.toString() ?? '';
    final List<String> extras = extrasString
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/booking-details', arguments: booking);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.isCustom
                        ? 'Custom cleaning request'
                        : booking.address,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking.getStatusLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${booking.bookingDate.toString().split(' ')[0]} at ${booking.bookingTime}',
              style: TextStyle(fontSize: 12, color: AppColors.darkGray),
            ),
            const SizedBox(height: 6),
            Text(
              '${booking.address}, ${booking.city}',
              style: const TextStyle(fontSize: 13),
            ),
            if (booking.isCustom) ...[
              const SizedBox(height: 8),
              Text(
                '${booking.propertyType ?? 'Property'} - ${booking.roomCount} rooms'
                '${booking.bathroomsCount > 0 ? ', ${booking.bathroomsCount} baths' : ''}'
                '${booking.kitchensCount > 0 ? ', ${booking.kitchensCount} kitchens' : ''}'
                ' - ${booking.cleaningType == 'deep' ? 'Deep' : 'Normal'}',
                style: TextStyle(fontSize: 12, color: AppColors.darkGray),
              ),
            ],
            if (extras.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: extras.take(3).map<Widget>((String extra) {
                  return Chip(
                    label: Text(extra, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '\$${booking.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Container(
                  padding: const EdgeInsets.all(AppStyles.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              authProvider.user?.fullName ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.email ?? '',
                              style: TextStyle(
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      _buildProfileOption(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () => _showEditProfileSheet(authProvider),
                      ),
                      _buildProfileOption(
                        icon: Icons.location_on_outlined,
                        title: 'My Addresses',
                        onTap: () => Navigator.of(context).pushNamed('/addresses'),
                      ),
                      _buildProfileOption(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        onTap: () => _showInfoSheet(
                          title: 'Payment Methods',
                          icon: Icons.payment_outlined,
                          message:
                              'Cash on service is active. Card payments can be added from the next app update.',
                        ),
                      ),
                      _buildProfileOption(
                        icon: Icons.history,
                        title: 'Transaction History',
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                      _buildProfileOption(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => _showInfoSheet(
                          title: 'Help & Support',
                          icon: Icons.help_outline,
                          message:
                              'For help, message support@naddefli.local or call +961 00 000 000.',
                        ),
                      ),
                      _buildProfileOption(
                        icon: Icons.info_outline,
                        title: 'About Naddefli',
                        onTap: () => _showInfoSheet(
                          title: 'About Naddefli',
                          icon: Icons.info_outline,
                          message:
                              'Naddefli connects customers with trusted cleaners for flexible home cleaning.',
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showEditProfileSheet(AuthProvider authProvider) {
    final nameController =
        TextEditingController(text: authProvider.user?.fullName ?? '');
    final phoneController =
        TextEditingController(text: authProvider.user?.phone ?? '');
    final emailController =
        TextEditingController(text: authProvider.user?.email ?? '');
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppStyles.paddingLarge,
            right: AppStyles.paddingLarge,
            top: AppStyles.paddingLarge,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                AppStyles.paddingLarge,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Profile', style: AppStyles.headlineSmall),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number.';
                    }
                    if (!RegExp(r'^\+?[0-9]{7,15}\$').hasMatch(value.trim())) {
                      return 'Enter a valid phone number.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      final success = await context.read<AuthProvider>().updateProfile(
                            fullName: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                          );
                      if (!mounted) return;
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Profile updated successfully'
                              : (context.read<AuthProvider>().error ??
                                  'Profile update failed')),
                          backgroundColor:
                              success ? AppColors.success : AppColors.error,
                        ),
                      );
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
    });
  }

  void _showInfoSheet({
    required String title,
    required IconData icon,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppStyles.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 40),
              const SizedBox(height: 12),
              Text(title, style: AppStyles.headlineSmall),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.darkGray),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppStyles.paddingBase,
            AppStyles.paddingSmall,
            AppStyles.paddingBase,
            AppStyles.paddingBase,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home, 'Home'),
              _buildBottomNavItem(1, Icons.calendar_month, 'Bookings'),
              _buildBottomNavItem(2, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingLarge,
          vertical: AppStyles.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppStyles.paddingXSmall),
            Text(
              label,
              style: AppStyles.labelBold.copyWith(
                color: isActive
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.gray;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
