import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/service_provider.dart';
import '../utils/app_styles.dart';
import 'package:intl/intl.dart';

class CustomBookingScreen extends StatefulWidget {
  const CustomBookingScreen({Key? key}) : super(key: key);

  @override
  State<CustomBookingScreen> createState() => _CustomBookingScreenState();
}

class _CustomBookingScreenState extends State<CustomBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = "09:00";

  String _propertyType = 'House/Apartment';
  int _roomCount = 2;
  int _bathroomCount = 1;
  int _kitchenCount = 1;
  String _cleaningType = 'normal'; // normal, deep

  final Map<String, bool> _extras = {
    'Pet-friendly': false,
    'Inside Windows': false,
    'Inside Fridge': false,
    'Inside Oven': false,
    'Balcony': false,
    'Eco-products': false,
  };

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

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

  double _calculateTotal() {
    final services = context.read<ServiceProvider>().services;
    double total = services.isNotEmpty ? services.first.basePrice : 50.0;
    total += (_roomCount * 20.0);
    total += (_bathroomCount * 30.0);
    total += (_kitchenCount * 40.0);

    if (_cleaningType == 'deep') {
      total *= 1.5;
    }

    _extras.forEach((key, value) {
      if (value) total += 15.0; // Each extra is $15
    });

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
        title: const Text('Custom Request',
            style: TextStyle(color: AppColors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Property Details'),
              const SizedBox(height: 12),
              _buildSegmentedControl(),
              const SizedBox(height: 20),
              _buildPropertyCounters(),
              const SizedBox(height: 24),
              _buildSectionTitle('Cleaning Type'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeCard(
                      'Normal',
                      'Standard clean',
                      Icons.cleaning_services,
                      _cleaningType == 'normal',
                      () => setState(() => _cleaningType = 'normal')),
                  const SizedBox(width: 12),
                  _buildTypeCard(
                      'Deep',
                      'Detailed clean',
                      Icons.auto_fix_high,
                      _cleaningType == 'deep',
                      () => setState(() => _cleaningType = 'deep')),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Extras'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _extras.keys.map((key) {
                  return FilterChip(
                    label: Text(key),
                    selected: _extras[key]!,
                    onSelected: (val) => setState(() => _extras[key] = val),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _extras[key]!
                          ? AppColors.primary
                          : AppColors.darkGray,
                      fontWeight:
                          _extras[key]! ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Schedule'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildTimePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Location'),
              const SizedBox(height: 12),
              _buildTextField(
                  'Address', _addressController, Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                  'City', _cityController, Icons.location_city_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                  'Special Notes', _notesController, Icons.note_outlined,
                  maxLines: 3),
              const SizedBox(height: 32),
              _buildPriceSummary(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child:
                    Consumer<BookingProvider>(builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white)
                        : const Text('Confirm Custom Request',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white)),
                  );
                }),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSegmentItem('House/Apartment')),
          Expanded(child: _buildSegmentItem('Room Only')),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String type) {
    bool isSelected = _propertyType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _propertyType = type;
          if (type == 'Room Only') {
            _bathroomCount = 0;
            _kitchenCount = 0;
            if (_roomCount == 0) _roomCount = 1;
          } else {
            if (_bathroomCount == 0) _bathroomCount = 1;
            if (_kitchenCount == 0) _kitchenCount = 1;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.darkGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCounters() {
    final isRoomOnly = _propertyType == 'Room Only';

    return Column(
      children: [
        _buildCounter(
          isRoomOnly ? 'Rooms to clean' : 'Living Rooms / Bedrooms',
          _roomCount,
          (val) => setState(() => _roomCount = val.clamp(1, 12).toInt()),
        ),
        if (!isRoomOnly) ...[
          _buildCounter(
            'Bathrooms',
            _bathroomCount,
            (val) => setState(() => _bathroomCount = val.clamp(0, 8).toInt()),
          ),
          _buildCounter(
            'Kitchens',
            _kitchenCount,
            (val) => setState(() => _kitchenCount = val.clamp(0, 3).toInt()),
          ),
        ],
      ],
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.primary),
              ),
              SizedBox(
                  width: 30,
                  child: Center(
                      child: Text('$value',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)))),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String title, String sub, IconData icon,
      bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.lightGray,
                width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.gray,
                  size: 32),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.black)),
              Text(sub,
                  style: TextStyle(fontSize: 10, color: AppColors.darkGray)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(DateFormat('EEE, MMM d, yyyy').format(_selectedDate)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index + 1));
              final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(_selectedDate);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  label: SizedBox(
                    width: 56,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(DateFormat('EEE').format(date)),
                        Text(DateFormat('d MMM').format(date)),
                      ],
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedDate = date),
                ),
              );
            },
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
    }
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time),
            label: Text(_selectedTime),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTime == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: AppColors.secondary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _selectedTime = time),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.lightGray.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Estimated Total',
              style: TextStyle(color: AppColors.white, fontSize: 16)),
          Text('\$${_calculateTotal().toStringAsFixed(2)}',
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _submitRequest() async {
    if (_addressController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter address and city')));
      return;
    }

    final serviceProvider = context.read<ServiceProvider>();
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.fetchServices();
    }
    final String serviceId = serviceProvider.services.isNotEmpty
        ? serviceProvider.services.first.id
        : '';
    if (serviceId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Services are still loading. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final bookingProvider = context.read<BookingProvider>();

    final success = await bookingProvider.createBooking(
      serviceId: serviceId,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      bookingTime: _selectedTime,
      address: _addressController.text,
      city: _cityController.text,
      notes: _notesController.text,
      isCustom: true,
      propertyType: _propertyType,
      roomCount: _roomCount,
      bathroomsCount: _bathroomCount,
      kitchensCount: _kitchenCount,
      cleaningType: _cleaningType,
      extras:
          _extras.entries.where((e) => e.value).map((e) => e.key).join(', '),
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
          content: Text(bookingProvider.error ?? 'Request failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
