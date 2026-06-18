import '../../domain/models/auth_response_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../services/secure_storage_service.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._storage);

  final AuthRemoteDataSource _dataSource;
  final SecureStorageService _storage;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.login(email: email, password: password);
    await _persistSession(response);
    return response;
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.register(
      name: name,
      email: email,
      password: password,
    );
    await _persistSession(response);
    return response;
  }

  @override
  Future<String> refreshToken(String token) async {
    final newAccessToken = await _dataSource.refreshToken(token);
    await _storage.saveAccessToken(newAccessToken);
    return newAccessToken;
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      // Always clear local state regardless of API result
      await _storage.clearAll();
    }
  }

  @override
  Future<UserModel> getMe() => _dataSource.getMe();

  Future<void> _persistSession(AuthResponseModel response) {
    return Future.wait([
      _storage.saveAccessToken(response.accessToken),
      _storage.saveRefreshToken(response.refreshToken),
      _storage.saveUser(response.user),
    ]);
  }
}
