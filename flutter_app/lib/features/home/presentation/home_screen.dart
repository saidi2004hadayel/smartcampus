import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/di/service_locator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../announcements/bloc/announcement_bloc.dart';
import '../../announcements/data/announcement_model.dart';
import '../../timetable/bloc/timetable_bloc.dart';
import '../../timetable/data/timetable_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _tiltX = 0, _tiltY = 0;

  late final AnnouncementBloc _announcementBloc;
  late final TimetableBloc _timetableBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _announcementBloc = sl<AnnouncementBloc>()
      ..add(const LoadAnnouncementsEvent());
    _timetableBloc = sl<TimetableBloc>()..add(const LoadTimetableEvent());
    _accelSub = accelerometerEventStream().listen((event) {
      if (mounted) setState(() {
        _tiltX = event.x;
        _tiltY = event.y;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _announcementBloc.add(const LoadAnnouncementsEvent(forceRefresh: true));
      _timetableBloc.add(const LoadTimetableEvent());
      debugPrint('[Lifecycle] App resumed — refreshing data');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelSub?.cancel();
    _announcementBloc.close();
    _timetableBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticatedState
        ? authState.name.split(' ').first
        : 'Student';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _announcementBloc),
        BlocProvider.value(value: _timetableBloc),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3FF),
        body: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            _Header(greeting: greeting, name: name),

            // ── Scrollable content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuickNavGrid(),
                    const SizedBox(height: 28),

                    _SectionTitle(
                      "Today's classes",
                      onSeeAll: () => context.go('/timetable'),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<TimetableBloc, TimetableState>(
                      builder: (_, state) {
                        if (state is TimetableLoading) {
                          return const _LoadingCard();
                        }
                        if (state is TimetableLoaded) {
                          final today = state.entries;
                          if (today.isEmpty) {
                            return _EmptyCard(
                              icon: Icons.free_breakfast_outlined,
                              message: 'No classes today — enjoy your day!',
                            );
                          }
                          return Column(
                            children: today
                                .take(3)
                                .map((e) => _TodayClassTile(entry: e))
                                .toList(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 28),

                    _SectionTitle(
                      'Latest news',
                      onSeeAll: () => context.go('/announcements'),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<AnnouncementBloc, AnnouncementState>(
                      builder: (_, state) {
                        if (state is AnnouncementLoading) {
                          return const _LoadingCard();
                        }
                        if (state is AnnouncementLoaded) {
                          return Column(
                            children: state.items
                                .take(3)
                                .map((a) => _AnnouncementTile(item: a))
                                .toList(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 28),

                    _SectionTitle('Device sensor'),
                    const SizedBox(height: 12),
                    _AccelerometerCard(tiltX: _tiltX, tiltY: _tiltY),
                    const SizedBox(height: 32),
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

// ── Header with curved white arc at bottom ────────────────────────────────────
class _Header extends StatelessWidget {
  final String greeting, name;
  const _Header({required this.greeting, required this.name});

  String _formattedDate() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF1A0933),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            bottom: 48,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── SmartCampus Logo + Title ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // App title
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Smart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Campus',
                          style: TextStyle(
                            color: Color(0xFFA78BFA),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Divider ──────────────────────────────────────────────
              Container(
                width: 40,
                height: 1,
                color: Colors.white.withOpacity(0.15),
              ),

              const SizedBox(height: 16),

              // ── Greeting ─────────────────────────────────────────────
              Text(
                greeting,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA78BFA),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$name 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              // ── Date pill ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  _formattedDate(),
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Curved white arc at bottom ───────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick nav 2×2 grid ────────────────────────────────────────────────────────
class _QuickNavGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.campaign_rounded, 'News', '/announcements',
          const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
      _NavItem(Icons.celebration_rounded, 'Events', '/events',
          const Color(0xFFDB2777), const Color(0xFFFCE7F3)),
      _NavItem(Icons.schedule_rounded, 'Schedule', '/timetable',
          const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
      _NavItem(Icons.map_rounded, 'Map', '/map',
          const Color(0xFF059669), const Color(0xFFECFDF5)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map(
            (item) => GestureDetector(
          onTap: () => context.go(item.route),
          child: Container(
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: item.color, size: 38),
                const SizedBox(height: 10),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label, route;
  final Color color, bgColor;
  _NavItem(this.icon, this.label, this.route, this.color, this.bgColor);
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionTitle(this.title, {this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A0933),
            letterSpacing: -0.3,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Today class tile ──────────────────────────────────────────────────────────
class _TodayClassTile extends StatelessWidget {
  final TimetableEntry entry;
  const _TodayClassTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.startTime,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1A0933),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.room} · ${entry.professor}',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFDDD6FE),
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Announcement tile ─────────────────────────────────────────────────────────
class _AnnouncementTile extends StatelessWidget {
  final Announcement item;
  const _AnnouncementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isImportant = item.isImportant;
    final accentColor =
    isImportant ? const Color(0xFFEC4899) : const Color(0xFF7C3AED);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coloured left accent bar
            Container(width: 4, color: accentColor),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isImportant ? '⚠ ${item.title}' : item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isImportant
                              ? const Color(0xFFDB2777)
                              : const Color(0xFF1A0933),
                        ),
                      ),
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

// ── Accelerometer card ────────────────────────────────────────────────────────
class _AccelerometerCard extends StatelessWidget {
  final double tiltX, tiltY;
  const _AccelerometerCard({required this.tiltX, required this.tiltY});

  @override
  Widget build(BuildContext context) {
    final clampedX = tiltX.clamp(-10.0, 10.0);
    final clampedY = tiltY.clamp(-10.0, 10.0);
    final offsetX = (clampedX / 10) * 40;
    final offsetY = (clampedY / 10) * 20;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Color(0xFF7C3AED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Accelerometer',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1A0933),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'X: ${tiltX.toStringAsFixed(2)}  Y: ${tiltY.toStringAsFixed(2)}  (m/s²)',
            style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDE9FE)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _CrosshairPainter()),
                ),
                Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tilt your device to see real-time sensor data',
            style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDD6FE)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Loading card ──────────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEDE9FE)),
    ),
    child: const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF7C3AED),
        strokeWidth: 2.5,
      ),
    ),
  );
}

// ── Empty card ────────────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEDE9FE)),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFDDD6FE), size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFC4B5FD),
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}