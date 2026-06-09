// =============================================================================
// NADDEFLI — pricing.dart
// Layer: Flutter — Utility
// Purpose: Client-side price calculation for custom bookings (hours × rate + add-ons).
// Connects to: Mirrors backend pricing logic for live UI updates
// =============================================================================

/// Lebanon/Zahle realistic cleaning pricing (hours + add-ons only).
class Pricing {
  static const double normalHourlyRate = 4.0;
  static const double deepHourlyRate = 6.0;

  static const Map<String, double> addonPrices = {};

  static double hourlyRate(String cleaningType) =>
      cleaningType == 'deep' ? deepHourlyRate : normalHourlyRate;

  static double addonsTotal(Iterable<String> selected) {
    double total = 0;
    for (final name in selected) {
      total += addonPrices[name] ?? 0;
    }
    return total;
  }

  static double calculateSubtotal({
    required String cleaningType,
    required double durationHours,
    required Iterable<String> selectedAddons,
    bool loyaltyFreeBase = false,
  }) {
    final base = loyaltyFreeBase
        ? 0.0
        : hourlyRate(cleaningType) * durationHours;
    return base + addonsTotal(selectedAddons);
  }
}
