import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email, password;
  const AuthLoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String fullName, email, password;
  const AuthRegisterEvent(
      {required this.fullName, required this.email, required this.password});
  @override
  List<Object?> get props => [fullName, email, password];
}

class AuthBiometricLoginEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final String userId, email, name;
  const AuthAuthenticatedState(
      {required this.userId, required this.email, required this.name});
  @override
  List<Object?> get props => [userId, email, name];
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  final SecureStorageService _storage;

  AuthBloc(this._repo, this._storage) : super(AuthInitialState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthBiometricLoginEvent>(_onBiometric);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onCheckStatus(
      AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    final token = await _storage.getToken();
    if (token == null) {
      emit(AuthUnauthenticatedState());
      return;
    }
    final user = await _storage.getUser();
    final id = user['id'];
    final email = user['email'];
    final name = user['name'];
    if (id != null && email != null && name != null) {
      emit(AuthAuthenticatedState(userId: id, email: email, name: name));
    } else {
      emit(AuthUnauthenticatedState());
    }
  }

  Future<void> _onLogin(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final result =
      await _repo.login(email: event.email, password: event.password);
      await _storage.saveToken(result['token'] ?? '');
      await _storage.saveUser(
        id: result['id'] ?? '',
        email: result['email'] ?? '',
        name: result['name'] ?? '',
      );
      emit(AuthAuthenticatedState(
        userId: result['id'] ?? '',
        email: result['email'] ?? '',
        name: result['name'] ?? '',
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onRegister(
      AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final result = await _repo.register(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );
      await _storage.saveToken(result['token'] ?? '');
      await _storage.saveUser(
        id: result['id'] ?? '',
        email: result['email'] ?? '',
        name: result['name'] ?? '',
      );
      emit(AuthAuthenticatedState(
        userId: result['id'] ?? '',
        email: result['email'] ?? '',
        name: result['name'] ?? '',
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onBiometric(
      AuthBiometricLoginEvent event, Emitter<AuthState> emit) async {
    final token = await _storage.getToken();
    if (token == null) {
      emit(AuthErrorState('No saved session. Please log in first.'));
      return;
    }
    final user = await _storage.getUser();
    final id = user['id'];
    final email = user['email'];
    final name = user['name'];
    if (id != null && email != null && name != null) {
      emit(AuthAuthenticatedState(userId: id, email: email, name: name));
    } else {
      emit(AuthErrorState('Session expired. Please log in again.'));
    }
  }

  Future<void> _onLogout(
      AuthLogoutEvent event, Emitter<AuthState> emit) async {
    await _repo.logout();
    await _storage.clearAll();
    emit(AuthUnauthenticatedState());
  }
}