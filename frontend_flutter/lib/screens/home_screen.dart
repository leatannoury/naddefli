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
  final TextEditingController _searchController = TextEditingController();
  String _serviceQuery = '';

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

  @override
  void dispose() {
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
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
          // Hero Welcome Section
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppStyles.marginMobile,
              AppStyles.paddingXLarge,
              AppStyles.marginMobile,
              AppStyles.paddingLarge,
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${authProvider.user?.fullName.split(' ').first ?? 'User'}',
                      style: AppStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    const Text(
                      'Experience The Refresh',
                      style: AppStyles.headlineMedium,
                    ),
                  ],
                );
              },
            ),
          ),

          // Premium Service Card - Whole Home Cleaning
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.marginMobile,
            ),
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/custom-booking'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppStyles.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingBase,
                        vertical: AppStyles.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'PREMIUM SERVICE',
                        style: AppStyles.labelBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingBase),
                    const Text(
                      'Whole Home Cleaning',
                      style: AppStyles.headlineSmall,
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    Text(
                      'A comprehensive, top-to-bottom refresh for your entire residence.',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingBase),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/custom-booking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyles.paddingLarge,
                          vertical: AppStyles.paddingBase,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Book Custom Request'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Specialized Services Section
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppStyles.marginMobile,
              AppStyles.paddingXLarge,
              AppStyles.marginMobile,
              AppStyles.paddingBase,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Specialized Services',
                  style: AppStyles.headlineSmall,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View all',
                    style: AppStyles.labelBold.copyWith(
                      color: AppColors.primary,
                    ),
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
                    crossAxisCount: 1,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: AppStyles.paddingBase,
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
                      const SizedBox(width: -6),
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
                      const SizedBox(width: -6),
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

  Widget _buildServiceCard(BuildContext context, dynamic service) {
    return GestureDetector(
      onTap: () {
        context.read<ServiceProvider>().selectService(service);
        Navigator.of(context).pushNamed('/booking', arguments: service);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppStyles.radiusXL),
                      topRight: Radius.circular(AppStyles.radiusXL),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.cleaning_services,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: AppStyles.paddingSmall,
                  right: AppStyles.paddingSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingBase,
                      vertical: AppStyles.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${service.basePrice.toStringAsFixed(0)}+',
                      style: AppStyles.labelBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppStyles.paddingSmall),
                      Expanded(
                        child: Text(
                          service.name,
                          style: AppStyles.labelBold.copyWith(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),
                  Text(
                    service.description ?? 'Professional cleaning service',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
        final incoming = bookingProvider.bookings.where((booking) {
          final dateTime = DateTime.tryParse(
              '${booking.bookingDate.toIso8601String().split('T').first}T${booking.bookingTime}');
          return !['completed', 'cancelled'].contains(booking.status) &&
              (dateTime == null || dateTime.isAfter(now));
        }).toList();
        final past = bookingProvider.bookings.where((booking) {
          final dateTime = DateTime.tryParse(
              '${booking.bookingDate.toIso8601String().split('T').first}T${booking.bookingTime}');
          return ['completed', 'cancelled'].contains(booking.status) ||
              (dateTime != null && dateTime.isBefore(now));
        }).toList();
        final visibleBookings = _bookingTabIndex == 0 ? incoming : past;

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
                    _buildBookingTab('Incoming', 0, incoming.length),
                    _buildBookingTab('Past', 1, past.length),
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
                        ? 'No incoming bookings.'
                        : 'No past bookings yet.',
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
    final extras = (booking.extras ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Container(
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
              children: extras.take(3).map<Widget>((extra) {
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
                        onTap: () => _showInfoSheet(
                          title: 'My Addresses',
                          icon: Icons.location_on_outlined,
                          message:
                              'Your next booking addresses will appear here for quick reuse.',
                        ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: AppStyles.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
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
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your name'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    final success =
                        await context.read<AuthProvider>().updateProfile(
                              fullName: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                            );
                    if (!mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Profile updated'
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
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
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
            color: AppColors.black.withOpacity(0.05),
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
