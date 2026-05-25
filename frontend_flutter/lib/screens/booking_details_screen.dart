import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../services/app_settings_service.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late String bookingId;
  final Map<String, double> _addOnPrices = {};

  @override
  void initState() {
    super.initState();
    bookingId = widget.booking.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false)
          .fetchBookingById(bookingId);
      _loadAddOnPrices();
    });
  }

  Future<void> _loadAddOnPrices() async {
    final addOns = await AppSettingsService.getPublicAddOns(forceRefresh: true);
    if (!mounted) return;

    setState(() {
      _addOnPrices.clear();
      for (final addOn in addOns) {
        final name = (addOn['name'] ?? addOn['title'] ?? '').toString().trim();
        final price = double.tryParse((addOn['price'] ?? '').toString()) ?? 0.0;
        if (name.isNotEmpty) _addOnPrices[name.toLowerCase()] = price;
      }
    });
  }

  double _addOnPrice(String name) => _addOnPrices[name.toLowerCase()] ?? 0.0;

  double _addOnsTotal(List<String> extras) {
    return extras.fold(0.0, (sum, name) => sum + _addOnPrice(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          'Booking Receipt',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedBooking == null) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D9488)));
          }

          final booking = provider.selectedBooking ?? widget.booking;

          // Pricing calculation breakdown
          final isDeep = booking.cleaningType.toLowerCase() == 'deep';
          final hourlyRate = isDeep ? 6.0 : 4.0;
          final duration = booking.durationHours;
          final cleaningBase = hourlyRate * duration;
          final extras = booking.extrasList;
          final addOnsTotal = _addOnsTotal(extras);
          final beforeDiscount = cleaningBase + addOnsTotal;

          final authProvider = Provider.of<AuthProvider>(context);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                provider.fetchBookingById(bookingId),
                _loadAddOnPrices(),
              ]);
            },
            color: const Color(0xFF0D9488),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cancelled banner
                  if (booking.status == 'cancelled') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined,
                              color: Colors.red, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Cancelled',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'This service request has been cancelled.',
                                  style: TextStyle(
                                    color: Color(0xFF7F1D1D),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Receipt Breakdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Receipt Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0FDFA),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.displayTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D9488),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(booking.bookingDate)} (${booking.startTime} - ${booking.endTime})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${duration.toStringAsFixed(1)} hrs',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // Address details
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Color(0xFF0D9488), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${booking.address}, ${booking.city}',
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (booking.notes != null &&
                                  booking.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Notes: ${booking.notes}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const Divider(height: 32),
                              const Text(
                                'Booking Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildReceiptRow(
                                  'Cleaning type', booking.cleaningTypeLabel),
                              const SizedBox(height: 8),
                              _buildReceiptRow(
                                'Time',
                                '${booking.startTime} - ${booking.endTime}',
                              ),
                              const Divider(height: 32),

                              // Receipt Items
                              const Text(
                                'Invoice Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildReceiptRow(
                                'Cleaning hours (${isDeep ? "\$6/hr" : "\$4/hr"} x ${duration.toStringAsFixed(1)}h)',
                                '\$${cleaningBase.toStringAsFixed(2)}',
                              ),
                              if (extras.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...extras.map(
                                  (extra) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildReceiptRow(
                                      extra,
                                      '+\$${_addOnPrice(extra).toStringAsFixed(2)}',
                                    ),
                                  ),
                                ),
                                _buildReceiptRow(
                                  'Add-ons total',
                                  '\$${addOnsTotal.toStringAsFixed(2)}',
                                ),
                              ],
                              if (booking.discountAmount > 0 ||
                                  addOnsTotal > 0) ...[
                                const SizedBox(height: 8),
                                _buildReceiptRow(
                                  'Subtotal',
                                  '\$${beforeDiscount.toStringAsFixed(2)}',
                                ),
                              ],
                              if (booking.discountAmount > 0) ...[
                                const SizedBox(height: 8),
                                _buildReceiptRow(
                                  'Promo Code Discount (${booking.promoCode ?? "Applied"})',
                                  '-\$${booking.discountAmount.toStringAsFixed(2)}',
                                  isDiscount: true,
                                ),
                              ],
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Paid / Due',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF0D9488),
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
                  const SizedBox(height: 24),

                  // Actions
                  if (booking.status != 'completed' &&
                      booking.status != 'cancelled') ...[
                    // Customer wants to cancel
                    if (booking.status == 'pending' ||
                        booking.status == 'accepted') ...[
                      OutlinedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cancel Booking'),
                              content: const Text(
                                  'Are you sure you want to cancel this booking?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No, keep it'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes, Cancel',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success =
                                await provider.cancelBooking(booking.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Booking cancelled successfully')),
                              );
                              // Sync profile to refresh points if any changes
                              Provider.of<AuthProvider>(context, listen: false)
                                  .getProfile();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(provider.error ??
                                        'Cancellation failed')),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Cancel Booking',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Mark as Completed (admin only)
                    if (authProvider.user?.role == 'admin')
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Complete Booking'),
                              content: const Text(
                                'Mark this booking as Completed? You will earn +1 loyalty point!',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes, Complete',
                                      style:
                                          TextStyle(color: Color(0xFF0D9488))),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success =
                                await provider.completeBooking(booking.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Booking marked completed! +1 Loyalty point earned!')),
                              );
                              // Refresh profile
                              Provider.of<AuthProvider>(context, listen: false)
                                  .getProfile();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(provider.error ??
                                        'Failed to complete booking')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        label: const Text(
                          'Mark as Completed',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isDiscount ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
