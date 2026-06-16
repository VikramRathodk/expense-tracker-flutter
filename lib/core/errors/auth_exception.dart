import 'app_exception.dart';

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
  }) : super(statusCode: 401);
}

class TokenRefreshException extends AppException {
  const TokenRefreshException({
    super.message = 'Failed to refresh session. Please log in again.',
  }) : super(statusCode: 401);
}
