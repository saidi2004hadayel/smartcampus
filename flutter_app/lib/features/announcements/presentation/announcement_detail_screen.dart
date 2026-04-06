import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/announcement_repository.dart';
import '../data/announcement_model.dart';
import '../../../core/di/service_locator.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final String id;
  const AnnouncementDetailScreen({super.key, required this.id});
  @override State<AnnouncementDetailScreen> createState() => _State();
}

class _State extends State<AnnouncementDetailScreen> {
  Announcement? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final item = await sl<AnnouncementRepository>().getById(widget.id);
      setState(() { _item = item; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _item == null
                  ? const Center(child: Text('Not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_item!.isImportant)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                              child: const Text('IMPORTANT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          Text(_item!.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(_item!.author, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(DateFormat('MMMM d, yyyy').format(_item!.createdAt),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ]),
                          const Divider(height: 28),
                          Text(_item!.body, style: const TextStyle(fontSize: 16, height: 1.7)),
                        ],
                      ),
                    ),
    );
  }
}
