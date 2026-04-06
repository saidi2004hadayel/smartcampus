import 'package:dio/dio.dart';
import '../../../core/storage/database_helper.dart';
import 'timetable_model.dart';

class TimetableRepository {
  final Dio _dio;
  final DatabaseHelper _db;

  TimetableRepository(this._dio, this._db);

  Future<List<TimetableEntry>> getTimetable({int? day}) async {
    try {
      final res = await _dio.get(
        '/timetable/',
        queryParameters: day != null ? {'day': day} : null,
      );
      final items = (res.data as List)
          .map((j) => TimetableEntry.fromJson(j as Map<String, dynamic>))
          .toList();
      await _db.upsertTimetable(items.map((e) => e.toMap()).toList());
      return items;
    } on DioException {
      final maps = await _db.getCachedTimetable(day: day);
      return maps.map(TimetableEntry.fromMap).toList();
    }
  }

  Future<String> exportAsJson() async {
    final entries = await getTimetable();
    final buffer = StringBuffer('[\n');
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      buffer.write('  {\n');
      buffer.write('    "course_code": "${e.courseCode}",\n');
      buffer.write('    "course_name": "${e.courseName}",\n');
      buffer.write('    "day": "${e.dayName}",\n');
      buffer.write('    "start_time": "${e.startTime}",\n');
      buffer.write('    "end_time": "${e.endTime}",\n');
      buffer.write('    "room": "${e.room}",\n');
      buffer.write('    "professor": "${e.professor}",\n');
      buffer.write('    "type": "${e.type}"\n');
      buffer.write('  }${i < entries.length - 1 ? ',' : ''}\n');
    }
    buffer.write(']');
    return buffer.toString();
  }
}