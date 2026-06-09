// =============================================================================
// NADDEFLI — custom_booking_screen.dart
// Layer: Flutter — Screen
// Purpose: Custom cleaning builder: property type, room counts, deep/normal, add-ons, loyalty redeem.
// Connects to: POST /api/bookings/create with is_custom=true; can be pre-filled from BookingDraft (AI)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../providers/service_provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../models/address.dart';
import '../models/booking_draft.dart';
import '../utils/pricing.dart';
import '../services/app_settings_service.dart';
import '../utils/app_styles.dart';
import '../widgets/booking_form_ui.dart';

class CustomBookingScreen extends StatefulWidget {
  const CustomBookingScreen({Key? key}) : super(key: key);

  @override
  State<CustomBookingScreen> createState() => _CustomBookingScreenState();
}

class _CustomBookingScreenState extends State<CustomBookingScreen> {
  bool _initializedFromDraft = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _startTime = "09:00";
  String _endTime = "13:00";
  double _durationHours = 4.0;

  String _propertyType = 'House/Apartment';
  int _roomCount = 2;
  int _bathroomCount = 1;
  int _kitchenCount = 1;
  String _cleaningType = 'normal'; // normal, deep

  Map<String, bool> _extras = {};
  final Map<String, double> _addOnPrices = {};

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromDraft) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is BookingDraft) {
        setState(() {
          _propertyType = args.propertyType;
          _roomCount = args.bedrooms;
          _bathroomCount = args.bathrooms;
          _kitchenCount = args.kitchens;
          _cleaningType = args.cleaningType;
          _durationHours = args.durationHours;
          _startTime = args.startTime;
          _endTime = args.endTime;
          if (args.notes != null && args.notes!.isNotEmpty) {
            _notesController.text = args.notes!;
          }
        });
      }
      _initializedFromDraft = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSettingsService.getPublicAddOns(forceRefresh: true).then((addons) {
        final Map<String, bool> extrasMap = {};
        final Map<String, double> pricesMap = {};

        for (final addon in addons) {
          final name =
              (addon['name'] ?? addon['title'] ?? '').toString().trim();
          final price =
              double.tryParse((addon['price'] ?? '').toString()) ?? 0.0;
          if (name.isEmpty) continue;
          extrasMap.putIfAbsent(name, () => false);
          pricesMap[name] = price;
        }

        if (mounted) {
          setState(() {
            _extras = extrasMap;
            _addOnPrices.clear();
            _addOnPrices.addAll(pricesMap);
          });
        }
      });
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
    final selectedAddons =
        _extras.entries.where((e) => e.value).map((e) => e.key);
    final base = _redeemLoyaltyPoints
        ? 0.0
        : Pricing.hourlyRate(_cleaningType) * _durationHours;
    double addonsTotal = 0.0;
    for (final k in selectedAddons) {
      addonsTotal += _addOnPrices[k] ?? 0.0;
    }
    return base + addonsTotal;
  }

  double _calculateTotal() {
    double subtotal = _calculateSubtotal();

    double finalTotal =
        subtotal - (_redeemLoyaltyPoints ? 0.0 : _discountAmount);
    return finalTotal < 0.0 ? 0.0 : finalTotal;
  }

  Future<void> _applyPromoCode() async {
    if (_redeemLoyaltyPoints) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Remove the free cleaning reward before applying a promo code.'),
      ));
      return;
    }
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final provider = Provider.of<BookingProvider>(context, listen: false);
    final subtotal = _calculateSubtotal();

    final selectedExtrasList =
        _extras.entries.where((e) => e.value).map((e) => e.key).toList();

    final result = await provider.validatePromoCode(
      code: code,
      cleaningType: _cleaningType,
      extras: selectedExtrasList.join(', '),
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
            backgroundColor: AppColors.primary),
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
    final loyaltyProgress = authProvider.user?.loyaltyProgress ?? 0;
    final rewardsAvailable = authProvider.user?.loyaltyRewardsAvailable ?? 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookingFormUi.appBar(context, 'Custom Cleaning'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.paddingBase),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BookingFormUi.gradientHeader(
              title: 'Customize Your Clean',
              subtitle: 'Pick your cleaning type, schedule, add-ons, and address — all in one flow.',
              icon: Icons.tune_rounded,
              colors: const [AppColors.primary, AppColors.primaryContainer],
            ),
            // Loyalty milestones bar
            if (loyaltyProgress > 0 || rewardsAvailable > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
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
                        if (rewardsAvailable > 0 && _cleaningType == 'normal')
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
                                    if (_redeemLoyaltyPoints) {
                                      _appliedPromoCode = null;
                                      _discountAmount = 0.0;
                                      _promoController.clear();
                                    }
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
                              rewardsAvailable == 1
                                  ? '1 reward ready'
                                  : '$rewardsAvailable rewards ready',
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
                      children: List.generate(4, (index) {
                        final isCompleted = index < loyaltyProgress;

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
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Clean ${index + 1}',
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
                      rewardsAvailable > 0
                          ? 'Your free normal cleaning reward is ready to redeem.'
                          : 'Complete ${4 - loyaltyProgress} more cleaning(s) to unlock a free normal cleaning.',
                      style: const TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            // Step 1: Cleaning type
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Cleaning type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    const Text('Normal \$4/hr · Deep \$6/hr',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Normal'),
                            selected: _cleaningType == 'normal',
                            onSelected: (_) =>
                                setState(() => _cleaningType = 'normal'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Deep'),
                            selected: _cleaningType == 'deep',
                            onSelected: (_) => setState(() {
                              _cleaningType = 'deep';
                              _redeemLoyaltyPoints = false;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note: duration and focus areas removed; using advanced timing below

            // Step 3: Timings
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Time',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.event, color: AppColors.primary),
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
                                        fontSize: 15)),
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
                                    color: AppColors.primary),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration:',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                          Text('${_durationHours.toStringAsFixed(1)} Hours',
                              style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Paid add-ons
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('4. Paid add-ons',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    const Text('Tap to add extras:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF0FDFA)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
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
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
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
                                    key,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: AppColors.onSurface,
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
                                    '+\$${(_addOnPrices[key] ?? 0.0).toStringAsFixed(2)}',
                                    style: const TextStyle(
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('4. Location details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
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
                                    activeColor: AppColors.primary,
                                    onChanged: (val) =>
                                        setState(() => _useSavedAddress = true),
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
                                      borderRadius: BorderRadius.circular(12)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Address>(
                                      value: _selectedAddress,
                                      isExpanded: true,
                                      onChanged: (Address? val) => setState(
                                          () => _selectedAddress = val),
                                      items: addrProvider.addresses.map((a) {
                                        return DropdownMenuItem(
                                            value: a,
                                            child: Text(
                                                '${a.label}: ${a.address}, ${a.city}'));
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    groupValue: _useSavedAddress,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(
                                        () => _useSavedAddress = false),
                                  ),
                                  const Text('Enter Custom Address',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                      _buildTextField(
                          'Address*', _addressController, Icons.location_on),
                      const SizedBox(height: 12),
                      _buildTextField(
                          'City*', _cityController, Icons.location_city),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _saveNewAddress,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _saveNewAddress = val ?? false),
                          ),
                          const Text('Save this address to profile',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                                onSelected: (val) =>
                                    setState(() => _customAddressLabel = lbl),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField('Special Instructions / Notes',
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('5. Apply Promo Code',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: InputDecoration(
                              hintText: 'Enter coupon (e.g. DEEP20, FIRST10)',
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
                            backgroundColor: AppColors.onSurface,
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
                                  color: AppColors.primary,
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
                                color: AppColors.primary),
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
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Invoice Summary Breakdown',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _buildInvoiceRow(
                      'Base cleaning rate (${_cleaningType == "deep" ? "\$6/hr" : "\$4/hr"} x ${_durationHours.toStringAsFixed(1)}h)',
                      '\$${(_redeemLoyaltyPoints ? 0.0 : (_cleaningType == "deep" ? 6.0 : 4.0) * _durationHours).toStringAsFixed(2)}',
                    ),
                    ..._extras.entries
                        .where((e) => e.value)
                        .map((e) => _buildInvoiceRow(
                              e.key,
                              '+\$${(_addOnPrices[e.key] ?? 0.0).toStringAsFixed(2)}',
                            )),
                    if (_discountAmount > 0 && !_redeemLoyaltyPoints) ...[
                      _buildInvoiceRow('Promo coupon discount',
                          '-\$${_discountAmount.toStringAsFixed(2)}',
                          isDiscount: true),
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
                                color: AppColors.primary)),
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
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirm Cleaning Request',
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
                color: isDiscount ? Colors.red : AppColors.onSurface,
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
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                            // convert to 24h
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

  void _submitRequest() async {
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

    final serviceProvider = context.read<ServiceProvider>();
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.fetchServices();
    }
    final String serviceId = serviceProvider.services.isNotEmpty
        ? serviceProvider.services.first.id
        : '';

    if (serviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Services loading error. Please retry.')));
      return;
    }

    final bookingProvider = context.read<BookingProvider>();

    final selectedExtrasList =
        _extras.entries.where((e) => e.value).map((e) => e.key).toList();

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
      await context.read<AuthProvider>().getProfile();
      if (!mounted) return;
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
            content: Text(bookingProvider.error ?? 'Request failed'),
            backgroundColor: Colors.red),
      );
    }
  }
}
