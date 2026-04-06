import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/announcements/bloc/announcement_bloc.dart';
import '../../features/announcements/data/announcement_repository.dart';
import '../../features/events/bloc/event_bloc.dart';
import '../../features/events/data/event_repository.dart';
import '../../features/timetable/bloc/timetable_bloc.dart';
import '../../features/timetable/data/timetable_repository.dart';
import '../../features/settings/cubit/settings_cubit.dart';
import '../network/dio_client.dart';
import '../network/connectivity_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/database_helper.dart';
import '../notifications/notification_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── External ───────────────────────────────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // ── Core services ──────────────────────────────────────────────────────────
  sl.registerSingleton<SecureStorageService>(
    SecureStorageService(sl<FlutterSecureStorage>()),
  );

  sl.registerSingleton<DatabaseHelper>(DatabaseHelper());
  await sl<DatabaseHelper>().init();

  sl.registerSingleton<ConnectivityService>(ConnectivityService());

  sl.registerSingleton<NotificationService>(NotificationService());
  await sl<NotificationService>().init();

  // ── Networking ─────────────────────────────────────────────────────────────
  sl.registerSingleton<Dio>(
    DioClient(sl<SecureStorageService>()).create(),
  );

  // ── Repositories ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(sl<Dio>(), sl<SecureStorageService>()),
  );
  sl.registerLazySingleton<AnnouncementRepository>(
        () => AnnouncementRepository(sl<Dio>(), sl<DatabaseHelper>()),
  );
  sl.registerLazySingleton<EventRepository>(
        () => EventRepository(sl<Dio>(), sl<DatabaseHelper>()),
  );
  sl.registerLazySingleton<TimetableRepository>(
        () => TimetableRepository(sl<Dio>(), sl<DatabaseHelper>()),
  );

  // ── BLoCs / Cubits ─────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(sl<AuthRepository>(), sl<SecureStorageService>()),
  );
  sl.registerFactory<AnnouncementBloc>(
        () => AnnouncementBloc(
        sl<AnnouncementRepository>(), sl<ConnectivityService>()),
  );
  sl.registerFactory<EventBloc>(
        () => EventBloc(sl<EventRepository>(), sl<ConnectivityService>()),
  );
  sl.registerFactory<TimetableBloc>(
        () => TimetableBloc(
        sl<TimetableRepository>(), sl<NotificationService>()),
  );
  sl.registerFactory<SettingsCubit>(
        () => SettingsCubit(sl<SharedPreferences>()),
  );
}