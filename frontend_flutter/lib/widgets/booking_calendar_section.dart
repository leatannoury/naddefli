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

  bool _hasBookings(DateTime day) => _getBookingsForDay(day).isNotEmpty;

  Widget _buildDayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final hasBookings = _hasBookings(day);

    BoxDecoration decoration;
    TextStyle textStyle;

    if (isSelected) {
      decoration = const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      );
      textStyle = const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      );
    } else if (isToday && hasBookings) {
      decoration = BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      );
      textStyle = const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      );
      textStyle = const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      );
    } else if (hasBookings) {
      decoration = BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.55),
          width: 1.5,
        ),
      );
      textStyle = const TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      );
    } else {
      decoration = const BoxDecoration(shape: BoxShape.circle);
      textStyle = const TextStyle(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(5),
      width: 38,
      height: 38,
      decoration: decoration,
      alignment: Alignment.center,
      child: Text('${day.day}', style: textStyle),
    );
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
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 0,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day),
              todayBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, isToday: true),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, isSelected: true),
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
                    'Days with a purple highlight have bookings — tap one to see details.',
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
