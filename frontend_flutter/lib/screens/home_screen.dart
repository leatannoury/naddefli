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
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Naddefli',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
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
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Container(
                  padding: const EdgeInsets.all(AppStyles.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.user?.fullName ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Find trusted cleaners near you',
                        style: TextStyle(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _serviceQuery = value),
              decoration: InputDecoration(
                hintText: 'Search services',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _serviceQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _serviceQuery = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Custom Request Section
            Container(
              padding: const EdgeInsets.all(AppStyles.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.auto_awesome, color: AppColors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Custom Cleaning',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Select rooms, depth, and extras',
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/custom-booking'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Request'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Services heading
            const Text(
              'Popular Services',
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: 16),
            // Services list
            Consumer<ServiceProvider>(
              builder: (context, serviceProvider, _) {
                if (serviceProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (serviceProvider.services.isEmpty) {
                  return const Center(
                    child: Text('No services available'),
                  );
                }

                final query = _serviceQuery.trim().toLowerCase();
                final services = query.isEmpty
                    ? serviceProvider.services
                    : serviceProvider.services.where((service) {
                        return service.name.toLowerCase().contains(query) ||
                            (service.description ?? '')
                                .toLowerCase()
                                .contains(query);
                      }).toList();

                if (services.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppStyles.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppStyles.radiusMedium),
                    ),
                    child: const Text('No services match your search.'),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 360 ? 1 : 2,
                    childAspectRatio:
                        MediaQuery.of(context).size.width < 360 ? 1.55 : 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return _buildServiceCard(context, service);
                  },
                );
              },
            ),
          ],
        ),
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
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.radiusLarge),
                  topRight: Radius.circular(AppStyles.radiusLarge),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.cleaning_services,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 12, color: AppColors.darkGray),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationHours.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${service.basePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
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
              const Text('Edit Profile', style: AppStyles.headingSmall),
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
              Text(title, style: AppStyles.headingSmall),
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
    return BottomNavigationBar(
      currentIndex: _selectedTabIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
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
