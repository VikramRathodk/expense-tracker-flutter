import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/core/errors/app_exception.dart';
import 'package:expense_tracker/core/errors/network_exception.dart';
import 'package:expense_tracker/features/auth/domain/models/auth_response_model.dart';
import 'package:expense_tracker/features/auth/domain/models/user_model.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/services/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late _MockAuthRepository repo;
  late _MockSecureStorageService storage;

  final tUser = UserModel(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    roles: ['USER'],
    isActive: true,
    createdAt: '2024-01-01T00:00:00Z',
    baseCurrency: 'INR',
  );

  final tAuthResponse = AuthResponseModel(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    user: tUser,
  );

  setUp(() {
    repo = _MockAuthRepository();
    storage = _MockSecureStorageService();
  });

  AuthBloc build() => AuthBloc(repository: repo, storage: storage);

  group('AuthRestoreSession', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when no token stored',
      build: build,
      setUp: () => when(() => storage.getAccessToken()).thenAnswer((_) async => null),
      act: (b) => b.add(AuthRestoreSession()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when token valid',
      build: build,
      setUp: () {
        when(() => storage.getAccessToken()).thenAnswer((_) async => 'token');
        when(() => repo.getMe()).thenAnswer((_) async => tUser);
        when(() => storage.saveUser(tUser)).thenAnswer((_) async {});
      },
      act: (b) => b.add(AuthRestoreSession()),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'serves cached user when offline',
      build: build,
      setUp: () {
        when(() => storage.getAccessToken()).thenAnswer((_) async => 'token');
        when(() => repo.getMe()).thenThrow(const NetworkException());
        when(() => storage.getUser()).thenAnswer((_) async => tUser);
      },
      act: (b) => b.add(AuthRestoreSession()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated when token expired and no cache',
      build: build,
      setUp: () {
        when(() => storage.getAccessToken()).thenAnswer((_) async => 'expired');
        when(() => repo.getMe())
            .thenThrow(const AppException(message: 'Unauthorized', statusCode: 401));
        when(() => storage.clearAll()).thenAnswer((_) async {});
      },
      act: (b) => b.add(AuthRestoreSession()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: build,
      setUp: () => when(() => repo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tAuthResponse),
      act: (b) => b.add(AuthLoginRequested(email: 'test@example.com', password: 'pass')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (b) {
        final state = b.state as AuthAuthenticated;
        expect(state.user, equals(tUser));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Error] on AppException',
      build: build,
      setUp: () => when(() => repo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AppException(message: 'Invalid credentials', statusCode: 401)),
      act: (b) => b.add(AuthLoginRequested(email: 'bad@test.com', password: 'wrong')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      verify: (b) {
        final state = b.state as AuthError;
        expect(state.message, 'Invalid credentials');
      },
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated after logout',
      build: build,
      setUp: () {
        when(() => repo.logout()).thenAnswer((_) async {});
      },
      act: (b) => b.add(AuthLogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });

  group('AuthProfileUpdated', () {
    blocTest<AuthBloc, AuthState>(
      'emits Authenticated with updated user',
      build: build,
      seed: () => AuthAuthenticated(tUser),
      act: (b) => b.add(AuthProfileUpdated(tUser.copyWith(name: 'New Name'))),
      expect: () => [isA<AuthAuthenticated>()],
      verify: (b) {
        expect((b.state as AuthAuthenticated).user.name, 'New Name');
      },
    );
  });
}