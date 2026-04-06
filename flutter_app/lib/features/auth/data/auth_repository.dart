import 'package:dio/dio.dart';
import '../../../core/storage/secure_storage_service.dart';

class AuthRepository {
  final Dio _dio;
  // ignore: unused_field
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<Map<String, String>> login(
      {required String email, required String password}) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _parseTokenResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, String>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {'full_name': fullName, 'email': email, 'password': password},
      );
      return _parseTokenResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
  }

  Map<String, String> _parseTokenResponse(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>? ?? {};
    return {
      'token': (data['access_token'] as String?) ?? '',
      'id': (user['id'] as String?) ?? '',
      'email': (user['email'] as String?) ?? '',
      'name': (user['full_name'] as String?) ?? '',
    };
  }

  String _handleError(DioException e) {
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return detail['detail'].toString();
    }
    return e.message ?? 'Network error';
  }
}