import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Exchanges the given refresh token for a new access token.
  Future<String> refreshToken(String refreshToken);

  Future<void> logout();

  Future<UserModel> getMe();
}
