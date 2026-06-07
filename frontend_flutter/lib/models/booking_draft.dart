class BookingDraft {
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final String cleaningType;
  final double durationHours;
  final String startTime;
  final String endTime;
  final String? notes;

  const BookingDraft({
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.cleaningType,
    required this.durationHours,
    this.startTime = '09:00',
    this.endTime = '13:00',
    this.notes,
  });

  factory BookingDraft.fromRecommendation(
    Map<String, dynamic> data, {
    Map<String, String>? answers,
  }) {
    final duration =
        double.tryParse(data['durationHours']?.toString() ?? '') ?? 4.0;
    final start = '09:00';
    final end = _endTimeFromDuration(start, duration);

    final noteParts = <String>[];
    if (answers != null && answers.isNotEmpty) {
      noteParts.add('AI plan: ${answers['situation'] ?? 'custom assessment'}');
    }

    return BookingDraft(
      propertyType: (data['propertyType'] ?? 'House/Apartment').toString(),
      bedrooms: int.tryParse(data['bedrooms']?.toString() ?? '') ?? 2,
      bathrooms: int.tryParse(data['bathrooms']?.toString() ?? '') ?? 1,
      kitchens: int.tryParse(data['kitchens']?.toString() ?? '') ?? 1,
      cleaningType: (data['cleaningType'] ?? 'normal').toString(),
      durationHours: duration,
      startTime: start,
      endTime: end,
      notes: noteParts.isEmpty ? null : noteParts.join(' · '),
    );
  }

  static String _endTimeFromDuration(String startTime, double hours) {
    try {
      final parts = startTime.split(':');
      final startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final endMinutes = startMinutes + (hours * 60).round();
      final h = (endMinutes ~/ 60) % 24;
      final m = endMinutes % 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return '13:00';
    }
  }
}
