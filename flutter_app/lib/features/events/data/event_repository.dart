import 'package:dio/dio.dart';
import '../../../core/storage/database_helper.dart';
import 'event_model.dart';

class EventRepository {
  final Dio _dio;
  final DatabaseHelper _db;

  EventRepository(this._dio, this._db);

  Future<List<CampusEvent>> getEvents({bool forceRefresh = false}) async {
    try {
      final res = await _dio.get('/events/');
      final items = (res.data as List)
          .map((j) => CampusEvent.fromJson(j as Map<String, dynamic>))
          .toList();
      await _db.upsertEvents(items.map((e) => e.toMap()).toList());
      return items;
    } on DioException {
      final maps = await _db.getCachedEvents();
      return maps.map(CampusEvent.fromMap).toList();
    }
  }
}