import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/di/service_locator.dart';
import '../bloc/announcement_bloc.dart';
import '../data/announcement_model.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnnouncementBloc>()..add(const LoadAnnouncementsEvent()),
      child: const _AnnouncementsView(),
    );
  }
}

class _AnnouncementsView extends StatelessWidget {
  const _AnnouncementsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Announcements'),
        actions: [
          BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context
                  .read<AnnouncementBloc>()
                  .add(const LoadAnnouncementsEvent(forceRefresh: true)),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          return Column(
            children: [
              // ── Offline banner ─────────────────────────────────────────
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'You\'re offline — showing cached content',
                        style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: switch (state) {
                  AnnouncementLoading() => _ShimmerList(),
                  AnnouncementLoaded(:final items) => items.isEmpty
                      ? const Center(child: Text('No announcements yet.'))
                      : RefreshIndicator(
                          onRefresh: () async => context
                              .read<AnnouncementBloc>()
                              .add(const LoadAnnouncementsEvent(forceRefresh: true)),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) => _AnnouncementCard(item: items[i]),
                          ),
                        ),
                  AnnouncementError(:final message) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context
                                .read<AnnouncementBloc>()
                                .add(const LoadAnnouncementsEvent()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
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

class _AnnouncementCard extends StatelessWidget {
  final Announcement item;
  const _AnnouncementCard({required this.item});

  Color _categoryColor(String cat) => switch (cat) {
        'safety' => Colors.red,
        'it' => Colors.blue,
        'academic' => Colors.purple,
        'facilities' => Colors.teal,
        _ => Colors.grey,
      };

  IconData _categoryIcon(String cat) => switch (cat) {
        'safety' => Icons.warning_amber,
        'it' => Icons.computer,
        'academic' => Icons.school,
        'facilities' => Icons.business,
        _ => Icons.campaign,
      };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(item.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/announcements/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_categoryIcon(item.category), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.isImportant)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('IMPORTANT',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(item.author, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d, y').format(item.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 90,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
