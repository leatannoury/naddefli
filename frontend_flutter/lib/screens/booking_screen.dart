import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/service.dart';
import '../providers/booking_provider.dart';
import '../utils/app_styles.dart';

/// Booking Screen
class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate;
  String _selectedTime = "09:00";
  int _quantity = 1;
  String _cleaningType = 'normal';
  final Set<String> _extras = {};
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = "09:00";
  }

  final List<String> _timeSlots = [
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00"
  ];

  final List<String> _availableExtras = const [
    'Eco products',
    'Bring supplies',
  ];

  double _calculateTotal() {
    var total = widget.service.basePrice * _quantity;
    total += _extras.length * 15;
    if (_cleaningType == 'deep') {
      total *= 1.5;
    }
    return total;
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
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service summary
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: AppStyles.headingSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.service.basePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Schedule', style: AppStyles.headingSmall),
              const SizedBox(height: 12),
              _buildSchedulePicker(),
              const SizedBox(height: 24),
              Text('${widget.service.name} Details',
                  style: AppStyles.headingSmall),
              const SizedBox(height: 12),
              _buildServiceDetails(),
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
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Confirm button
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: bookingProvider.isLoading
                          ? null
                          : () => _confirmBooking(context),
                      child: bookingProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Confirm Booking'),
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

  Widget _buildSchedulePicker() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Column(
        children: [
          _ScheduleTile(
            icon: Icons.event_outlined,
            title: 'Day',
            value: DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
            onTap: _pickDate,
          ),
          const SizedBox(height: 10),
          _ScheduleTile(
            icon: Icons.access_time,
            title: 'Time',
            value: _selectedTime,
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    final label = _quantityLabel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _buildCounter(label, _quantity),
        if (_supportsCleaningType()) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['normal', 'deep'].map((type) {
              final selected = _cleaningType == type;
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                selectedColor: AppColors.secondary,
                label:
                    Text(type == 'deep' ? 'Deep cleaning' : 'Normal cleaning'),
                labelStyle: TextStyle(
                  color: selected ? AppColors.white : AppColors.black,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => setState(() => _cleaningType = type),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _extrasForService().map((extra) {
            final selected = _extras.contains(extra);
            return FilterChip(
              label: Text(extra),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  value ? _extras.add(extra) : _extras.remove(extra);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String? _quantityLabel() {
    final name = widget.service.name.toLowerCase();
    if (name.contains('kitchen')) return 'Kitchens';
    if (name.contains('bathroom')) return 'Bathrooms';
    if (name.contains('bedroom')) return 'Bedrooms / rooms';
    if (name.contains('window')) return 'Window groups';
    if (name.contains('sofa')) return 'Sofa seats';
    if (name.contains('office')) return 'Office rooms';
    return null;
  }

  bool _supportsCleaningType() {
    final name = widget.service.name.toLowerCase();
    return !name.contains('pest');
  }

  List<String> _extrasForService() {
    final name = widget.service.name.toLowerCase();
    if (name.contains('kitchen')) {
      return ['Inside oven', 'Inside fridge', ..._availableExtras];
    }
    if (name.contains('bathroom')) {
      return ['Mold treatment', 'Tile scrub', ..._availableExtras];
    }
    if (name.contains('window')) {
      return ['Inside and outside', 'Balcony windows', ..._availableExtras];
    }
    if (name.contains('sofa')) {
      return ['Stain treatment', 'Deodorizing', ..._availableExtras];
    }
    if (name.contains('pest')) {
      return ['Kitchen focus', 'Bathroom focus', 'Pet-safe treatment'];
    }
    return _availableExtras;
  }

  Widget _buildCounter(String label, int value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
            onPressed: value > 1 ? () => setState(() => _quantity--) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text('$value',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    await showModalBottomSheet<void>(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose Time', style: AppStyles.headingSmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _timeSlots.map((time) {
                  final selected = _selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.white : AppColors.black,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedTime = time);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final parts = _selectedTime.split(':');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(parts.first),
                        minute: int.parse(parts.last),
                      ),
                    );
                    if (picked != null && mounted) {
                      setState(() {
                        _selectedTime =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Pick another time'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    if (_addressController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill required fields'),
        ),
      );
      return;
    }

    final bookingProvider = context.read<BookingProvider>();

    final success = await bookingProvider.createBooking(
      serviceId: widget.service.id,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      bookingTime: _selectedTime,
      address: _addressController.text,
      city: _cityController.text,
      notes: _notesController.text,
      isCustom: false,
      propertyType: widget.service.name,
      roomCount: _roomCountForService(),
      bathroomsCount: _bathroomCountForService(),
      kitchensCount: _kitchenCountForService(),
      cleaningType: _cleaningType,
      extras: _extras.join(', '),
    );

    if (success && mounted) {
      final createdBooking = bookingProvider.lastCreatedBooking;
      if (createdBooking == null) {
        Navigator.pop(context);
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        '/booking-confirmation',
        arguments: createdBooking,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Booking failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  int _roomCountForService() {
    final name = widget.service.name.toLowerCase();
    return name.contains('bedroom') ||
            name.contains('office') ||
            name.contains('window') ||
            name.contains('sofa')
        ? _quantity
        : 0;
  }

  int _bathroomCountForService() {
    return widget.service.name.toLowerCase().contains('bathroom')
        ? _quantity
        : 0;
  }

  int _kitchenCountForService() {
    return widget.service.name.toLowerCase().contains('kitchen')
        ? _quantity
        : 0;
  }
}

class _ScheduleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ScheduleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.darkGray)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}
