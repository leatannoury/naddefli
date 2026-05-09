import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../utils/app_styles.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedExtras = (booking.extras ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmed',
            style: TextStyle(color: AppColors.black)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle,
                          color: AppColors.success, size: 44),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your request is in',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We saved your booking and it is waiting for a cleaner.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.darkGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Schedule',
                children: [
                  _InfoRow(
                    icon: Icons.event_available,
                    label: DateFormat('EEE, MMM d, yyyy')
                        .format(booking.bookingDate),
                  ),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: booking.bookingTime,
                  ),
                ],
              ),
              _InfoCard(
                title: 'Location',
                children: [
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: '${booking.address}, ${booking.city}',
                  ),
                ],
              ),
              if (booking.isCustom)
                _InfoCard(
                  title: 'Cleaning Details',
                  children: [
                    _InfoRow(
                      icon: Icons.home_work_outlined,
                      label: booking.propertyType ?? 'Custom property',
                    ),
                    _InfoRow(
                      icon: Icons.bed_outlined,
                      label: '${booking.roomCount} rooms',
                    ),
                    if (booking.bathroomsCount > 0)
                      _InfoRow(
                        icon: Icons.bathtub_outlined,
                        label: '${booking.bathroomsCount} bathrooms',
                      ),
                    if (booking.kitchensCount > 0)
                      _InfoRow(
                        icon: Icons.kitchen_outlined,
                        label: '${booking.kitchensCount} kitchens',
                      ),
                    _InfoRow(
                      icon: Icons.cleaning_services_outlined,
                      label: booking.cleaningType == 'deep'
                          ? 'Deep cleaning'
                          : 'Normal cleaning',
                    ),
                  ],
                ),
              if (selectedExtras.isNotEmpty)
                _InfoCard(
                  title: 'Extras',
                  children: selectedExtras
                      .map((extra) =>
                          _InfoRow(icon: Icons.add_task, label: extra))
                      .toList(),
                ),
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated total',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                  arguments: 1,
                ),
                icon: const Icon(Icons.calendar_today),
                label: const Text('View My Bookings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
