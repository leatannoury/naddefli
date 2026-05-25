import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../models/service.dart';
import '../models/address.dart';
import '../providers/booking_provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/pricing.dart';
import '../services/app_settings_service.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate;
  String _startTime = "09:00";
  String _endTime = "13:00";
  double _durationHours = 4.0;

  String _cleaningType = 'normal';
  final Set<String> _selectedAddons = {};

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

  final Map<String, double> _addOnPrices = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _cleaningType =
        widget.service.name.toLowerCase().contains('deep') ? 'deep' : 'normal';

    _addOnPrices.clear();

    AppSettingsService.getPublicAddOns(forceRefresh: true).then((globals) {
      if (!mounted) return;
      setState(() {
        _addOnPrices.clear();
        for (final addon in globals) {
          final name =
              (addon['name'] ?? addon['title'] ?? '').toString().trim();
          final price =
              double.tryParse((addon['price'] ?? '').toString()) ?? 0.0;
          if (name.isNotEmpty) {
            _addOnPrices[name] = price;
          }
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false)
          .fetchAddresses()
          .then((_) {
        final addresses =
            Provider.of<AddressProvider>(context, listen: false).addresses;
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
    final base = _redeemLoyaltyPoints
        ? 0.0
        : Pricing.hourlyRate(_cleaningType) * _durationHours;
    double addons = 0.0;
    for (final name in _selectedAddons) {
      addons += _addOnPrices[name] ?? 0.0;
    }
    return base + addons;
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
    return MathMax(0.0, finalTotal);
  }

  double MathMax(double a, double b) => a > b ? a : b;

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final provider = Provider.of<BookingProvider>(context, listen: false);
    final subtotal = _calculateSubtotal();

    final result = await provider.validatePromoCode(
      code: code,
      cleaningType: _cleaningType,
      extras: _selectedAddons.join(', '),
      subtotal: subtotal,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    if (result['success']) {
      setState(() {
        _appliedPromoCode = code;
        _discountAmount = double.tryParse(
                result['data']['discount_amount']?.toString() ?? '0.0') ??
            0.0;
        _promoMessage = result['data']['message'] ?? 'Promo applied!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_promoMessage!),
            backgroundColor: const Color(0xFF0D9488)),
      );
    } else {
      setState(() {
        _appliedPromoCode = null;
        _discountAmount = 0.0;
        _promoMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Invalid promo code'),
            backgroundColor: Colors.red),
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
        title: Text(
          'Book ${widget.service.name}',
          style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
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
                    BoxShadow(
                        color: Color(0x240D9488),
                        blurRadius: 12,
                        offset: Offset(0, 4))
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
                              const Icon(Icons.stars,
                                  color: Colors.amber, size: 24),
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
                              const Text('Redeem',
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)),
                              Checkbox(
                                value: _redeemLoyaltyPoints,
                                activeColor: Colors.amber,
                                checkColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Total: $userPoints pts',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
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
                                  color: isCompleted
                                      ? Colors.amber
                                      : Colors.white38,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isGift
                                    ? Icon(
                                        Icons.card_giftcard,
                                        color: isCompleted
                                            ? Colors.white
                                            : Colors.white70,
                                        size: 20,
                                      )
                                    : (isCompleted
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 20)
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
                                color:
                                    isCompleted ? Colors.amber : Colors.white70,
                                fontSize: 10,
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                      style: const TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            // Date & Start/End Time Selection Card
            Card(
              elevation: 2,
              shadowColor: const Color(0x1F000000),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Advanced Scheduling',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B)),
                    ),
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
                                const Text('Date',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B))),
                                Text(
                                  DateFormat('EEEE, MMM d, yyyy')
                                      .format(_selectedDate),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
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
                                const Icon(Icons.login,
                                    color: Color(0xFF0D9488)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Start Hour',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B))),
                                      Text(_startTime,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFFE2E8F0)),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTimeSlot(false),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Icon(Icons.logout,
                                    color: Color(0xFFE11D48)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('End Hour',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B))),
                                      Text(_endTime,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Booking Duration:',
                            style: TextStyle(
                                color: Color(0xFF0D9488),
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_durationHours.toStringAsFixed(1)} Hours',
                            style: const TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selectable Add-ons List Card
            Card(
              elevation: 2,
              shadowColor: const Color(0x1F000000),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. Selectable Add-ons',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _addOnPrices.entries.map((entry) {
                        final addon = entry.key;
                        final price = entry.value;
                        final isSelected = _selectedAddons.contains(addon);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedAddons.remove(addon);
                              } else {
                                _selectedAddons.add(addon);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF0FDFA)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0D9488)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0D9488)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF0D9488)
                                          : const Color(0xFFCBD5E1),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    addon,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFCCFBF1)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+\$${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFF64748B),
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

            // Saved Addresses / Address Fields Selection Card
            Card(
              elevation: 2,
              shadowColor: const Color(0x1F000000),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3. Address Information',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 16),
                    Consumer<AddressProvider>(
                      builder: (context, addrProvider, _) {
                        if (addrProvider.addresses.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: _useSavedAddress,
                                    activeColor: const Color(0xFF0D9488),
                                    onChanged: (val) {
                                      setState(() {
                                        _useSavedAddress = true;
                                      });
                                    },
                                  ),
                                  const Text('Use Saved Address',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (_useSavedAddress)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Address>(
                                      value: _selectedAddress,
                                      isExpanded: true,
                                      hint: const Text('Select an address'),
                                      onChanged: (Address? value) {
                                        setState(() {
                                          _selectedAddress = value;
                                        });
                                      },
                                      items: addrProvider.addresses
                                          .map((Address addr) {
                                        return DropdownMenuItem<Address>(
                                          value: addr,
                                          child: Text(
                                              '${addr.label}: ${addr.address}, ${addr.city}'),
                                        );
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
                                    onChanged: (val) {
                                      setState(() {
                                        _useSavedAddress = false;
                                      });
                                    },
                                  ),
                                  const Text('Enter Custom Address',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return const Text(
                              'Enter your service location details below:',
                              style: TextStyle(color: Color(0xFF64748B)));
                        }
                      },
                    ),
                    if (!_useSavedAddress) ...[
                      const SizedBox(height: 12),
                      _buildTextField('Address details (Street / Area)*',
                          _addressController, Icons.location_on_outlined),
                      const SizedBox(height: 12),
                      _buildTextField(
                          'City*', _cityController, Icons.location_city),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _saveNewAddress,
                            activeColor: const Color(0xFF0D9488),
                            onChanged: (val) {
                              setState(() {
                                _saveNewAddress = val ?? false;
                              });
                            },
                          ),
                          const Text('Save this address to profile',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (_saveNewAddress)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Row(
                            children: ['Home', 'Work', 'Other'].map((lbl) {
                              final isSelected = _customAddressLabel == lbl;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(lbl),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF0D9488),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _customAddressLabel = lbl;
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField('Notes / special instructions (Optional)',
                        _notesController, Icons.note,
                        maxLines: 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Coupon Code Validation Card
            Card(
              elevation: 2,
              shadowColor: const Color(0x1F000000),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. Add Promo Code',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: InputDecoration(
                              hintText:
                                  'Enter coupon (e.g. DEEP20, WINDOWFREE)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _applyPromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Apply',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (_appliedPromoCode != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Coupon $_appliedPromoCode applied successfully (-\$${_discountAmount.toStringAsFixed(2)})!',
                              style: const TextStyle(
                                  color: Color(0xFF0D9488),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _appliedPromoCode = null;
                                _discountAmount = 0.0;
                                _promoController.clear();
                              });
                            },
                            icon: const Icon(Icons.close,
                                color: Color(0xFF0D9488)),
                            tooltip: 'Remove promo',
                          )
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Receipts / Breakdown Invoicing Card
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Receipt Breakdown',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _buildInvoiceRow(
                      'Base cleaning rate (${_cleaningType == "deep" ? "\$6/hr" : "\$4/hr"} x ${_durationHours.toStringAsFixed(1)}h)',
                      '\$${(_redeemLoyaltyPoints ? 0.0 : (_cleaningType == "deep" ? 6.0 : 4.0) * _durationHours).toStringAsFixed(2)}',
                    ),
                    if (_selectedAddons.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInvoiceRow(
                        'Add-ons sum (${_selectedAddons.length})',
                        '\$${_selectedAddons.fold(0.0, (double sum, String item) => sum + (_addOnPrices[item] ?? 0.0)).toStringAsFixed(2)}',
                      ),
                    ],
                    if (_discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      _buildInvoiceRow(
                        'Discount applied (${_appliedPromoCode ?? ""})',
                        '-\$${_discountAmount.toStringAsFixed(2)}',
                        isDiscount: true,
                      ),
                    ],
                    if (_redeemLoyaltyPoints) ...[
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Loyalty reward applied',
                              style: TextStyle(
                                  color: Color(0xFF0D9488),
                                  fontWeight: FontWeight.bold)),
                          Text('Base Rate Free!',
                              style: TextStyle(
                                  color: Color(0xFF0D9488),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Final Price',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B))),
                        Text('\$${_calculateTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF0D9488))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Booking Button
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        bookingProvider.isLoading ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: bookingProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirm Cleaning Booking',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDiscount ? Colors.red : const Color(0xFF1E293B),
                fontSize: 13)),
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
        prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
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
    final hours = List<int>.generate(12, (i) => i + 1);
    final minutes = [0, 15, 30, 45];
    final ampm = ['AM', 'PM'];

    String current = isStart ? _startTime : _endTime;
    int curH = 0, curM = 0;
    String curAmp = 'AM';
    try {
      final parts = current.split(':');
      final h24 = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      curAmp = h24 >= 12 ? 'PM' : 'AM';
      curH = h24 % 12 == 0 ? 12 : h24 % 12;
      curM = minutes.contains(m) ? m : (m ~/ 15) * 15;
    } catch (_) {
      curH = 9;
      curM = 0;
      curAmp = 'AM';
    }

    int selHour = curH;
    int selMin = curM;
    int selAmp = curAmp == 'PM' ? 1 : 0;

    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        builder: (ctx) {
          return SizedBox(
            height: 320,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      Text(isStart ? 'Select Start Time' : 'Select End Time',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {
                            int hour12 = selHour % 12;
                            int hour24 = hour12 + (selAmp == 1 ? 12 : 0);
                            if (selHour == 12 && selAmp == 0) hour24 = 0;
                            final timeStr =
                                '${hour24.toString().padLeft(2, '0')}:${selMin.toString().padLeft(2, '0')}';
                            setState(() {
                              if (isStart)
                                _startTime = timeStr;
                              else
                                _endTime = timeStr;
                              _calculateDuration();
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Confirm')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: selHour - 1),
                          itemExtent: 32,
                          onSelectedItemChanged: (i) => selHour = hours[i],
                          children: hours
                              .map((h) => Center(child: Text('$h')))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: minutes.indexOf(selMin)),
                          itemExtent: 32,
                          onSelectedItemChanged: (i) => selMin = minutes[i],
                          children: minutes
                              .map((m) => Center(
                                  child: Text(m.toString().padLeft(2, '0'))))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController:
                              FixedExtentScrollController(initialItem: selAmp),
                          itemExtent: 32,
                          onSelectedItemChanged: (i) => selAmp = i,
                          children:
                              ampm.map((s) => Center(child: Text(s))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _confirmBooking() async {
    String addressText = '';
    String cityText = '';

    if (_useSavedAddress) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please select or add a saved address')));
        return;
      }
      addressText = _selectedAddress!.address;
      cityText = _selectedAddress!.city;
    } else {
      if (_addressController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please enter custom address and city')));
        return;
      }
      addressText = _addressController.text.trim();
      cityText = _cityController.text.trim();
    }

    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    final success = await bookingProvider.createBooking(
      serviceId: widget.service.id,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      bookingTime: _startTime,
      startTime: _startTime,
      endTime: _endTime,
      durationHours: _durationHours,
      address: addressText,
      city: cityText,
      notes: _notesController.text.trim(),
      isCustom: false,
      propertyType: widget.service.name,
      cleaningType: _cleaningType,
      extras: _selectedAddons.join(', '),
      discountAmount: _discountAmount,
      promoCode: _appliedPromoCode,
      redeemLoyalty: _redeemLoyaltyPoints,
      saveAddress: !_useSavedAddress && _saveNewAddress,
      addressLabel: _customAddressLabel,
    );

    if (success) {
      final created = bookingProvider.lastCreatedBooking;
      if (created != null) {
        Navigator.pushReplacementNamed(context, '/booking-confirmation',
            arguments: created);
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(bookingProvider.error ?? 'Booking failed'),
            backgroundColor: Colors.red),
      );
    }
  }
}
