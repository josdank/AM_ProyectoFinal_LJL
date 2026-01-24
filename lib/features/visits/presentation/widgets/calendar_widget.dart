import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget simple de calendario para mostrar visitas
class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> markedDates;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    this.markedDates = const [],
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con mes/año
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final previousMonth = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                  );
                  onDateSelected(previousMonth);
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'es').format(selectedDate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final nextMonth = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                  );
                  onDateSelected(nextMonth);
                },
              ),
            ],
          ),
        ),

        // Días de la semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Grid de días
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildDaysGrid(context),
        ),
      ],
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);

    final startingWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final days = <Widget>[];

    // Espacios vacíos antes del primer día
    for (int i = 1; i < startingWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final isSelected = _isSameDay(date, selectedDate);
      final isMarked = markedDates.any((d) => _isSameDay(d, date));
      final isToday = _isSameDay(date, DateTime.now());

      days.add(
        InkWell(
          onTap: () => onDateSelected(date),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : null,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isMarked)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}