import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/booking_provider.dart';
import '../utils/app_styles.dart';
import '../utils/storage_service.dart';

/// Booking Screen
class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({Key? key, required this.service})
      : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(AppStyles.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service summary
              Container(
                padding: const EdgeInsets.all(
                    AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppStyles.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cleaning_services,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: AppStyles
                                .headingSmall,
                          ),
                          const SizedBox(
                              height: 4),
                          Text(
                            '\$${widget.service.basePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: AppColors
                                  .primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Date selection
              const Text('Select Date',
                  style: AppStyles.headingSmall),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.gray),
                    borderRadius:
                        BorderRadius.circular(
                            AppStyles
                                .radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Time selection
              const Text('Select Time',
                  style: AppStyles.headingSmall),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.gray),
                    borderRadius:
                        BorderRadius.circular(
                            AppStyles
                                .radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(_selectedTime
                          .format(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Address
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                icon: Icons.location_on_outlined,
                hint: 'Enter your address',
              ),
              const SizedBox(height: 16),
              // City
              _buildTextField(
                label: 'City',
                controller: _cityController,
                icon: Icons.location_city_outlined,
                hint: 'Enter your city',
              ),
              const SizedBox(height: 16),
              // Notes
              _buildTextField(
                label: 'Special Notes (Optional)',
                controller: _notesController,
                icon: Icons.note_outlined,
                hint: 'Add any special requests',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Price summary
              Container(
                padding: const EdgeInsets.all(
                    AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(
                      AppStyles.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'Total Price:',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${widget.service.basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Confirm button
              Consumer<BookingProvider>(
                builder:
                    (context, bookingProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: bookingProvider
                              .isLoading
                          ? null
                          : () =>
                              _confirmBooking(
                                  context),
                      child: bookingProvider
                              .isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirm Booking'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppStyles.radiusMedium),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _confirmBooking(
      BuildContext context) async {
    if (_addressController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill required fields'),
        ),
      );
      return;
    }

    final bookingProvider =
        context.read<BookingProvider>();

    final success =
        await bookingProvider.createBooking(
      serviceId: widget.service.id,
      bookingDate:
          _selectedDate.toString().split(' ')[0],
      bookingTime:
          _selectedTime.format(context),
      address: _addressController.text,
      city: _cityController.text,
      notes: _notesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              bookingProvider.error ??
                  'Booking failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
