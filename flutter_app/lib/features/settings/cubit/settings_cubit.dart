import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class SettingsState extends Equatable {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String language; // 'en', 'fr', 'ar'

  const SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.language = 'en',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? language,
  }) =>
      SettingsState(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        language: language ?? this.language,
      );

  @override
  List<Object?> get props => [isDarkMode, notificationsEnabled, language];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  static const _keyDark = 'dark_mode';
  static const _keyNotif = 'notifications_enabled';
  static const _keyLang = 'language';

  SettingsCubit(this._prefs) : super(const SettingsState());

  void loadSettings() {
    emit(SettingsState(
      isDarkMode: _prefs.getBool(_keyDark) ?? false,
      notificationsEnabled: _prefs.getBool(_keyNotif) ?? true,
      language: _prefs.getString(_keyLang) ?? 'en',
    ));
  }

  Future<void> toggleDarkMode(bool value) async {
    await _prefs.setBool(_keyDark, value);
    emit(state.copyWith(isDarkMode: value));
  }

  Future<void> toggleNotifications(bool value) async {
    await _prefs.setBool(_keyNotif, value);
    emit(state.copyWith(notificationsEnabled: value));
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(_keyLang, lang);
    emit(state.copyWith(language: lang));
  }
}
