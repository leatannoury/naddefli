import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../providers/service_provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../models/address.dart';
import '../utils/app_styles.dart';

class CustomBookingScreen extends StatefulWidget {
  const CustomBookingScreen({Key? key}) : super(key: key);

  @override
  State<CustomBookingScreen> createState() => _CustomBookingScreenState();
}

class _CustomBookingScreenState extends State<CustomBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _startTime = "09:00";
  String _endTime = "13:00";
  double _durationHours = 4.0;

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

  // Saved Address variables
  Address? _selectedAddress;
  bool _useSavedAddress = true;
  bool _saveNewAddress = false;
  String _customAddressLabel = 'Home';

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  final _promoController = TextEditingController();

  // Coupon / Loyalty variables
  String? _appliedPromoCode;
  double _discountAmount = 0.0;
  bool _redeemLoyaltyPoints = false;
  String? _promoMessage;

  final List<String> _timeSlots = [
    "08:00", "09:00", "10:00", "11:00", "12:00",
    "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses().then((_) {
        final addresses = Provider.of<AddressProvider>(context, listen: false).addresses;
        if (addresses.isNotEmpty) {
          setState(() {
            _selectedAddress = addresses.first;
            _useSavedAddress = true;
          });
        } else {
          setState(() {
            _useSavedAddress = false;
          });
        }
      });
      Provider.of<AuthProvider>(context, listen: false).getProfile();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _calculateDuration() {
    try {
      final startParts = _startTime.split(':');
      final endParts = _endTime.split(':');

      final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      if (endMin <= startMin) {
        setState(() {
          _durationHours = 1.0;
        });
      } else {
        setState(() {
          _durationHours = (endMin - startMin) / 60.0;
        });
      }
    } catch (e) {
      _durationHours = 4.0;
    }
  }

  double _calculateSubtotal() {
    // Custom Cleaning Estimate base: $4/hr or $6/hr base * duration
    final hourlyRate = _cleaningType == 'deep' ? 6.0 : 4.0;
    double baseTotal = _redeemLoyaltyPoints ? 0.0 : (hourlyRate * _durationHours);

    // Add rooms count rates
    baseTotal += (_roomCount * 20.0);
    baseTotal += (_bathroomCount * 30.0);
    baseTotal += (_kitchenCount * 40.0);

    // Add extras (each selected extra is $15)
    _extras.forEach((key, value) {
      if (value) baseTotal += 15.0;
    });

    return baseTotal;
  }

  double _calculateTotal() {
    double subtotal = _calculateSubtotal();

    // Surcharge if urgent
    final now = DateTime.now();
    final difference = _selectedDate.difference(now).inHours;
    double urgentSurcharge = 0.0;
    if (difference < 24) {
      urgentSurcharge = subtotal * 0.2;
    }

    double finalTotal = subtotal + urgentSurcharge - _discountAmount;
    return finalTotal < 0.0 ? 0.0 : finalTotal;
  }

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final provider = Provider.of<BookingProvider>(context, listen: false);
    final subtotal = _calculateSubtotal();

    final selectedExtrasList = _extras.entries.where((e) => e.value).map((e) => e.key).toList();

    final result = await provider.validatePromoCode(
      code: code,
      cleaningType: _cleaningType,
      extras: selectedExtrasList.join(', '),
      subtotal: subtotal,
    );

    if (result['success']) {
      setState(() {
        _appliedPromoCode = code;
        _discountAmount = double.tryParse(result['data']['discount_amount']?.toString() ?? '0.0') ?? 0.0;
        _promoMessage = result['data']['message'] ?? 'Promo applied!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_promoMessage!), backgroundColor: const Color(0xFF0D9488)),
      );
    } else {
      setState(() {
        _appliedPromoCode = null;
        _discountAmount = 0.0;
        _promoMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Invalid promo code'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userPoints = authProvider.user?.loyaltyPoints ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text('Custom Booking Service', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loyalty milestones bar
            if (userPoints > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x240D9488), blurRadius: 12, offset: Offset(0, 4))
                  ],
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
                              const Icon(Icons.stars, color: Colors.amber, size: 24),
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
                        if (userPoints >= 5)
                          Row(
                            children: [
                              const Text('Redeem', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12.5)),
                              Checkbox(
                                value: _redeemLoyaltyPoints,
                                activeColor: Colors.amber,
                                checkColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                onChanged: (val) {
                                  setState(() {
                                    _redeemLoyaltyPoints = val ?? false;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Total: $userPoints pts',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final streakProgress = userPoints % 5;
                        final isCompleted = index < streakProgress;
                        final isGift = index == 4;

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
                                  color: isCompleted ? Colors.amber : Colors.white38,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isGift
                                    ? Icon(
                                        Icons.card_giftcard,
                                        color: isCompleted ? Colors.white : Colors.white70,
                                        size: 20,
                                      )
                                    : (isCompleted
                                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          )),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isGift ? 'Reward' : 'Clean ${index + 1}',
                              style: TextStyle(
                                color: isCompleted ? Colors.amber : Colors.white70,
                                fontSize: 10,
                                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userPoints >= 5 
                          ? '🎉 You unlocked a FREE standard hourly base clean!' 
                          : 'Complete ${5 - (userPoints % 5)} more standard booking(s) to unlock milestone 5!',
                      style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 11.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            // Step 1: Property Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Property Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(child: _buildSegmentItem('House/Apartment')),
                          Expanded(child: _buildSegmentItem('Room Only')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPropertyCounters(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Timings
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2. Advanced Timing selection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.event, color: Color(0xFF0D9488)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTimeSlot(true),
                            child: Row(
                              children: [
                                const Icon(Icons.login, color: Color(0xFF0D9488)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Start Hour', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      Text(_startTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTimeSlot(false),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Icon(Icons.logout, color: Color(0xFFE11D48)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('End Hour', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      Text(_endTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration:', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                          Text('${_durationHours.toStringAsFixed(1)} Hours', style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Cleaning Type & Extras
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('3. Service Upgrades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Normal cleaning'),
                            selected: _cleaningType == 'normal',
                            onSelected: (val) => setState(() => _cleaningType = 'normal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Deep cleaning'),
                            selected: _cleaningType == 'deep',
                            onSelected: (val) => setState(() => _cleaningType = 'deep'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Optional extras:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Column(
                      children: _extras.keys.map((key) {
                        final isSelected = _extras[key]!;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _extras[key] = !isSelected;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    r'+$15.00',
                                    style: TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 4: Addresses
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('4. Location details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Consumer<AddressProvider>(
                      builder: (context, addrProvider, _) {
                        if (addrProvider.addresses.isNotEmpty) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: _useSavedAddress,
                                    activeColor: const Color(0xFF0D9488),
                                    onChanged: (val) => setState(() => _useSavedAddress = true),
                                  ),
                                  const Text('Use Saved Address', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (_useSavedAddress)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBD5E1)), borderRadius: BorderRadius.circular(12)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Address>(
                                      value: _selectedAddress,
                                      isExpanded: true,
                                      onChanged: (Address? val) => setState(() => _selectedAddress = val),
                                      items: addrProvider.addresses.map((a) {
                                        return DropdownMenuItem(value: a, child: Text('${a.label}: ${a.address}, ${a.city}'));
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    groupValue: _useSavedAddress,
                                    activeColor: const Color(0xFF0D9488),
                                    onChanged: (val) => setState(() => _useSavedAddress = false),
                                  ),
                                  const Text('Enter Custom Address', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    if (!_useSavedAddress) ...[
                      const SizedBox(height: 12),
                      _buildTextField('Address*', _addressController, Icons.location_on),
                      const SizedBox(height: 12),
                      _buildTextField('City*', _cityController, Icons.location_city),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _saveNewAddress,
                            activeColor: const Color(0xFF0D9488),
                            onChanged: (val) => setState(() => _saveNewAddress = val ?? false),
                          ),
                          const Text('Save this address to profile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (_saveNewAddress)
                        Row(
                          children: ['Home', 'Work', 'Other'].map((lbl) {
                            final isSel = _customAddressLabel == lbl;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(lbl),
                                selected: isSel,
                                onSelected: (val) => setState(() => _customAddressLabel = lbl),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField('Special Instructions / Notes', _notesController, Icons.note, maxLines: 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Coupon Code Validation Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('5. Apply Promo Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: InputDecoration(
                              hintText: 'Enter coupon (e.g. DEEP20, FIRST10)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _applyPromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (_appliedPromoCode != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Coupon $_appliedPromoCode applied successfully (-\$${_discountAmount.toStringAsFixed(2)})!',
                        style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Receipts / Breakdown Invoicing Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Invoice Summary Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _buildInvoiceRow(
                      'Base cleaning rate (${_cleaningType == "deep" ? "\$6/hr" : "\$4/hr"} x ${_durationHours.toStringAsFixed(1)}h)',
                      '\$${(_redeemLoyaltyPoints ? 0.0 : (_cleaningType == "deep" ? 6.0 : 4.0) * _durationHours).toStringAsFixed(2)}',
                    ),
                    _buildInvoiceRow('Living rooms / bedrooms count rate', '\$${(_roomCount * 20.0).toStringAsFixed(2)}'),
                    _buildInvoiceRow('Bathrooms count rate', '\$${(_bathroomCount * 30.0).toStringAsFixed(2)}'),
                    _buildInvoiceRow('Kitchens count rate', '\$${(_kitchenCount * 40.0).toStringAsFixed(2)}'),
                    if (_extras.entries.any((e) => e.value)) ...[
                      _buildInvoiceRow(
                        'Extras upgrades sum',
                        '\$${(_extras.entries.where((e) => e.value).length * 15.0).toStringAsFixed(2)}',
                      ),
                    ],
                    if (_discountAmount > 0) ...[
                      _buildInvoiceRow('Promo coupon discount', '-\$${_discountAmount.toStringAsFixed(2)}', isDiscount: true),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Final Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        Text('\$${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D9488))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Consumer<BookingProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirm Cleaning Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isDiscount ? Colors.red : const Color(0xFF1E293B), fontSize: 13)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF475569),
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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0D9488)),
              ),
              SizedBox(
                width: 30,
                child: Center(child: Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D9488)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTimeSlot(bool isStart) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isStart ? 'Select Start Hour' : 'Select End Hour', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((time) {
                  final selected = isStart ? (_startTime == time) : (_endTime == time);
                  return ChoiceChip(
                    label: Text(time),
                    selected: selected,
                    selectedColor: const Color(0xFF0D9488),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          if (isStart) {
                            _startTime = time;
                          } else {
                            _endTime = time;
                          }
                          _calculateDuration();
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitRequest() async {
    String addressText = '';
    String cityText = '';

    if (_useSavedAddress) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or add a saved address')));
        return;
      }
      addressText = _selectedAddress!.address;
      cityText = _selectedAddress!.city;
    } else {
      if (_addressController.text.trim().isEmpty || _cityController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter custom address and city')));
        return;
      }
      addressText = _addressController.text.trim();
      cityText = _cityController.text.trim();
    }

    final serviceProvider = context.read<ServiceProvider>();
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.fetchServices();
    }
    final String serviceId = serviceProvider.services.isNotEmpty ? serviceProvider.services.first.id : '';

    if (serviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Services loading error. Please retry.')));
      return;
    }

    final bookingProvider = context.read<BookingProvider>();

    final selectedExtrasList = _extras.entries.where((e) => e.value).map((e) => e.key).toList();

    final success = await bookingProvider.createBooking(
      serviceId: serviceId,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      bookingTime: _startTime,
      startTime: _startTime,
      endTime: _endTime,
      durationHours: _durationHours,
      address: addressText,
      city: cityText,
      notes: _notesController.text.trim(),
      isCustom: true,
      propertyType: _propertyType,
      roomCount: _roomCount,
      bathroomsCount: _bathroomCount,
      kitchensCount: _kitchenCount,
      cleaningType: _cleaningType,
      extras: selectedExtrasList.join(', '),
      discountAmount: _discountAmount,
      promoCode: _appliedPromoCode,
      redeemLoyalty: _redeemLoyaltyPoints,
      saveAddress: !_useSavedAddress && _saveNewAddress,
      addressLabel: _customAddressLabel,
    );

    if (success) {
      final created = bookingProvider.lastCreatedBooking;
      if (created != null) {
        Navigator.pushReplacementNamed(context, '/booking-confirmation', arguments: created);
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.error ?? 'Request failed'), backgroundColor: Colors.red),
      );
    }
  }
}
