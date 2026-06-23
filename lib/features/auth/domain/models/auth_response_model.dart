import 'user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final payload =
        json['data'] as Map<String, dynamic>? ?? json;
    return AuthResponseModel(
      accessToken: payload['accessToken'] as String,
      refreshToken: payload['refreshToken'] as String,
      user: UserModel.fromJson(payload['user'] as Map<String, dynamic>),
    );
  }
}
