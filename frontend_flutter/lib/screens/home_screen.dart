import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/booking_provider.dart';
import '../utils/app_styles.dart';
import '../utils/image_utils.dart';
import '../services/app_settings_service.dart';
import '../services/cleaning_tip_service.dart';
import '../services/notification_service.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';
import '../widgets/cleaning_tip_card.dart';
import '../widgets/booking_calendar_section.dart';

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
  int _bookingViewMode = 0; // 0 = list, 1 = calendar
  int _heroPageIndex = 0;
  final PageController _heroPageController =
      PageController(viewportFraction: 0.92);
  final ScrollController _homeScrollController = ScrollController();
  final GlobalKey _servicesSectionKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _appSettings = {
    'supportPhone': '+961 00 000 000',
    'supportEmail': 'support@naddefli.local',
  };
  int _unreadNotifications = 0;
  Map<String, dynamic>? _cleaningTip;
  bool _cleaningTipLoading = true;

  final List<Map<String, dynamic>> _heroCards = [
    {
      'title': 'A Cleaner Home, A Better Life',
      'subtitle':
          'Trusted home cleaning that gives you more time for what matters.',
      'icon': Icons.auto_awesome,
      'colors': const [Color(0xFF0F766E), Color(0xFF14B8A6)],
    },
    {
      'title': 'Book Your Cleaning Now',
      'subtitle':
          'Choose your schedule, cleaning type, and extras in a few simple steps.',
      'button': 'Customize & Book',
      'action': 'book',
      'icon': Icons.calendar_month_rounded,
      'colors': const [Color(0xFF312E81), Color(0xFF6366F1)],
    },
    {
      'title': 'Explore Our Services',
      'subtitle':
          'Find the right cleaning service for every room and every need.',
      'button': 'Explore Services',
      'action': 'services',
      'icon': Icons.cleaning_services_rounded,
      'colors': const [Color(0xFF9A3412), Color(0xFFF97316)],
    },
  ];

  List<Map<String, String>> _offerCards = [];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadServices();
      _loadBookings();
      _loadAppSettings();
      _loadUnreadNotifications();
      _loadHotOffers();
      _loadCleaningTip();
    });
  }

  Future<void> _loadCleaningTip() async {
    setState(() => _cleaningTipLoading = true);
    final tip = await CleaningTipService.getTipOfTheDay(forceRefresh: true);
    if (mounted) {
      setState(() {
        _cleaningTip = tip;
        _cleaningTipLoading = false;
      });
    }
  }

  Future<void> _loadHotOffers() async {
    try {
      final response = await HttpService.get(
          '${ApiEndpoints.baseOrigin}/api/promo/hot-offers');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<Map<String, String>> offers = [];
        for (var item in data) {
          offers.add({
            'title': (item['description'] ??
                    '${item['value']}${item['type'] == 'percentage' ? '%' : '\$'} OFF')
                .toString(),
            'subtitle':
                'Use code ${item['code']} for ${item['type'] == 'percentage' ? 'a ${item['value']}% discount' : 'a \$${item['value']} discount'}.',
            'tag': 'Hot',
            'code': item['code'].toString(),
          });
        }
        if (mounted) {
          setState(() {
            _offerCards = offers;
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load hot offers: $e');
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final count = await NotificationService.fetchUnreadCount();
    if (mounted) setState(() => _unreadNotifications = count);
  }

  Future<void> _loadAppSettings() async {
    final settings =
        await AppSettingsService.getPublicSettings(forceRefresh: true);
    if (mounted) {
      setState(() => _appSettings = settings);
    }
  }

  Widget _buildServiceImage(dynamic service) {
    final imageUrl =
        resolveServiceImageUrl(service.image, imageUrl: service.imageUrl);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _serviceImageFallback(),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : _serviceImageFallback(),
          )
        else
          _serviceImageFallback(),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _serviceImageFallback() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child:
            Icon(Icons.cleaning_services, size: 48, color: AppColors.primary),
      ),
    );
  }

  void _loadServices() {
    context.read<ServiceProvider>().fetchServices();
  }

  void _loadBookings() {
    context.read<BookingProvider>().fetchMyBookings().then((_) {
      if (mounted) context.read<AuthProvider>().getProfile();
    });
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      context.read<ServiceProvider>().fetchServices(),
      context.read<BookingProvider>().fetchMyBookings(),
      context.read<AuthProvider>().getProfile(),
      _loadAppSettings(),
      _loadUnreadNotifications(),
      _loadHotOffers(),
      _loadCleaningTip(),
    ]);
  }

  Widget _buildSectionHeader(
    String title, {
    IconData? icon,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.marginMobile),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.sectionTitle, maxLines: 2),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.sectionSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
    _homeScrollController.dispose();
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
            icon: Badge(
              isLabelVisible: _unreadNotifications > 0,
              label: Text('$_unreadNotifications'),
              child: const Icon(Icons.notifications, color: AppColors.primary),
            ),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/notifications');
              if (mounted) _loadUnreadNotifications();
            },
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
    return RefreshIndicator(
      onRefresh: _refreshHome,
      child: SingleChildScrollView(
        controller: _homeScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppStyles.paddingLarge),
            _buildHeroSection(),
            const SizedBox(height: AppStyles.paddingLarge),
            _buildQuickBookingCard(),
            const SizedBox(height: AppStyles.paddingLarge),
            _buildAiCleaningPlannerCard(),
            const SizedBox(height: AppStyles.paddingLarge),
            _buildLoyaltyStreakCard(),
            const SizedBox(height: AppStyles.paddingLarge),
            _buildSectionHeader(
              'Cleaning Tip of the Day',
              icon: Icons.lightbulb_outline_rounded,
              subtitle: 'Fresh advice to keep your home spotless',
            ),
            const SizedBox(height: AppStyles.paddingSmall),
            CleaningTipCard(
              tip: _cleaningTip,
              isLoading: _cleaningTipLoading,
            ),
            const SizedBox(height: AppStyles.paddingLarge),
            _buildOffersSection(),
            const SizedBox(height: AppStyles.paddingXLarge),
            Padding(
              key: _servicesSectionKey,
              padding: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
              child: _buildSectionHeader(
                'Our Services',
                icon: Icons.cleaning_services_rounded,
                subtitle: 'Tap a service to book instantly',
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                decoration: AppDecorations.gradientCard(
                  colors: const [AppColors.secondary, AppColors.secondaryContainer],
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
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        SizedBox(
          height: 238,
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
                      colors: card['colors'],
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
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -38,
                        top: -45,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 24,
                        bottom: 20,
                        child: Icon(card['icon'],
                            size: 92,
                            color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppStyles.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['title'],
                              style: const TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 245,
                              child: Text(
                                card['subtitle'],
                                style: TextStyle(
                                  color: AppColors.onPrimary
                                      .withValues(alpha: 0.9),
                                  fontSize: 13.5,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                              ),
                            ),
                            const Spacer(),
                            if (card['button'] != null)
                              ElevatedButton(
                                onPressed: () {
                                  if (card['action'] == 'book') {
                                    Navigator.of(context)
                                        .pushNamed('/custom-booking');
                                  } else {
                                    Scrollable.ensureVisible(
                                      _servicesSectionKey.currentContext!,
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: card['colors'][0],
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(card['button'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                          ],
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
        decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book Your Cleaning Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize and get instant pricing',
                    style: AppStyles.sectionSubtitle,
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
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.arrow_forward_rounded,
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

  Widget _buildAiCleaningPlannerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.marginMobile),
      child: Container(
        decoration: AppDecorations.gradientCard(
          colors: const [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
          radius: AppStyles.radiusXL,
        ),
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Cleaning Planner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find your perfect cleaning service & duration',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/service-advisor'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF6366F1),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Hot Offers',
          icon: Icons.local_offer_rounded,
          subtitle: 'Limited-time savings on your next clean',
        ),
        const SizedBox(height: AppStyles.paddingSmall),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          if (_offerCards.isEmpty)
            Text(
              'No hot offers currently available.',
              style: AppStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
            )
          else
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
        ),
      ],
    );
  }

  Widget _buildLoyaltyStreakCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final streakProgress = auth.user?.loyaltyProgress ?? 0;
        final rewards = auth.user?.loyaltyRewardsAvailable ?? 0;

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppStyles.marginMobile),
          child: Container(
            padding: const EdgeInsets.all(AppStyles.paddingLarge),
            decoration: AppDecorations.gradientCard(
              colors: const [AppColors.primary, AppColors.primaryContainer],
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
                          const Icon(Icons.stars,
                              color: Colors.amber, size: 24),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        rewards == 1
                            ? '1 reward ready'
                            : '$rewards rewards ready',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    final isCompleted = index < streakProgress;

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
                              color:
                                  isCompleted ? Colors.amber : Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Clean ${index + 1}',
                          style: TextStyle(
                            color: isCompleted ? Colors.amber : Colors.white70,
                            fontSize: 10,
                            fontWeight: isCompleted
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Text(
                  rewards > 0
                      ? 'Your free normal cleaning reward is ready in custom booking.'
                      : 'Complete ${4 - streakProgress} more cleaning(s) to unlock a free normal cleaning.',
                  style: const TextStyle(
                      color: Color(0xFFCCFBF1),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        const Icon(Icons.local_offer, color: Color(0xFF0D9488)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(offer['title']!,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer['subtitle']!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 16),
                        const Text('Use Coupon Code:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey)),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF0D9488)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy,
                                    color: Color(0xFF64748B)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Coupon code ${offer['code']} copied to clipboard!')),
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
        decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppStyles.radiusXL),
                topRight: Radius.circular(AppStyles.radiusXL),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: _buildServiceImage(service),
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
          return const Center(child: CircularProgressIndicator());
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
              _buildSectionHeader(
                'My Bookings',
                icon: Icons.calendar_month_rounded,
                subtitle: _bookingViewMode == 1
                    ? 'Tap a day to see your scheduled cleans'
                    : 'Track upcoming, completed, and cancelled jobs',
              ),
              const SizedBox(height: AppStyles.paddingBase),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: AppDecorations.elevatedCard(),
                child: Row(
                  children: [
                    _buildViewModeTab('List', 0, Icons.view_list_rounded),
                    _buildViewModeTab('Calendar', 1, Icons.calendar_month_rounded),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.paddingBase),
              if (_bookingViewMode == 1) ...[
                BookingCalendarSection(
                  bookings: bookingProvider.bookings,
                  bookingCardBuilder: _buildBookingCard,
                ),
              ] else ...[
                if (bookingProvider.bookings.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingXLarge),
                    decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 56,
                          color: AppColors.gray.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No bookings yet',
                          style: AppStyles.sectionTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Book your first cleaning from the home tab.',
                          textAlign: TextAlign.center,
                          style: AppStyles.sectionSubtitle,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() => _selectedTabIndex = 0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                            ),
                          ),
                          child: const Text('Browse Services'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: AppDecorations.elevatedCard(),
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
                      decoration: AppDecorations.elevatedCard(),
                      child: Text(
                        _bookingTabIndex == 0
                            ? 'No upcoming bookings.'
                            : _bookingTabIndex == 1
                                ? 'No completed bookings yet.'
                                : 'No cancelled bookings.',
                        textAlign: TextAlign.center,
                        style: AppStyles.bodyMedium,
                      ),
                    )
                  else
                    ...visibleBookings.map(_buildBookingCard),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewModeTab(String label, int index, IconData icon) {
    final selected = _bookingViewMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _bookingViewMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.white : AppColors.darkGray,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.white : AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
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
    final List<String> extras = booking.extrasList;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/booking-details', arguments: booking);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.displayTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.getStatusLabel(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.darkGray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${booking.bookingDate.toString().split(' ')[0]} at ${booking.bookingTime}',
                    style: TextStyle(fontSize: 12, color: AppColors.darkGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.darkGray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${booking.address}, ${booking.city}',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${booking.cleaningTypeLabel} - ${booking.durationHours.toStringAsFixed(1)} hours',
              style: TextStyle(fontSize: 12, color: AppColors.darkGray),
            ),
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
                Container(
                  padding: const EdgeInsets.all(AppStyles.paddingLarge),
                  decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(42),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
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
                        onTap: () =>
                            Navigator.of(context).pushNamed('/addresses'),
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
                        onTap: _showTransactionHistory,
                      ),
                      _buildProfileOption(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () async {
                          await _loadAppSettings();
                          if (!mounted) return;
                          _showInfoSheet(
                            title: 'Help & Support',
                            icon: Icons.help_outline,
                            message:
                                'Email: ${_appSettings['supportEmail']}\nPhone: ${_appSettings['supportPhone']}',
                          );
                        },
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

  Future<void> _showTransactionHistory() async {
    await context.read<BookingProvider>().fetchMyBookings();
    if (!mounted) return;

    final history = context
        .read<BookingProvider>()
        .bookings
        .where((booking) =>
            booking.status == 'completed' ||
            booking.loyaltyRewardEarned ||
            booking.loyaltyRewardRedeemed)
        .toList()
      ..sort((a, b) => (b.createdAt ?? b.bookingDate)
          .compareTo(a.createdAt ?? a.bookingDate));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        builder: (_, controller) => Column(
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Transaction History',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child:
                          Text('No completed bookings or reward activity yet.'))
                  : ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final booking = history[index];
                        return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(booking.displayTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  Text(
                                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Color(0xFF0F766E),
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                DateFormat('MMM d, yyyy')
                                    .format(booking.bookingDate),
                                style: const TextStyle(
                                    color: Color(0xFF64748B), fontSize: 12),
                              ),
                              if (booking.loyaltyRewardEarned ||
                                  booking.loyaltyRewardRedeemed) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (booking.loyaltyRewardEarned)
                                      _buildHistoryTag(
                                          'Reward earned', Icons.card_giftcard),
                                    if (booking.loyaltyRewardRedeemed)
                                      _buildHistoryTag(
                                          'Reward redeemed', Icons.redeem),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F766E)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
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
                    final digits =
                        value.trim().replaceAll(RegExp(r'[\s\-()]'), '');
                    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(digits)) {
                      return 'Enter a valid phone number (e.g. +96170123456).';
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
                      final messenger = ScaffoldMessenger.of(context);
                      final success =
                          await context.read<AuthProvider>().updateProfile(
                                fullName: nameController.text.trim(),
                                phone: phoneController.text
                                    .trim()
                                    .replaceAll(RegExp(r'[\s\-()]'), ''),
                              );
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      messenger.showSnackBar(
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
    );
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
          color: isActive ? AppColors.secondaryContainer : Colors.transparent,
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
