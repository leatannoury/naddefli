import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/booking_provider.dart';
import '../utils/app_styles.dart';

/// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadBookings();
  }

  void _loadServices() {
    context.read<ServiceProvider>().fetchServices();
  }

  void _loadBookings() {
    context.read<BookingProvider>().fetchMyBookings();
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
            icon: const Icon(Icons.notifications_none,
                color: AppColors.primary),
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
                  padding: const EdgeInsets.all(
                      AppStyles.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(
                        AppStyles.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
              decoration: InputDecoration(
                hintText: 'Search services',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppStyles.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
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

                return GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: serviceProvider.services.length,
                  itemBuilder: (context, index) {
                    final service =
                        serviceProvider.services[index];
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

  Widget _buildServiceCard(
      BuildContext context, dynamic service) {
    return GestureDetector(
      onTap: () {
        context
            .read<ServiceProvider>()
            .selectService(service);
        Navigator.of(context)
            .pushNamed('/booking', arguments: service);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppStyles.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft:
                      Radius.circular(AppStyles.radiusLarge),
                  topRight:
                      Radius.circular(AppStyles.radiusLarge),
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
              padding:
                  const EdgeInsets.all(AppStyles.paddingMedium),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                  Text(
                    '${service.durationHours.toStringAsFixed(1)}h',
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 12,
                    ),
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
                  color: AppColors.gray.withOpacity(0.5),
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

        return ListView.builder(
          padding: const EdgeInsets.all(
              AppStyles.paddingLarge),
          itemCount: bookingProvider.bookings.length,
          itemBuilder: (context, index) {
            final booking = bookingProvider.bookings[index];
            return Container(
              margin: const EdgeInsets.only(
                  bottom: AppStyles.paddingMedium),
              padding: const EdgeInsets.all(
                  AppStyles.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                    AppStyles.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.address,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking
                              .status),
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                        child: Text(
                          booking.getStatusLabel(),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${booking.bookingDate.toString().split(' ')[0]} at ${booking.bookingTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGray,
                    ),
                  ),
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
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.all(AppStyles.paddingLarge),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Profile card
                Container(
                  padding: const EdgeInsets.all(
                      AppStyles.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                        AppStyles.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primary,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            40),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors
                                    .white,
                              ),
                            ),
                            const SizedBox(
                                height: 16),
                            Text(
                              authProvider.user
                                      ?.fullName ??
                                  'User',
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                                height: 4),
                            Text(
                              authProvider.user
                                      ?.email ??
                                  '',
                              style: TextStyle(
                                color: AppColors
                                    .darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height: 24),
                      // Logout button
                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed: () =>
                              _handleLogout(
                                  context),
                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                                AppColors
                                    .error,
                          ),
                          icon: const Icon(
                              Icons
                                  .logout),
                          label: const Text(
                              'Logout'),
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
      Navigator.of(context)
          .pushReplacementNamed('/login');
    }
  }
}
