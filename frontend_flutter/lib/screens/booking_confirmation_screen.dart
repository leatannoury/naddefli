import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/app_settings_service.dart';
import '../utils/app_styles.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> selectedExtras = booking.extrasList;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmed',
            style: TextStyle(color: AppColors.black)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: AppSettingsService.getPublicAddOns(forceRefresh: true),
        builder: (context, snapshot) {
          final addOnPrices = <String, double>{};
          for (final addOn in snapshot.data ?? <Map<String, dynamic>>[]) {
            final name =
                (addOn['name'] ?? addOn['title'] ?? '').toString().trim();
            final price =
                double.tryParse((addOn['price'] ?? '').toString()) ?? 0.0;
            if (name.isNotEmpty) addOnPrices[name.toLowerCase()] = price;
          }
          double addOnPrice(String name) =>
              addOnPrices[name.toLowerCase()] ?? 0.0;

          final isDeep = booking.cleaningType.toLowerCase() == 'deep';
          final hourlyRate = isDeep ? 6.0 : 4.0;
          final cleaningBase = hourlyRate * booking.durationHours;
          final addOnsTotal = selectedExtras.fold(
            0.0,
            (sum, name) => sum + addOnPrice(name),
          );
          final subtotal = cleaningBase + addOnsTotal;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppStyles.radiusLarge),
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
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
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
                    title: 'Service',
                    children: [
                      _InfoRow(
                        icon: booking.isCustom
                            ? Icons.tune
                            : Icons.cleaning_services_outlined,
                        label: booking.displayTitle,
                      ),
                      _InfoRow(
                        icon: Icons.cleaning_services_outlined,
                        label: booking.cleaningTypeLabel,
                      ),
                    ],
                  ),
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
                        label: '${booking.startTime} - ${booking.endTime}',
                      ),
                      _InfoRow(
                        icon: Icons.timer_outlined,
                        label:
                            '${booking.durationHours.toStringAsFixed(1)} hours',
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
                  _InfoCard(
                    title: 'Booking Details',
                    children: [
                      _InfoRow(
                        icon: Icons.info_outline,
                        label: booking.getStatusLabel(),
                      ),
                      if (booking.notes != null &&
                          booking.notes!.trim().isNotEmpty)
                        _InfoRow(
                          icon: Icons.notes_outlined,
                          label: booking.notes!.trim(),
                        ),
                    ],
                  ),
                  _InfoCard(
                    title: 'Total Details',
                    children: [
                      _InfoRow(
                        icon: Icons.timer_outlined,
                        label:
                            'Cleaning hours (${isDeep ? "\$6/hr" : "\$4/hr"} x ${booking.durationHours.toStringAsFixed(1)}h): \$${cleaningBase.toStringAsFixed(2)}',
                      ),
                      ...selectedExtras.map(
                        (extra) => _InfoRow(
                          icon: Icons.add_task,
                          label:
                              '$extra: +\$${addOnPrice(extra).toStringAsFixed(2)}',
                        ),
                      ),
                      if (selectedExtras.isNotEmpty)
                        _InfoRow(
                          icon: Icons.add_circle_outline,
                          label:
                              'Add-ons total: \$${addOnsTotal.toStringAsFixed(2)}',
                        ),
                      if (booking.discountAmount > 0 ||
                          selectedExtras.isNotEmpty)
                        _InfoRow(
                          icon: Icons.receipt_long_outlined,
                          label: 'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                        ),
                      if (booking.discountAmount > 0)
                        _InfoRow(
                          icon: Icons.local_offer_outlined,
                          label:
                              '${booking.promoCode ?? 'Discount'}: -\$${booking.discountAmount.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppStyles.radiusMedium),
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
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
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
          );
        },
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
