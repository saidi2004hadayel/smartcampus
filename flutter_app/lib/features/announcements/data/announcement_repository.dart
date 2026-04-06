import 'package:dio/dio.dart';
import '../../../core/storage/database_helper.dart';
import 'announcement_model.dart';

class AnnouncementRepository {
  final Dio _dio;
  final DatabaseHelper _db;

  AnnouncementRepository(this._dio, this._db);

  Future<List<Announcement>> getAnnouncements(
      {bool forceRefresh = false}) async {
    try {
      final res = await _dio.get('/announcements/');
      final items = (res.data as List)
          .map((j) => Announcement.fromJson(j as Map<String, dynamic>))
          .toList();
      await _db.upsertAnnouncements(items.map((a) => a.toMap()).toList());
      return items;
    } on DioException {
      return _getCached();
    }
  }

  Future<List<Announcement>> _getCached() async {
    final maps = await _db.getCachedAnnouncements();
    return maps.map(Announcement.fromMap).toList();
  }

  Future<Announcement?> getById(String id) async {
    try {
      final res = await _dio.get('/announcements/$id');
      return Announcement.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      final maps = await _db.getCachedAnnouncements();
      final match = maps.where((m) => m['id'] == id);
      return match.isNotEmpty ? Announcement.fromMap(match.first) : null;
    }
  }
}