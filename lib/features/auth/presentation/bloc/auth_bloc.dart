import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/dev_flags.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../services/secure_storage_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

sealed class AuthEvent {}

/// Fired on app start to restore session from secure storage.
class AuthRestoreSession extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthRegisterRequested extends AuthEvent {
  AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileUpdated extends AuthEvent {
  AuthProfileUpdated(this.user);
  final UserModel user;
}

// ─── States ───────────────────────────────────────────────────────────────────

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user);
  final UserModel user;
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  AuthError({required this.message, this.fieldErrors});
  final String message;
  final Map<String, String>? fieldErrors;
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    required SecureStorageService storage,
  })  : _repository = repository,
        _storage = storage,
        super(AuthInitial()) {
    on<AuthRestoreSession>(_onRestoreSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthProfileUpdated>((event, emit) => emit(AuthAuthenticated(event.user)));
  }

  final AuthRepository _repository;
  final SecureStorageService _storage;

  Future<void> _onRestoreSession(
    AuthRestoreSession event,
    Emitter<AuthState> emit,
  ) async {
    if (kBypassAuth) {
      emit(AuthAuthenticated(UserModel.fromJson(devUserJson)));
      return;
    }
    emit(AuthLoading());
    try {
      final accessToken = await _storage.getAccessToken();
      if (accessToken == null) {
        emit(AuthUnauthenticated());
        return;
      }
      // Validate by fetching current user; AuthInterceptor refreshes if needed
      final user = await _repository.getMe();
      await _storage.saveUser(user);
      emit(AuthAuthenticated(user));
    } on NetworkException catch (_) {
      // Offline: serve cached user so app still opens
      final cachedUser = await _storage.getUser();
      if (cachedUser != null) {
        emit(AuthAuthenticated(cachedUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } on AppException catch (_) {
      // Auth failure (token invalid/expired and refresh also failed)
      await _storage.clearAll();
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(response.user));
    } on AppException catch (e) {
      emit(AuthError(message: e.message, fieldErrors: e.fieldErrors));
    } catch (_) {
      emit(AuthError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(response.user));
    } on AppException catch (e) {
      emit(AuthError(message: e.message, fieldErrors: e.fieldErrors));
    } catch (_) {
      emit(AuthError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.logout();
    } catch (_) {
      // Ensure local state is cleared even if the API call fails
      await _storage.clearAll();
    }
    emit(AuthUnauthenticated());
  }
}
