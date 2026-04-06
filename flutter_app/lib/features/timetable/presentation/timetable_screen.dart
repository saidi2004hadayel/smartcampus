import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/service_locator.dart';
import '../bloc/timetable_bloc.dart';
import '../data/timetable_model.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TimetableBloc>()..add(const LoadTimetableEvent()),
      child: const _TimetableView(),
    );
  }
}

class _TimetableView extends StatefulWidget {
  const _TimetableView();
  @override State<_TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<_TimetableView> {
  int _selectedDay = DateTime.now().weekday - 1;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _exportJson(BuildContext context, String jsonContent) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/timetable.json');
    await file.writeAsString(jsonContent);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'SmartCampus Timetable',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<TimetableBloc, TimetableState>(
      listener: (context, state) {
        if (state is TimetableReminderSet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder set for ${state.courseName}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is TimetableExported) {
          _exportJson(context, state.jsonContent);
        }
        if (state is TimetableError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Schedule'),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Export as JSON',
                onPressed: () =>
                    context.read<TimetableBloc>().add(ExportTimetableEvent()),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Day selector ─────────────────────────────────────────────
              Container(
                color: theme.colorScheme.primary.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_days.length, (i) {
                    final isSelected = i == _selectedDay;
                    final isToday = i == DateTime.now().weekday - 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDay = i);
                        context.read<TimetableBloc>().add(
                              LoadTimetableEvent(filterDay: i),
                            );
                      },
                      child: Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isToday && !isSelected
                              ? Border.all(color: theme.colorScheme.primary)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _days[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ── Entries ───────────────────────────────────────────────────
              Expanded(
                child: switch (state) {
                  TimetableLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  TimetableLoaded(:final entries) => entries.isEmpty
                      ? _EmptyDay(day: _days[_selectedDay])
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: entries.length,
                          itemBuilder: (_, i) => _EntryCard(entry: entries[i]),
                        ),
                  TimetableError(:final message) =>
                    Center(child: Text(message)),
                  _ => const SizedBox(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  final TimetableEntry entry;
  const _EntryCard({required this.entry});

  Color _typeColor(String t) => switch (t) {
        'lab' => Colors.orange,
        'tutorial' => Colors.teal,
        _ => Colors.indigo,
      };

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(entry.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Colored side bar ────────────────────────────────────────
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            entry.type.toUpperCase(),
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.courseCode,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.courseName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.startTime} – ${entry.endTime}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 14),
                        Icon(Icons.room_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          entry.room,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          entry.professor,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        // ── Reminder button ──────────────────────────────
                        TextButton.icon(
                          onPressed: () => context
                              .read<TimetableBloc>()
                              .add(ScheduleReminderEvent(entry)),
                          icon: const Icon(Icons.notifications_none, size: 16),
                          label: const Text('Remind me',
                              style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final String day;
  const _EmptyDay({required this.day});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.free_breakfast_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No classes on $day',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
