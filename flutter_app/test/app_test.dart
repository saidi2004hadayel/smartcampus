import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:smartcampus/features/announcements/data/announcement_model.dart';
import 'package:smartcampus/features/announcements/data/announcement_repository.dart';
import 'package:smartcampus/features/announcements/bloc/announcement_bloc.dart';
import 'package:smartcampus/features/auth/bloc/auth_bloc.dart';
import 'package:smartcampus/features/auth/data/auth_repository.dart';
import 'package:smartcampus/core/storage/secure_storage_service.dart';
import 'package:smartcampus/core/storage/database_helper.dart';
import 'package:smartcampus/core/network/connectivity_service.dart';

@GenerateMocks([Dio, DatabaseHelper, SecureStorageService, ConnectivityService, AuthRepository, AnnouncementRepository])
import 'app_test.mocks.dart';

void main() {
  // ── Announcement model parsing ─────────────────────────────────────────────
  group('Announcement.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'abc123',
        'title': 'Test Title',
        'body': 'Test body text',
        'category': 'academic',
        'author': 'Dr. Test',
        'created_at': '2025-01-15T10:00:00.000Z',
        'is_important': true,
      };
      final a = Announcement.fromJson(json);
      expect(a.id, 'abc123');
      expect(a.title, 'Test Title');
      expect(a.category, 'academic');
      expect(a.isImportant, true);
      expect(a.createdAt.year, 2025);
    });

    test('handles missing optional fields with defaults', () {
      final json = {'id': 'x', 'title': 'T', 'body': 'B'};
      final a = Announcement.fromJson(json);
      expect(a.category, 'general');
      expect(a.isImportant, false);
      expect(a.author, 'Admin');
    });

    test('toMap round-trip preserves data', () {
      final original = Announcement(
        id: '1', title: 'Hello', body: 'World',
        category: 'it', author: 'IT', isImportant: true,
        createdAt: DateTime(2025, 6, 1),
      );
      final map = original.toMap();
      final restored = Announcement.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.isImportant, original.isImportant);
    });
  });

  // ── AnnouncementRepository ─────────────────────────────────────────────────
  group('AnnouncementRepository', () {
    late MockDio mockDio;
    late MockDatabaseHelper mockDb;
    late AnnouncementRepository repo;

    setUp(() {
      mockDio = MockDio();
      mockDb = MockDatabaseHelper();
      repo = AnnouncementRepository(mockDio, mockDb);
    });

    test('getAnnouncements returns parsed items on success', () async {
      final jsonList = [
        {'id': '1', 'title': 'A1', 'body': 'B1', 'created_at': DateTime.now().toIso8601String()},
        {'id': '2', 'title': 'A2', 'body': 'B2', 'created_at': DateTime.now().toIso8601String()},
      ];
      when(mockDio.get('/announcements/')).thenAnswer(
          (_) async => Response(data: jsonList, statusCode: 200, requestOptions: RequestOptions()));
      when(mockDb.upsertAnnouncements(any)).thenAnswer((_) async {});

      final result = await repo.getAnnouncements();
      expect(result.length, 2);
      expect(result.first.id, '1');
    });

    test('getAnnouncements falls back to cache on DioException', () async {
      when(mockDio.get('/announcements/')).thenThrow(
          DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionTimeout));
      when(mockDb.getCachedAnnouncements()).thenAnswer((_) async => [
            {'id': 'cached', 'title': 'Cached', 'body': 'From DB', 'created_at': DateTime.now().toIso8601String()},
          ]);

      final result = await repo.getAnnouncements();
      expect(result.length, 1);
      expect(result.first.id, 'cached');
    });
  });

  // ── AuthBloc ───────────────────────────────────────────────────────────────
  group('AuthBloc', () {
    late MockAuthRepository mockRepo;
    late MockSecureStorageService mockStorage;
    late AuthBloc bloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      mockStorage = MockSecureStorageService();
      bloc = AuthBloc(mockRepo, mockStorage);
    });

    tearDown(() => bloc.close());

    test('emits Unauthenticated when no token stored', () async {
      when(mockStorage.getToken()).thenAnswer((_) async => null);
      bloc.add(AuthCheckStatusEvent());
      await expectLater(
        bloc.stream,
        emits(isA<AuthUnauthenticatedState>()),
      );
    });

    test('emits Authenticated when token and user exist', () async {
      when(mockStorage.getToken()).thenAnswer((_) async => 'valid_token');
      when(mockStorage.getUser()).thenAnswer((_) async => {
            'id': 'u1',
            'email': 'test@univ.dz',
            'name': 'Test User',
          });
      bloc.add(AuthCheckStatusEvent());
      await expectLater(
        bloc.stream,
        emits(isA<AuthAuthenticatedState>()),
      );
    });

    test('emits Error on login failure', () async {
      when(mockRepo.login(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(Exception('Invalid credentials'));
      bloc.add(const AuthLoginEvent(email: 'bad@test.com', password: 'wrong'));
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoadingState>(), isA<AuthErrorState>()]),
      );
    });
  });
}
