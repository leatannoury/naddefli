import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/app_styles.dart';

class BookingCalendarSection extends StatefulWidget {
  final List<dynamic> bookings;
  final Widget Function(dynamic booking) bookingCardBuilder;

  const BookingCalendarSection({
    Key? key,
    required this.bookings,
    required this.bookingCardBuilder,
  }) : super(key: key);

  @override
  State<BookingCalendarSection> createState() => _BookingCalendarSectionState();
}

class _BookingCalendarSectionState extends State<BookingCalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Map<DateTime, List<dynamic>> get _bookingsByDay {
    final map = <DateTime, List<dynamic>>{};
    for (final booking in widget.bookings) {
      try {
        final date = booking.bookingDate as DateTime;
        final key = DateTime(date.year, date.month, date.day);
        map.putIfAbsent(key, () => []).add(booking);
      } catch (_) {}
    }
    return map;
  }

  List<dynamic> _getBookingsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _bookingsByDay[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedBookings = _selectedDay != null
        ? _getBookingsForDay(_selectedDay!)
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
          padding: const EdgeInsets.all(AppStyles.paddingMedium),
          child: TableCalendar<dynamic>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: _getBookingsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: AppColors.onSurfaceVariant),
              defaultTextStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              markerSize: 6,
              markerMargin: const EdgeInsets.only(top: 32),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
              formatButtonTextStyle: AppStyles.labelBold.copyWith(
                color: AppColors.primary,
              ),
              titleTextStyle: AppStyles.headlineSmall.copyWith(fontSize: 17),
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppStyles.labelBold.copyWith(color: AppColors.onSurfaceVariant),
              weekendStyle: AppStyles.labelBold.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: AppStyles.paddingBase),
        if (_selectedDay != null) ...[
          Row(
            children: [
              Icon(Icons.event_note, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d').format(_selectedDay!),
                  style: AppStyles.headlineSmall.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedBookings.length} booking${selectedBookings.length == 1 ? '' : 's'}',
                  style: AppStyles.labelBold.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingSmall),
          if (selectedBookings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              decoration: AppDecorations.elevatedCard(),
              child: Text(
                'No bookings on this day.',
                textAlign: TextAlign.center,
                style: AppStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            ...selectedBookings.map(widget.bookingCardBuilder),
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyles.paddingLarge),
            decoration: AppDecorations.elevatedCard(),
            child: Row(
              children: [
                Icon(Icons.touch_app_outlined, color: AppColors.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap a highlighted day to view your bookings.',
                    style: AppStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
