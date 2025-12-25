import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/journal_entry.dart';
import '../../../../core/utils/mood_analyzer.dart';

class MoodCalendar extends StatefulWidget {
  final List<JournalEntry> journals;

  const MoodCalendar({super.key, required this.journals});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late Map<DateTime, List<JournalEntry>> _groupedJournals;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _groupJournals();
  }

  // FIX: Update calendar when new journals are added!
  @override
  void didUpdateWidget(covariant MoodCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journals != widget.journals) {
      _groupJournals();
    }
  }

  void _groupJournals() {
    _groupedJournals = {};
    for (var entry in widget.journals) {
      // Normalize date to UTC midnight to match TableCalendar's logic
      final date =
          DateTime.utc(entry.date.year, entry.date.month, entry.date.day);
      if (_groupedJournals[date] == null) _groupedJournals[date] = [];
      _groupedJournals[date]!.add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarFormat: CalendarFormat.month,
      headerStyle:
          const HeaderStyle(formatButtonVisible: false, titleCentered: true),

      calendarStyle: CalendarStyle(
        // Ensure today doesn't override our mood colors
        todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            shape: BoxShape.circle),
        markerDecoration: const BoxDecoration(color: Colors.transparent),
        defaultTextStyle:
            TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),

      // THIS BUILDER COLORS THE DAYS
      calendarBuilders:
          CalendarBuilders(defaultBuilder: (context, day, focusedDay) {
        // Normalize day to check against our map
        final normalizedDay = DateTime.utc(day.year, day.month, day.day);
        final entries = _groupedJournals[normalizedDay];

        if (entries != null && entries.isNotEmpty) {
          // Use the mood of the LATEST entry for that day
          final mood = entries.first.mood ?? 'Neutral';
          final label = MoodAnalyzer.getLabel(mood);
          final colorInt = MoodAnalyzer.getColor(label);

          return Container(
            margin: const EdgeInsets.all(6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(colorInt).withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${day.day}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        }
        return null;
      },
              // Also apply mood color to "Today" if there is an entry
              todayBuilder: (context, day, focusedDay) {
        final normalizedDay = DateTime.utc(day.year, day.month, day.day);
        final entries = _groupedJournals[normalizedDay];

        if (entries != null && entries.isNotEmpty) {
          final mood = entries.first.mood ?? 'Neutral';
          final label = MoodAnalyzer.getLabel(mood);
          final colorInt = MoodAnalyzer.getColor(label);

          return Container(
            margin: const EdgeInsets.all(6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color(colorInt), // Solid color for today
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).primaryColor, width: 2)),
            child: Text(
              '${day.day}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        }
        return null;
      }),
    );
  }
}
