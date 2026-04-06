class TimetableEntry {
  final String id;
  final String courseCode;
  final String courseName;
  final String room;
  final String professor;
  final int dayOfWeek; // 0=Mon, 6=Sun
  final String startTime; // "HH:MM"
  final String endTime;
  final String type; // lecture, lab, tutorial

  const TimetableEntry({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.room,
    required this.professor,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> j) => TimetableEntry(
        id: j['id'] ?? '',
        courseCode: j['course_code'] ?? '',
        courseName: j['course_name'] ?? '',
        room: j['room'] ?? '',
        professor: j['professor'] ?? '',
        dayOfWeek: j['day_of_week'] ?? 0,
        startTime: j['start_time'] ?? '00:00',
        endTime: j['end_time'] ?? '00:00',
        type: j['type'] ?? 'lecture',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'course_code': courseCode,
        'course_name': courseName,
        'room': room,
        'professor': professor,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'type': type,
      };

  factory TimetableEntry.fromMap(Map<String, dynamic> m) =>
      TimetableEntry.fromJson(m);

  static const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String get dayName => dayNames[dayOfWeek.clamp(0, 6)];

  /// Next DateTime when this class occurs
  DateTime get nextOccurrence {
    final now = DateTime.now();
    final todayWeekday = now.weekday - 1; // 0=Mon
    int daysAhead = dayOfWeek - todayWeekday;
    if (daysAhead < 0) daysAhead += 7;
    final parts = startTime.split(':');
    final target = DateTime(
      now.year, now.month, now.day + daysAhead,
      int.parse(parts[0]), int.parse(parts[1]),
    );
    // If same day but already passed, push one week
    if (target.isBefore(now)) return target.add(const Duration(days: 7));
    return target;
  }
}
