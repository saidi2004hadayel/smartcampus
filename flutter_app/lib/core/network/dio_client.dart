import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

// Use 10.0.2.2 for Android emulator (maps to localhost on host machine)
const String _baseUrl = 'http://10.0.2.2:8003/api';

class DioClient {
  final SecureStorageService _storage;
  DioClient(this._storage);

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.clearToken();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}