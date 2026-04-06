import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/di/service_locator.dart';
import '../bloc/event_bloc.dart';
import '../data/event_model.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventBloc>()..add(const LoadEventsEvent()),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatelessWidget {
  const _EventsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Row(children: [
                    Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Text('Offline — cached content', style: TextStyle(color: Colors.orange.shade800, fontSize: 13)),
                  ]),
                ),
              Expanded(
                child: switch (state) {
                  EventLoading() => const Center(child: CircularProgressIndicator()),
                  EventLoaded(:final items) => items.isEmpty
                      ? const Center(child: Text('No upcoming events'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) => _EventCard(event: items[i]),
                        ),
                  EventError(:final message) => Center(child: Text(message)),
                  _ => const SizedBox(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CampusEvent event;
  const _EventCard({required this.event});

  Future<void> _attachPhoto(BuildContext context) async {
    // Request camera permission at runtime
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                if (context.mounted) Navigator.pop(context, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (context.mounted) Navigator.pop(context, img);
              },
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo attached: ${result.name}')),
      );
    }
  }

  Color _catColor(String cat) => switch (cat) {
        'academic' => Colors.purple,
        'career' => Colors.indigo,
        'sports' => Colors.green,
        _ => Colors.teal,
      };

  @override
  Widget build(BuildContext context) {
    final color = _catColor(event.category);
    final daysUntil = event.eventDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(event.category.toUpperCase(),
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (daysUntil <= 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      daysUntil == 0 ? 'Today!' : 'In $daysUntil days',
                      style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(DateFormat('EEE, MMM d  •  HH:mm').format(event.eventDate),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(event.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _attachPhoto(context),
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Attach Photo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
